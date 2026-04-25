{-# LANGUAGE OverloadedStrings #-}

-- |
-- Production pull loop for the image-worker: PubSub pull -> Stability
-- text-to-image -> Storage upload -> Firestore write + currentImage
-- handoff -> ack.
module ImageWorker.PullLoop
  ( runPullLoop,
  )
where

import Control.Concurrent (threadDelay)
import Control.Monad (forM_, forever)
import Data.Maybe (fromMaybe)
import Data.Text (Text)
import qualified Data.Text as T
import qualified Network.HTTP.Conduit as Http
import System.Environment (lookupEnv)
import System.IO (hPutStrLn, stderr)

import ImageWorker.FirestoreWriter (readCurrentImage, switchCurrentImage, writeCompletedImage)
import ImageWorker.StabilityAdapter
  ( ImageOutcome (..),
    StabilityConfig,
    generateImage,
    resolveStabilityConfig,
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
import Vocas.Worker.Core.Storage (StorageClient, storageFromEnv, uploadObject)

defaultSubscription :: Text
defaultSubscription = "workflow.image-jobs.sub"

defaultBucket :: Text
defaultBucket = "demo-vocastock.appspot.com"

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
  maybeStorage <- storageFromEnv
  storage <- case maybeStorage of
    Just client -> pure client
    Nothing -> die "STORAGE_EMULATOR_HOST must be set in production mode"
  stabilityResult <- resolveStabilityConfig
  stability <- case stabilityResult of
    Right cfg -> pure cfg
    Left reason -> die reason
  subscription <-
    fmap
      (T.pack . fromMaybe (T.unpack defaultSubscription))
      (lookupEnv "VOCAS_IMAGE_SUBSCRIPTION")
  bucket <-
    fmap
      (T.pack . fromMaybe (T.unpack defaultBucket))
      (lookupEnv "VOCAS_STORAGE_BUCKET")
  manager <- Http.newManager Http.tlsManagerSettings
  putStrLn ("[vocastock] image-worker pull loop started on subscription=" <> T.unpack subscription)
  forever (tick pubsub firestore storage stability manager subscription bucket)

tick ::
  PubSubClient ->
  FirestoreClient ->
  StorageClient ->
  StabilityConfig ->
  Http.Manager ->
  Text ->
  Text ->
  IO ()
tick pubsub firestore storage stability manager subscription bucket = do
  messages <- pullMessages pubsub subscription 10
  forM_ messages $ \msg -> do
    outcome <- processMessage firestore storage stability manager bucket msg
    case outcome of
      Right () -> acknowledge pubsub subscription [receivedAckId msg]
      Left (True, reason) -> do
        hPutStrLn stderr ("[vocastock] image-worker retryable failure: " <> reason)
      Left (False, reason) -> do
        hPutStrLn stderr ("[vocastock] image-worker terminal failure: " <> reason)
        acknowledge pubsub subscription [receivedAckId msg]
  threadDelay (5 * 1_000_000)

processMessage ::
  FirestoreClient ->
  StorageClient ->
  StabilityConfig ->
  Http.Manager ->
  Text ->
  ReceivedMessage ->
  IO (Either (Bool, String) ())
processMessage firestore storage stability manager bucket msg =
  case decodeDispatchEnvelope (receivedData msg) of
    Left reason -> pure (Left (False, "envelope-decode-failed: " <> reason))
    Right envelope
      | envelopeKind envelope == ImageGenerationKind
          || envelopeKind envelope == RetryKind ->
          runImageJob firestore storage stability manager bucket envelope
      | otherwise ->
          pure (Left (False, "unsupported kind for image-worker"))

runImageJob ::
  FirestoreClient ->
  StorageClient ->
  StabilityConfig ->
  Http.Manager ->
  Text ->
  DispatchEnvelope ->
  IO (Either (Bool, String) ())
runImageJob firestore storage stability manager bucket envelope = do
  let actor = envelopeActor envelope
  let vocabularyExpressionId = envelopeVocabularyExpression envelope
  let idempotencyKey = envelopeIdempotencyKey envelope
  let prompt =
        "Illustration visualising \""
          <> fromMaybe vocabularyExpressionId (envelopeNormalizedText envelope)
          <> "\""
  outcome <- generateImage stability manager prompt idempotencyKey
  case outcome of
    ImageRetryable reason -> pure (Left (True, reason))
    ImageTerminal reason -> pure (Left (False, reason))
    ImageSucceeded bytes -> do
      let imageId = T.pack ("img-" <> T.unpack idempotencyKey)
      let objectPath =
            T.concat
              [ "actors/",
                actor,
                "/images/",
                imageId,
                ".png"
              ]
      uploadResult <- uploadObject storage bucket objectPath "image/png" bytes
      case uploadResult of
        Left err -> pure (Left (True, "storage-upload-failed: " <> show err))
        Right assetReference -> do
          -- explanationId is not on the envelope; we assume the worker
          -- uses the vocabulary expression's currentExplanation handoff.
          -- In practice the command-api records vocabulary -> explanation
          -- linkage via Firestore, but for this pass we link by
          -- explanation id == vocabulary id (a placeholder covered by
          -- feature tests in Phase E).
          let explanationId = vocabularyExpressionId
          previousImage <- readCurrentImage firestore actor explanationId
          writeResult <-
            writeCompletedImage
              firestore
              actor
              imageId
              explanationId
              assetReference
              (T.pack "Generated illustration")
              Nothing
              Nothing
              previousImage
          case writeResult of
            Left err -> pure (Left (True, "firestore-write-failed: " <> show err))
            Right () -> do
              handoffResult <- switchCurrentImage firestore actor explanationId imageId
              case handoffResult of
                Left err -> pure (Left (True, "firestore-patch-failed: " <> show err))
                Right () -> pure (Right ())

die :: String -> IO a
die reason = do
  hPutStrLn stderr ("[vocastock] image-worker cannot start: " <> reason)
  error reason
