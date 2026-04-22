{-# LANGUAGE OverloadedStrings #-}

-- |
-- Stripe REST API adapter. Uses Bearer auth with `STRIPE_SECRET_KEY`,
-- `STRIPE_API_BASE_URL` override for feature tests. Only two
-- interactions are needed for the initial slice:
--
-- * `createSubscription` : POST `/v1/subscriptions` for purchase jobs
-- * `listActiveSubscriptions` : GET `/v1/customers/{id}/subscriptions`
--   for restore jobs
module BillingWorker.StripePort
  ( StripeConfig (..),
    StripeOutcome (..),
    resolveStripeConfig,
    createSubscription,
    listActiveSubscriptions,
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

import Vocas.Worker.Core.Env (lookupRequiredEnv, resolveBaseUrl)

data StripeConfig = StripeConfig
  { stripeSecretKey :: Text,
    stripeBaseUrl :: Text
  }
  deriving (Show)

data StripeOutcome
  = StripeSucceeded Text
  | StripeRetryable String
  | StripeTerminal String
  deriving (Show, Eq)

defaultBaseUrl :: String
defaultBaseUrl = "https://api.stripe.com"

resolveStripeConfig :: IO (Either String StripeConfig)
resolveStripeConfig = do
  keyResult <- lookupRequiredEnv "STRIPE_SECRET_KEY"
  baseUrl <- resolveBaseUrl "STRIPE_API_BASE_URL" defaultBaseUrl
  case keyResult of
    Left name -> pure (Left ("missing required env var: " <> name))
    Right key ->
      pure
        ( Right
            StripeConfig
              { stripeSecretKey = T.pack key,
                stripeBaseUrl = T.pack baseUrl
              }
        )

createSubscription ::
  StripeConfig ->
  Http.Manager ->
  -- | customer id
  Text ->
  -- | Stripe price id (e.g. `price_standard_monthly`)
  Text ->
  -- | request correlation id / idempotency key
  Text ->
  IO StripeOutcome
createSubscription config manager customerId priceId idempotencyKey = do
  let url = T.unpack (stripeBaseUrl config) <> "/v1/subscriptions"
  initial <- Http.parseRequest url
  let formBody =
        TE.encodeUtf8 $
          T.concat
            [ "customer=",
              customerId,
              "&items[0][price]=",
              priceId
            ]
  let request =
        initial
          { Http.method = Method.methodPost,
            Http.requestHeaders =
              [ (Header.hContentType, "application/x-www-form-urlencoded"),
                (Header.hAccept, "application/json"),
                (Header.hAuthorization, "Bearer " <> TE.encodeUtf8 (stripeSecretKey config)),
                ("Idempotency-Key", TE.encodeUtf8 idempotencyKey)
              ],
            Http.requestBody = Http.RequestBodyBS formBody
          }
  response <- Http.httpLbs request manager
  let statusCode = Status.statusCode (Http.responseStatus response)
  let body = Http.responseBody response
  if statusCode >= 200 && statusCode < 300
    then pure (extractSubscriptionId body)
    else pure (interpretFailure statusCode)

listActiveSubscriptions ::
  StripeConfig ->
  Http.Manager ->
  Text ->
  IO StripeOutcome
listActiveSubscriptions config manager customerId = do
  let url =
        T.unpack (stripeBaseUrl config)
          <> "/v1/customers/"
          <> T.unpack customerId
          <> "/subscriptions"
  initial <- Http.parseRequest url
  let request =
        initial
          { Http.method = Method.methodGet,
            Http.requestHeaders =
              [ (Header.hAccept, "application/json"),
                (Header.hAuthorization, "Bearer " <> TE.encodeUtf8 (stripeSecretKey config))
              ]
          }
  response <- Http.httpLbs request manager
  let statusCode = Status.statusCode (Http.responseStatus response)
  let body = Http.responseBody response
  if statusCode >= 200 && statusCode < 300
    then pure (extractFirstActiveSubscriptionId body)
    else pure (interpretFailure statusCode)

extractSubscriptionId :: LBS.ByteString -> StripeOutcome
extractSubscriptionId body = case Aeson.decode body of
  Just (Aeson.Object outer) -> case KeyMap.lookup (Key.fromText "id") outer of
    Just (Aeson.String value) -> StripeSucceeded value
    _ -> StripeTerminal "stripe-response-missing-id"
  _ -> StripeTerminal "stripe-response-not-json"

extractFirstActiveSubscriptionId :: LBS.ByteString -> StripeOutcome
extractFirstActiveSubscriptionId body = case Aeson.decode body of
  Just (Aeson.Object outer) -> case KeyMap.lookup (Key.fromText "data") outer of
    Just (Aeson.Array entries) -> case toList entries of
      (first : _) -> case first of
        Aeson.Object obj -> case KeyMap.lookup (Key.fromText "id") obj of
          Just (Aeson.String value) -> StripeSucceeded value
          _ -> StripeTerminal "stripe-restore-missing-id"
        _ -> StripeTerminal "stripe-restore-entry-not-object"
      [] -> StripeTerminal "stripe-restore-empty-list"
    _ -> StripeTerminal "stripe-restore-missing-data"
  _ -> StripeTerminal "stripe-restore-response-not-json"

interpretFailure :: Int -> StripeOutcome
interpretFailure statusCode
  | statusCode == 408 || statusCode == 504 =
      StripeRetryable ("stripe-timeout:" <> show statusCode)
  | statusCode == 429 || statusCode >= 500 =
      StripeRetryable ("stripe-retryable:" <> show statusCode)
  | otherwise = StripeTerminal ("stripe-error:" <> show statusCode)

_reservedBs :: BS.ByteString
_reservedBs = BS8.empty
