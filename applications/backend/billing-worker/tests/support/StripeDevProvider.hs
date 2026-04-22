{-# LANGUAGE OverloadedStrings #-}

-- |
-- Test-only Stripe fixture that covers the two endpoints the
-- billing-worker uses: `POST /v1/subscriptions` and
-- `GET /v1/customers/{id}/subscriptions`.
module StripeDevProvider
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
import Network.Wai (Application, Response, pathInfo, requestMethod, responseLBS)
import qualified Network.Wai.Handler.Warp as Warp

data DevProviderScenario
  = ScenarioSuccess
  | ScenarioRestoreEmpty
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
  case (requestMethod request, pathInfo request) of
    ("POST", ["v1", "subscriptions"]) -> respond (subscriptionCreateResponse scenario)
    ("GET", ["v1", "customers", _customerId, "subscriptions"]) ->
      respond (listSubscriptionsResponse scenario)
    _ -> respond (responseLBS status400 [] "unsupported path")

subscriptionCreateResponse :: DevProviderScenario -> Response
subscriptionCreateResponse ScenarioSuccess =
  responseLBS status200 [("Content-Type", "application/json")] createdSubscriptionBody
subscriptionCreateResponse ScenarioRestoreEmpty =
  -- Restore scenario always hits the GET endpoint, but we fall back
  -- gracefully if a caller mis-routes.
  responseLBS status400 [] "restore-only scenario"
subscriptionCreateResponse ScenarioRetryable5xx =
  responseLBS status500 [] "simulated upstream failure"
subscriptionCreateResponse ScenarioThrottled429 =
  responseLBS status429 [] "rate limited"
subscriptionCreateResponse ScenarioTerminal400 =
  responseLBS status400 [] "card declined"
subscriptionCreateResponse ScenarioMalformedBody =
  responseLBS status200 [("Content-Type", "application/json")] "not json"

listSubscriptionsResponse :: DevProviderScenario -> Response
listSubscriptionsResponse ScenarioRestoreEmpty =
  responseLBS status200 [("Content-Type", "application/json")] emptyListBody
listSubscriptionsResponse ScenarioSuccess =
  responseLBS status200 [("Content-Type", "application/json")] listWithOneBody
listSubscriptionsResponse ScenarioRetryable5xx =
  responseLBS status500 [] "simulated upstream failure"
listSubscriptionsResponse ScenarioThrottled429 =
  responseLBS status429 [] "rate limited"
listSubscriptionsResponse ScenarioTerminal400 =
  responseLBS status400 [] "invalid request"
listSubscriptionsResponse ScenarioMalformedBody =
  responseLBS status200 [("Content-Type", "application/json")] "not json"

createdSubscriptionBody :: LBS.ByteString
createdSubscriptionBody =
  Aeson.encode $
    Aeson.object
      [ Key.fromText "id" Aeson..= ("sub_test_created" :: T.Text),
        Key.fromText "object" Aeson..= ("subscription" :: T.Text),
        Key.fromText "status" Aeson..= ("active" :: T.Text)
      ]

listWithOneBody :: LBS.ByteString
listWithOneBody =
  Aeson.encode $
    Aeson.object
      [ Key.fromText "object" Aeson..= ("list" :: T.Text),
        Key.fromText "data"
          Aeson..= [ Aeson.object
                       [ Key.fromText "id" Aeson..= ("sub_test_existing" :: T.Text),
                         Key.fromText "status" Aeson..= ("active" :: T.Text)
                       ]
                   ]
      ]

emptyListBody :: LBS.ByteString
emptyListBody =
  Aeson.encode $
    Aeson.object
      [ Key.fromText "object" Aeson..= ("list" :: T.Text),
        Key.fromText "data" Aeson..= ([] :: [Aeson.Value])
      ]
