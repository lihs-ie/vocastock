{-# LANGUAGE OverloadedStrings #-}

-- |
-- Anthropic Messages API adapter. Real REST call against
-- `https://api.anthropic.com/v1/messages` (or the
-- `ANTHROPIC_API_BASE_URL` override for feature tests that stand up a
-- fixture server). The adapter maps HTTP status / transport errors
-- into the worker-facing `GenerationOutcome` types.
module ExplanationWorker.AnthropicAdapter
  ( AnthropicConfig (..),
    resolveAnthropicConfig,
    generateExplanation,
  )
where

import qualified Data.Aeson as Aeson
import qualified Data.Aeson.Key as Key
import qualified Data.Aeson.KeyMap as KeyMap
import qualified Data.ByteString as BS
import qualified Data.ByteString.Char8 as BS8
import qualified Data.ByteString.Lazy as LBS
import Data.Foldable (toList)
import qualified Data.Text as T
import Data.Text (Text)
import qualified Data.Text.Encoding as TE
import qualified Network.HTTP.Conduit as Http
import qualified Network.HTTP.Types.Header as Header
import qualified Network.HTTP.Types.Method as Method
import qualified Network.HTTP.Types.Status as Status

import ExplanationWorker.GenerationPort
  ( CompletedExplanationPayload (..),
    GenerationOutcome (..),
    GenerationStatus (..),
  )
import Vocas.Worker.Core.Env (lookupRequiredEnv, resolveBaseUrl)

data AnthropicConfig = AnthropicConfig
  { anthropicApiKey :: Text,
    anthropicBaseUrl :: Text,
    anthropicModel :: Text
  }
  deriving (Show)

defaultBaseUrl :: String
defaultBaseUrl = "https://api.anthropic.com"

defaultModel :: Text
defaultModel = "claude-sonnet-4-6"

-- | Resolves the adapter from environment variables. Returns `Left`
-- when `ANTHROPIC_API_KEY` is missing so the caller can reject the job
-- up front (we do not want to silently fall back to a mock).
resolveAnthropicConfig :: IO (Either String AnthropicConfig)
resolveAnthropicConfig = do
  keyResult <- lookupRequiredEnv "ANTHROPIC_API_KEY"
  baseUrl <- resolveBaseUrl "ANTHROPIC_API_BASE_URL" defaultBaseUrl
  case keyResult of
    Left name -> pure (Left ("missing required env var: " <> name))
    Right key ->
      pure
        ( Right
            AnthropicConfig
              { anthropicApiKey = T.pack key,
                anthropicBaseUrl = T.pack baseUrl,
                anthropicModel = defaultModel
              }
        )

-- | POSTs to `/v1/messages` and parses the first content block as an
-- `ExplanationPayload` JSON object (the system prompt asks Claude to
-- emit strict JSON). Non-2xx / malformed replies are mapped to the
-- worker's failure taxonomy.
generateExplanation ::
  AnthropicConfig ->
  Http.Manager ->
  -- | normalized vocabulary text to explain
  Text ->
  -- | request correlation id for logging
  Text ->
  IO GenerationOutcome
generateExplanation config manager normalizedText correlationId = do
  let url =
        T.unpack (anthropicBaseUrl config)
          <> "/v1/messages"
  initial <- Http.parseRequest url
  let request =
        initial
          { Http.method = Method.methodPost,
            Http.requestHeaders =
              [ (Header.hContentType, "application/json; charset=utf-8"),
                (Header.hAccept, "application/json"),
                ("x-api-key", TE.encodeUtf8 (anthropicApiKey config)),
                ("anthropic-version", "2023-06-01"),
                ("x-request-correlation", TE.encodeUtf8 correlationId)
              ],
            Http.requestBody = Http.RequestBodyLBS (Aeson.encode (buildPrompt config normalizedText))
          }
  response <- Http.httpLbs request manager
  let statusCode = Status.statusCode (Http.responseStatus response)
  let body = Http.responseBody response
  if statusCode >= 200 && statusCode < 300
    then pure (interpretSuccess correlationId body)
    else pure (interpretFailure correlationId statusCode)

buildPrompt :: AnthropicConfig -> Text -> Aeson.Value
buildPrompt config normalizedText =
  Aeson.object
    [ Key.fromText "model" Aeson..= anthropicModel config,
      Key.fromText "max_tokens" Aeson..= (1024 :: Int),
      Key.fromText "system"
        Aeson..= ( "You are generating a vocabulary explanation for a Japanese learner. "
                     <> "Respond with strict JSON only, matching the schema: "
                     <> "{\"summary\":string, \"senses\":[{\"label\":string,\"nuance\":string}], "
                     <> "\"frequency\":\"OFTEN|SOMETIMES|RARELY|HARDLY_EVER\", "
                     <> "\"sophistication\":\"VERY_BASIC|BASIC|INTERMEDIATE|ADVANCED\", "
                     <> "\"pronunciation\":{\"weak\":string,\"strong\":string}, "
                     <> "\"etymology\":string, "
                     <> "\"similar_expressions\":[{\"value\":string,\"meaning\":string,\"comparison\":string}] }."
                     :: Text
                 ),
      Key.fromText "messages"
        Aeson..= [ Aeson.object
                     [ Key.fromText "role" Aeson..= ("user" :: Text),
                       Key.fromText "content"
                         Aeson..= ("Generate explanation for \"" <> normalizedText <> "\".")
                     ]
                 ]
    ]

interpretSuccess :: Text -> LBS.ByteString -> GenerationOutcome
interpretSuccess correlationId body =
  case Aeson.decode body of
    Nothing ->
      malformed correlationId "non-json-response"
    Just (Aeson.Object outer) ->
      case extractContentText outer of
        Nothing -> malformed correlationId "missing-content-text"
        Just contentText ->
          case Aeson.decode (LBS.fromStrict (TE.encodeUtf8 contentText)) of
            Just (Aeson.Object payloadObj) ->
              case mapPayload payloadObj of
                Nothing -> malformed correlationId "missing-required-field"
                Just payload ->
                  GenerationOutcome
                    { outcomeRequestIdentifier = T.unpack correlationId,
                      outcomeStatus = GenerationSucceeded,
                      outcomePayload = Just payload,
                      outcomeFailureReason = Nothing
                    }
            _ -> malformed correlationId "content-not-json"
    _ -> malformed correlationId "unexpected-root"

extractContentText :: KeyMap.KeyMap Aeson.Value -> Maybe Text
extractContentText obj = case KeyMap.lookup (Key.fromText "content") obj of
  Just (Aeson.Array entries) ->
    case toList entries of
      (Aeson.Object first : _) -> case KeyMap.lookup (Key.fromText "text") first of
        Just (Aeson.String value) -> Just value
        _ -> Nothing
      _ -> Nothing
  _ -> Nothing

mapPayload :: KeyMap.KeyMap Aeson.Value -> Maybe CompletedExplanationPayload
mapPayload obj = do
  summary <- takeString obj "summary"
  senses <- takeArray obj "senses"
  let senseCount = length senses
  let hasFrequency = isPresent obj "frequency"
  let hasSophistication = isPresent obj "sophistication"
  let hasPronunciation = isPresent obj "pronunciation"
  let hasEtymology = isPresent obj "etymology"
  let hasSimilar = isPresent obj "similar_expressions"
  pure
    CompletedExplanationPayload
      { payloadSummary = T.unpack summary,
        payloadSenseCount = senseCount,
        payloadHasFrequency = hasFrequency,
        payloadHasSophistication = hasSophistication,
        payloadHasPronunciation = hasPronunciation,
        payloadHasEtymology = hasEtymology,
        payloadHasSimilarExpression = hasSimilar
      }

takeString :: KeyMap.KeyMap Aeson.Value -> Text -> Maybe Text
takeString obj key = case KeyMap.lookup (Key.fromText key) obj of
  Just (Aeson.String value) -> Just value
  _ -> Nothing

takeArray :: KeyMap.KeyMap Aeson.Value -> Text -> Maybe [Aeson.Value]
takeArray obj key = case KeyMap.lookup (Key.fromText key) obj of
  Just (Aeson.Array values) -> Just (toList values)
  _ -> Nothing

isPresent :: KeyMap.KeyMap Aeson.Value -> Text -> Bool
isPresent obj key = case KeyMap.lookup (Key.fromText key) obj of
  Just Aeson.Null -> False
  Just _ -> True
  Nothing -> False

malformed :: Text -> String -> GenerationOutcome
malformed correlationId reason =
  GenerationOutcome
    { outcomeRequestIdentifier = T.unpack correlationId,
      outcomeStatus = GenerationSucceeded,
      outcomePayload = Nothing,
      outcomeFailureReason = Just reason
    }

interpretFailure :: Text -> Int -> GenerationOutcome
interpretFailure correlationId statusCode
  | statusCode == 408 || statusCode == 504 =
      GenerationOutcome
        { outcomeRequestIdentifier = T.unpack correlationId,
          outcomeStatus = GenerationTimedOut,
          outcomePayload = Nothing,
          outcomeFailureReason = Just "provider-timeout"
        }
  | statusCode == 429 || statusCode >= 500 =
      GenerationOutcome
        { outcomeRequestIdentifier = T.unpack correlationId,
          outcomeStatus = GenerationRetryableFailure,
          outcomePayload = Nothing,
          outcomeFailureReason = Just ("provider-retryable:" <> show statusCode)
        }
  | otherwise =
      GenerationOutcome
        { outcomeRequestIdentifier = T.unpack correlationId,
          outcomeStatus = GenerationNonRetryableFailure,
          outcomePayload = Nothing,
          outcomeFailureReason = Just ("provider-error:" <> show statusCode)
        }

_reservedBs :: BS.ByteString
_reservedBs = BS8.empty
