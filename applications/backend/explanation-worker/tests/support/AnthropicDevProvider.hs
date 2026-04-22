{-# LANGUAGE OverloadedStrings #-}

-- |
-- Test-only HTTP fixture that pretends to be the Anthropic Messages
-- API. Used from unit / feature tests to exercise the real
-- `http-conduit` transport path without hitting the live provider.
-- Lives under `tests/support/` so the production binary never links
-- this module — the "no mocks in production" constraint stays intact.
module AnthropicDevProvider
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

-- | Scenarios the dev provider can emulate. Each maps to a different
-- HTTP behaviour so the adapter's failure taxonomy can be asserted.
data DevProviderScenario
  = ScenarioSuccess
  | ScenarioRetryable5xx
  | ScenarioThrottled429
  | ScenarioTerminal400
  | ScenarioMalformedBody
  deriving (Eq, Show)

-- | Binds a free port, spawns the fixture in a worker thread, runs the
-- action with the bound port, and tears down the thread / socket on
-- exit (including exceptions).
withDevProvider :: DevProviderScenario -> (Int -> IO a) -> IO a
withDevProvider scenario action = do
  (port, sock) <- Warp.openFreePort
  readyMVar <- newEmptyMVar
  let settings =
        Warp.setBeforeMainLoop (putMVar readyMVar ()) Warp.defaultSettings
  bracket
    (forkIO (Warp.runSettingsSocket settings sock (application scenario)))
    ( \threadId -> do
        killThread threadId
        Socket.close sock
    )
    ( \_ -> do
        -- Block until warp signals that the accept loop is live.
        takeMVar readyMVar
        action port
    )

application :: DevProviderScenario -> Application
application scenario request respond =
  case pathInfo request of
    ["v1", "messages"] -> respond (messagesResponse scenario)
    _ -> respond (responseLBS status400 [] "unsupported path")

messagesResponse :: DevProviderScenario -> Response
messagesResponse ScenarioSuccess =
  responseLBS status200 [("Content-Type", "application/json")] successBody
messagesResponse ScenarioRetryable5xx =
  responseLBS status500 [] "simulated upstream failure"
messagesResponse ScenarioThrottled429 =
  responseLBS status429 [] "rate limited"
messagesResponse ScenarioTerminal400 =
  responseLBS status400 [] "bad request"
messagesResponse ScenarioMalformedBody =
  responseLBS status200 [("Content-Type", "application/json")] "not json"

successBody :: LBS.ByteString
successBody =
  Aeson.encode $
    Aeson.object
      [ Key.fromText "id" Aeson..= ("msg_test" :: T.Text),
        Key.fromText "content"
          Aeson..= [ Aeson.object
                       [ Key.fromText "type" Aeson..= ("text" :: T.Text),
                         Key.fromText "text" Aeson..= payloadText
                       ]
                   ]
      ]

payloadText :: T.Text
payloadText =
  T.concat
    [ "{",
      "\"summary\":\"Dev fixture explanation\",",
      "\"senses\":[",
      "{\"label\":\"run\",\"nuance\":\"to move quickly\"}",
      "],",
      "\"frequency\":\"OFTEN\",",
      "\"sophistication\":\"VERY_BASIC\",",
      "\"pronunciation\":{\"weak\":\"/run/\",\"strong\":\"/RUN/\"},",
      "\"etymology\":\"Old English rinnan.\",",
      "\"similar_expressions\":[",
      "{\"value\":\"sprint\",\"meaning\":\"run fast\",\"comparison\":\"more intense\"}",
      "]",
      "}"
    ]
