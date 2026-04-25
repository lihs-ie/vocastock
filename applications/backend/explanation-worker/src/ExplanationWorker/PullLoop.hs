{-# LANGUAGE OverloadedStrings #-}

-- |
-- Production pull loop: PubSub `pull` -> decode dispatch envelope ->
-- Anthropic generation -> Firestore write + `currentExplanation`
-- handoff -> ack. Non-success outcomes are logged and the message is
-- acked only when the failure is terminal (retryable failures leave
-- the ack for the emulator to redeliver on the next tick).
module ExplanationWorker.PullLoop
  ( PullLoopConfig (..),
    resolvePullLoopConfig,
    runPullLoop,
    JobOutcome (..),
    handleDispatchEnvelope,
  )
where

import Control.Concurrent (threadDelay)
import Control.Monad (forever, forM_)
import qualified Data.ByteString.Lazy.Char8 as LBS8
import Data.Maybe (fromMaybe)
import Data.Text (Text)
import qualified Data.Text as T
import qualified Network.HTTP.Conduit as Http
import System.Environment (lookupEnv)
import System.IO (hPutStrLn, stderr)

import ExplanationWorker.AnthropicAdapter
  ( AnthropicConfig,
    generateExplanation,
    resolveAnthropicConfig,
  )
import ExplanationWorker.FirestoreWriter
  ( switchCurrentExplanation,
    writeCompletedExplanation,
  )
import ExplanationWorker.GenerationPort
  ( CompletedExplanationPayload (..),
    GenerationOutcome (..),
    GenerationStatus (..),
    validateCompletedPayload,
  )

import Vocas.Worker.Core.Firestore (FirestoreClient, firestoreFromEnv)
import Vocas.Worker.Core.MessageEnvelope
  ( DispatchEnvelope (..),
    DispatchKind (..),
    decodeDispatchEnvelope,
  )
import Vocas.Worker.Core.PubSub
  ( PubSubClient,
    ReceivedMessage (..),
    acknowledge,
    pubsubFromEnv,
    pullMessages,
  )

data PullLoopConfig = PullLoopConfig
  { pullSubscription :: Text,
    pullMaxMessages :: Int,
    pullIntervalMicros :: Int
  }
  deriving (Show)

data JobOutcome
  = JobSuccess
  | JobRetryableFailure String
  | JobTerminalFailure String
  deriving (Show, Eq)

defaultSubscription :: Text
defaultSubscription = "workflow.explanation-jobs.sub"

resolvePullLoopConfig :: IO PullLoopConfig
resolvePullLoopConfig = do
  subscription <- lookupEnv "VOCAS_EXPLANATION_SUBSCRIPTION"
  interval <- lookupEnv "VOCAS_WORKER_POLL_INTERVAL_SECONDS"
  let seconds = case interval >>= parseInt of
        Just s | s > 0 -> s
        _ -> 5
  pure
    PullLoopConfig
      { pullSubscription = T.pack (fromMaybe (T.unpack defaultSubscription) subscription),
        pullMaxMessages = 10,
        pullIntervalMicros = seconds * 1_000_000
      }

parseInt :: String -> Maybe Int
parseInt s = case reads s of
  [(n, "")] -> Just n
  _ -> Nothing

-- | Pulls messages forever, processing each one in turn. Returns only
-- on unrecoverable error (e.g. emulator down); in that case the caller
-- should log and exit so the container orchestrator restarts us.
runPullLoop :: IO ()
runPullLoop = do
  maybePubSub <- pubsubFromEnv
  pubsub <- case maybePubSub of
    Just client -> pure client
    Nothing -> die "PUBSUB_EMULATOR_HOST must be set in production mode"
  maybeFirestore <- firestoreFromEnv
  firestore <- case maybeFirestore of
    Just client -> pure client
    Nothing -> die "FIRESTORE_EMULATOR_HOST must be set in production mode"
  anthropicResult <- resolveAnthropicConfig
  anthropic <- case anthropicResult of
    Right cfg -> pure cfg
    Left reason -> die reason
  config <- resolvePullLoopConfig
  manager <- Http.newManager Http.tlsManagerSettings
  putStrLn
    ( "[vocastock] explanation-worker pull loop started on subscription="
        <> T.unpack (pullSubscription config)
    )
  forever (tick pubsub firestore anthropic manager config)

tick ::
  PubSubClient ->
  FirestoreClient ->
  AnthropicConfig ->
  Http.Manager ->
  PullLoopConfig ->
  IO ()
tick pubsub firestore anthropic manager config = do
  messages <- pullMessages pubsub (pullSubscription config) (pullMaxMessages config)
  forM_ messages $ \msg -> do
    outcome <- processMessage firestore anthropic manager msg
    case outcome of
      JobSuccess ->
        acknowledge pubsub (pullSubscription config) [receivedAckId msg]
      JobTerminalFailure reason -> do
        hPutStrLn stderr ("[vocastock] terminal failure: " <> reason)
        -- Terminal failures still ack so the emulator stops redelivering.
        acknowledge pubsub (pullSubscription config) [receivedAckId msg]
      JobRetryableFailure reason -> do
        hPutStrLn stderr ("[vocastock] retryable failure: " <> reason)
  threadDelay (pullIntervalMicros config)

processMessage ::
  FirestoreClient ->
  AnthropicConfig ->
  Http.Manager ->
  ReceivedMessage ->
  IO JobOutcome
processMessage firestore anthropic manager msg =
  case decodeDispatchEnvelope (receivedData msg) of
    Left reason ->
      pure (JobTerminalFailure ("envelope-decode-failed: " <> reason))
    Right envelope -> handleDispatchEnvelope firestore anthropic manager envelope

-- | Handles a single decoded envelope. Exposed for unit testing (the
-- main pull loop is I/O-heavy and hard to reach from ghci).
handleDispatchEnvelope ::
  FirestoreClient ->
  AnthropicConfig ->
  Http.Manager ->
  DispatchEnvelope ->
  IO JobOutcome
handleDispatchEnvelope firestore anthropic manager envelope =
  case envelopeKind envelope of
    ExplanationGenerationKind -> runGeneration firestore anthropic manager envelope
    RetryKind -> runGeneration firestore anthropic manager envelope
    _ -> pure (JobTerminalFailure ("unsupported kind for explanation-worker"))

runGeneration ::
  FirestoreClient ->
  AnthropicConfig ->
  Http.Manager ->
  DispatchEnvelope ->
  IO JobOutcome
runGeneration firestore anthropic manager envelope = do
  let normalizedText =
        fromMaybe
          (envelopeVocabularyExpression envelope)
          (envelopeNormalizedText envelope)
  outcome <-
    generateExplanation
      anthropic
      manager
      normalizedText
      (envelopeIdempotencyKey envelope)
  case outcomeStatus outcome of
    GenerationRetryableFailure ->
      pure
        ( JobRetryableFailure
            (fromMaybe "retryable" (outcomeFailureReason outcome))
        )
    GenerationTimedOut ->
      pure
        ( JobRetryableFailure
            (fromMaybe "timeout" (outcomeFailureReason outcome))
        )
    GenerationNonRetryableFailure ->
      pure
        ( JobTerminalFailure
            (fromMaybe "non-retryable" (outcomeFailureReason outcome))
        )
    GenerationSucceeded ->
      case outcomePayload outcome of
        Nothing ->
          pure
            ( JobTerminalFailure
                (fromMaybe "missing-payload" (outcomeFailureReason outcome))
            )
        Just payload ->
          case validateCompletedPayload payload of
            Left validationError ->
              pure (JobTerminalFailure ("payload-validation:" <> show validationError))
            Right validated -> commitSucceededGeneration firestore envelope outcome validated

commitSucceededGeneration ::
  FirestoreClient ->
  DispatchEnvelope ->
  GenerationOutcome ->
  CompletedExplanationPayload ->
  IO JobOutcome
commitSucceededGeneration firestore envelope outcome payload = do
  let actor = envelopeActor envelope
  let vocabularyExpressionId = envelopeVocabularyExpression envelope
  let normalizedText =
        fromMaybe vocabularyExpressionId (envelopeNormalizedText envelope)
  let explanationId =
        T.pack
          ( "exp-"
              <> outcomeRequestIdentifier outcome
          )
  writeResult <-
    writeCompletedExplanation
      firestore
      actor
      explanationId
      vocabularyExpressionId
      (T.pack (payloadSummary payload))
      (fromIntegral (payloadSenseCount payload))
  case writeResult of
    Left err -> pure (JobRetryableFailure ("firestore-write-failed: " <> show err))
    Right () -> do
      handoffResult <-
        switchCurrentExplanation firestore actor vocabularyExpressionId normalizedText explanationId
      case handoffResult of
        Left err ->
          pure (JobRetryableFailure ("firestore-patch-failed: " <> show err))
        Right () -> pure JobSuccess

die :: String -> IO a
die reason = do
  hPutStrLn stderr ("[vocastock] explanation-worker cannot start: " <> reason)
  error reason

-- Placeholder silences unused-import warning when hpack trims modules:
_reservedLbs :: LBS8.ByteString
_reservedLbs = LBS8.empty
