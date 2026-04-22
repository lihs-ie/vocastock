{-# LANGUAGE OverloadedStrings #-}

-- |
-- Stability AI text-to-image adapter. Accepts a prompt, returns the
-- decoded PNG bytes for a single sample. `STABILITY_API_BASE_URL`
-- overrides the canonical endpoint for feature tests.
module ImageWorker.StabilityAdapter
  ( StabilityConfig (..),
    ImageOutcome (..),
    resolveStabilityConfig,
    generateImage,
  )
where

import qualified Data.Aeson as Aeson
import qualified Data.Aeson.Key as Key
import qualified Data.Aeson.KeyMap as KeyMap
import qualified Data.ByteString as BS
import qualified Data.ByteString.Base64 as Base64
import qualified Data.ByteString.Lazy as LBS
import Data.Foldable (toList)
import qualified Data.Text as T
import Data.Text (Text)
import qualified Data.Text.Encoding as TE
import qualified Network.HTTP.Conduit as Http
import qualified Network.HTTP.Types.Header as Header
import qualified Network.HTTP.Types.Method as Method
import qualified Network.HTTP.Types.Status as Status

import Vocas.Worker.Core.Env (lookupRequiredEnv, resolveBaseUrl)

data StabilityConfig = StabilityConfig
  { stabilityApiKey :: Text,
    stabilityBaseUrl :: Text,
    stabilityEngineId :: Text
  }
  deriving (Show)

data ImageOutcome
  = ImageSucceeded BS.ByteString
  | ImageRetryable String
  | ImageTerminal String
  deriving (Show)

defaultBaseUrl :: String
defaultBaseUrl = "https://api.stability.ai"

defaultEngineId :: Text
defaultEngineId = "stable-diffusion-v1-6"

resolveStabilityConfig :: IO (Either String StabilityConfig)
resolveStabilityConfig = do
  keyResult <- lookupRequiredEnv "STABILITY_API_KEY"
  baseUrl <- resolveBaseUrl "STABILITY_API_BASE_URL" defaultBaseUrl
  case keyResult of
    Left name -> pure (Left ("missing required env var: " <> name))
    Right key ->
      pure
        ( Right
            StabilityConfig
              { stabilityApiKey = T.pack key,
                stabilityBaseUrl = T.pack baseUrl,
                stabilityEngineId = defaultEngineId
              }
        )

generateImage :: StabilityConfig -> Http.Manager -> Text -> Text -> IO ImageOutcome
generateImage config manager prompt correlationId = do
  let url =
        T.unpack (stabilityBaseUrl config)
          <> "/v1/generation/"
          <> T.unpack (stabilityEngineId config)
          <> "/text-to-image"
  initial <- Http.parseRequest url
  let request =
        initial
          { Http.method = Method.methodPost,
            Http.requestHeaders =
              [ (Header.hContentType, "application/json; charset=utf-8"),
                (Header.hAccept, "application/json"),
                (Header.hAuthorization, "Bearer " <> TE.encodeUtf8 (stabilityApiKey config)),
                ("x-request-correlation", TE.encodeUtf8 correlationId)
              ],
            Http.requestBody = Http.RequestBodyLBS (Aeson.encode (buildPrompt prompt))
          }
  response <- Http.httpLbs request manager
  let statusCode = Status.statusCode (Http.responseStatus response)
  let body = Http.responseBody response
  if statusCode >= 200 && statusCode < 300
    then pure (interpretSuccess body)
    else pure (interpretFailure statusCode)

buildPrompt :: Text -> Aeson.Value
buildPrompt prompt =
  Aeson.object
    [ Key.fromText "text_prompts"
        Aeson..= [ Aeson.object
                     [ Key.fromText "text" Aeson..= prompt,
                       Key.fromText "weight" Aeson..= (1 :: Int)
                     ]
                 ],
      Key.fromText "cfg_scale" Aeson..= (7 :: Int),
      Key.fromText "height" Aeson..= (512 :: Int),
      Key.fromText "width" Aeson..= (512 :: Int),
      Key.fromText "samples" Aeson..= (1 :: Int),
      Key.fromText "steps" Aeson..= (30 :: Int)
    ]

interpretSuccess :: LBS.ByteString -> ImageOutcome
interpretSuccess body = case Aeson.decode body of
  Nothing -> ImageTerminal "non-json-response"
  Just (Aeson.Object outer) -> case KeyMap.lookup (Key.fromText "artifacts") outer of
    Just (Aeson.Array artifacts) -> case toList artifacts of
      (Aeson.Object first : _) -> case KeyMap.lookup (Key.fromText "base64") first of
        Just (Aeson.String encoded) ->
          case Base64.decode (TE.encodeUtf8 encoded) of
            Right bytes -> ImageSucceeded bytes
            Left _ -> ImageTerminal "invalid-base64"
        _ -> ImageTerminal "missing-base64"
      _ -> ImageTerminal "empty-artifacts"
    _ -> ImageTerminal "missing-artifacts"
  _ -> ImageTerminal "unexpected-root"

interpretFailure :: Int -> ImageOutcome
interpretFailure statusCode
  | statusCode == 408 || statusCode == 504 =
      ImageRetryable ("provider-timeout:" <> show statusCode)
  | statusCode == 429 || statusCode >= 500 =
      ImageRetryable ("provider-retryable:" <> show statusCode)
  | otherwise = ImageTerminal ("provider-error:" <> show statusCode)
