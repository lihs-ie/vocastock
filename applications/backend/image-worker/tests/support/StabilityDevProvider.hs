{-# LANGUAGE OverloadedStrings #-}

-- |
-- Test-only Stability AI text-to-image fixture. Returns a
-- deterministic base64-encoded 1x1 PNG per scenario so the real
-- http-conduit adapter can be exercised without touching the live
-- provider. Only linked into the unit / feature test binaries.
module StabilityDevProvider
  ( DevProviderScenario (..),
    withDevProvider,
  )
where

import Control.Concurrent (forkIO, killThread)
import Control.Concurrent.MVar (newEmptyMVar, putMVar, takeMVar)
import Control.Exception (bracket)
import qualified Data.Aeson as Aeson
import qualified Data.Aeson.Key as Key
import qualified Data.ByteString.Lazy as LBS
import qualified Data.Text as T
import Network.HTTP.Types (status200, status400, status429, status500)
import qualified Network.Socket as Socket
import Network.Wai (Application, Response, pathInfo, responseLBS)
import qualified Network.Wai.Handler.Warp as Warp

data DevProviderScenario
  = ScenarioSuccess
  | ScenarioRetryable5xx
  | ScenarioThrottled429
  | ScenarioTerminal400
  | ScenarioMalformedBody
  deriving (Eq, Show)

withDevProvider :: DevProviderScenario -> (Int -> IO a) -> IO a
withDevProvider scenario action = do
  (port, sock) <- Warp.openFreePort
  readyMVar <- newEmptyMVar
  let settings = Warp.setBeforeMainLoop (putMVar readyMVar ()) Warp.defaultSettings
  bracket
    (forkIO (Warp.runSettingsSocket settings sock (application scenario)))
    ( \threadId -> do
        killThread threadId
        Socket.close sock
    )
    ( \_ -> do
        takeMVar readyMVar
        action port
    )

application :: DevProviderScenario -> Application
application scenario request respond =
  case pathInfo request of
    ["v1", "generation", _engineId, "text-to-image"] ->
      respond (generateResponse scenario)
    _ -> respond (responseLBS status400 [] "unsupported path")

generateResponse :: DevProviderScenario -> Response
generateResponse ScenarioSuccess =
  responseLBS status200 [("Content-Type", "application/json")] successBody
generateResponse ScenarioRetryable5xx =
  responseLBS status500 [] "simulated upstream failure"
generateResponse ScenarioThrottled429 =
  responseLBS status429 [] "rate limited"
generateResponse ScenarioTerminal400 =
  responseLBS status400 [] "bad request"
generateResponse ScenarioMalformedBody =
  responseLBS status200 [("Content-Type", "application/json")] "not json"

successBody :: LBS.ByteString
successBody =
  Aeson.encode $
    Aeson.object
      [ Key.fromText "artifacts"
          Aeson..= [ Aeson.object
                       [ Key.fromText "base64" Aeson..= onePixelBase64,
                         Key.fromText "seed" Aeson..= (42 :: Int),
                         Key.fromText "finishReason" Aeson..= ("SUCCESS" :: T.Text)
                       ]
                   ]
      ]

-- 1x1 transparent PNG, base64-encoded. Small, deterministic, and enough
-- to round-trip through the adapter's base64 decoder.
onePixelBase64 :: T.Text
onePixelBase64 =
  "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg=="
