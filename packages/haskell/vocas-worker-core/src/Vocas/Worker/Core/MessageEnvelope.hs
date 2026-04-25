{-# LANGUAGE OverloadedStrings #-}

-- |
-- Envelope decoder for PubSub messages published by `command-api`.
-- Must stay in lock-step with `PubSubDispatchPort::build_dispatch_message`
-- on the Rust side.
module Vocas.Worker.Core.MessageEnvelope
  ( DispatchKind (..),
    GenerationTarget (..),
    PlanCode (..),
    DispatchEnvelope (..),
    decodeDispatchEnvelope,
    decodeDispatchKind,
    decodeGenerationTarget,
    decodePlanCode,
  )
where

import qualified Data.Aeson as Aeson
import qualified Data.Aeson.Key as Key
import qualified Data.Aeson.KeyMap as KeyMap
import qualified Data.ByteString.Lazy as LBS
import Data.Text (Text)
import qualified Data.Text as T

data DispatchKind
  = ExplanationGenerationKind
  | ImageGenerationKind
  | RetryKind
  | PurchaseKind
  | RestorePurchaseKind
  deriving (Eq, Show)

data GenerationTarget
  = ExplanationTarget
  | ImageTarget
  deriving (Eq, Show)

data PlanCode
  = FreePlan
  | StandardMonthlyPlan
  | ProMonthlyPlan
  deriving (Eq, Show)

data DispatchEnvelope = DispatchEnvelope
  { envelopeActor :: Text,
    envelopeIdempotencyKey :: Text,
    envelopeKind :: DispatchKind,
    envelopeVocabularyExpression :: Text,
    envelopeRestartRequested :: Bool,
    envelopeNormalizedText :: Maybe Text,
    envelopeRetryTarget :: Maybe GenerationTarget,
    envelopePlanCode :: Maybe PlanCode,
    envelopeSenseIdentifier :: Maybe Text
  }
  deriving (Eq, Show)

-- | Decodes a base64-decoded PubSub message body into a
-- `DispatchEnvelope`. Returns `Left` with a human-readable reason when
-- the message is malformed; callers can ack those to avoid an infinite
-- redelivery loop and log the failure reason.
decodeDispatchEnvelope :: LBS.ByteString -> Either String DispatchEnvelope
decodeDispatchEnvelope bytes = do
  value <- maybe (Left "message body is not valid JSON") Right (Aeson.decode bytes)
  case value of
    Aeson.Object obj -> buildEnvelope obj
    _ -> Left "message body must be a JSON object"

buildEnvelope :: KeyMap.KeyMap Aeson.Value -> Either String DispatchEnvelope
buildEnvelope obj = do
  actor <- requireText "actor" obj
  idempotencyKey <- requireText "idempotencyKey" obj
  kindText <- requireText "kind" obj
  kind <- decodeDispatchKind kindText
  vocabularyExpression <- optionalText "vocabularyExpression" obj
  restartRequested <- optionalBool "restartRequested" obj False
  normalizedText <- optionalMaybeText "normalizedText" obj
  retryTargetRaw <- optionalMaybeText "retryTarget" obj
  retryTarget <- traverse decodeGenerationTarget retryTargetRaw
  planCodeRaw <- optionalMaybeText "planCode" obj
  planCode <- traverse decodePlanCode planCodeRaw
  senseIdentifier <- optionalMaybeText "senseIdentifier" obj
  Right
    DispatchEnvelope
      { envelopeActor = actor,
        envelopeIdempotencyKey = idempotencyKey,
        envelopeKind = kind,
        envelopeVocabularyExpression = vocabularyExpression,
        envelopeRestartRequested = restartRequested,
        envelopeNormalizedText = normalizedText,
        envelopeRetryTarget = retryTarget,
        envelopePlanCode = planCode,
        envelopeSenseIdentifier = senseIdentifier
      }

decodeDispatchKind :: Text -> Either String DispatchKind
decodeDispatchKind t = case T.toLower t of
  "explanation-generation" -> Right ExplanationGenerationKind
  "image-generation" -> Right ImageGenerationKind
  "retry" -> Right RetryKind
  "purchase" -> Right PurchaseKind
  "restore-purchase" -> Right RestorePurchaseKind
  other -> Left ("unsupported dispatch kind: " <> T.unpack other)

decodeGenerationTarget :: Text -> Either String GenerationTarget
decodeGenerationTarget t = case T.toUpper t of
  "EXPLANATION" -> Right ExplanationTarget
  "IMAGE" -> Right ImageTarget
  other -> Left ("unsupported retry target: " <> T.unpack other)

decodePlanCode :: Text -> Either String PlanCode
decodePlanCode t = case T.toUpper t of
  "FREE" -> Right FreePlan
  "STANDARD_MONTHLY" -> Right StandardMonthlyPlan
  "PRO_MONTHLY" -> Right ProMonthlyPlan
  other -> Left ("unsupported plan code: " <> T.unpack other)

requireText :: Text -> KeyMap.KeyMap Aeson.Value -> Either String Text
requireText key obj = case KeyMap.lookup (Key.fromText key) obj of
  Just (Aeson.String value) -> Right value
  _ -> Left ("required field missing or not a string: " <> T.unpack key)

optionalText :: Text -> KeyMap.KeyMap Aeson.Value -> Either String Text
optionalText key obj = case KeyMap.lookup (Key.fromText key) obj of
  Just (Aeson.String value) -> Right value
  Nothing -> Right T.empty
  _ -> Left ("field expected to be a string: " <> T.unpack key)

optionalMaybeText :: Text -> KeyMap.KeyMap Aeson.Value -> Either String (Maybe Text)
optionalMaybeText key obj = case KeyMap.lookup (Key.fromText key) obj of
  Just (Aeson.String value) -> Right (Just value)
  Just Aeson.Null -> Right Nothing
  Nothing -> Right Nothing
  _ -> Left ("field expected to be a string: " <> T.unpack key)

optionalBool :: Text -> KeyMap.KeyMap Aeson.Value -> Bool -> Either String Bool
optionalBool key obj defaultValue = case KeyMap.lookup (Key.fromText key) obj of
  Just (Aeson.Bool value) -> Right value
  Just Aeson.Null -> Right defaultValue
  Nothing -> Right defaultValue
  _ -> Left ("field expected to be a boolean: " <> T.unpack key)
