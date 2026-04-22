{-# LANGUAGE OverloadedStrings #-}

-- |
-- Production pull loop for the billing-worker: PubSub pull -> Stripe
-- REST call -> Firestore subscription update -> ack.
module BillingWorker.PullLoop
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

import BillingWorker.StripePort
  ( StripeConfig,
    StripeOutcome (..),
    createSubscription,
    listActiveSubscriptions,
    resolveStripeConfig,
  )
import BillingWorker.SubscriptionPersistence (writeSubscriptionState)
import BillingWorker.BillingJob
  ( Plan (..),
    planCodeText,
    planForCode,
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

defaultSubscription :: Text
defaultSubscription = "billing.purchase-jobs.sub"

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
  stripeResult <- resolveStripeConfig
  stripe <- case stripeResult of
    Right cfg -> pure cfg
    Left reason -> die reason
  subscription <-
    fmap
      (T.pack . fromMaybe (T.unpack defaultSubscription))
      (lookupEnv "VOCAS_BILLING_SUBSCRIPTION")
  manager <- Http.newManager Http.tlsManagerSettings
  putStrLn
    ( "[vocastock] billing-worker pull loop started on subscription="
        <> T.unpack subscription
    )
  forever (tick pubsub firestore stripe manager subscription)

tick ::
  PubSubClient ->
  FirestoreClient ->
  StripeConfig ->
  Http.Manager ->
  Text ->
  IO ()
tick pubsub firestore stripe manager subscription = do
  messages <- pullMessages pubsub subscription 10
  forM_ messages $ \msg -> do
    outcome <- processMessage firestore stripe manager msg
    case outcome of
      Right () -> acknowledge pubsub subscription [receivedAckId msg]
      Left (True, reason) ->
        hPutStrLn stderr ("[vocastock] billing-worker retryable failure: " <> reason)
      Left (False, reason) -> do
        hPutStrLn stderr ("[vocastock] billing-worker terminal failure: " <> reason)
        acknowledge pubsub subscription [receivedAckId msg]
  threadDelay (5 * 1_000_000)

processMessage ::
  FirestoreClient ->
  StripeConfig ->
  Http.Manager ->
  ReceivedMessage ->
  IO (Either (Bool, String) ())
processMessage firestore stripe manager msg =
  case decodeDispatchEnvelope (receivedData msg) of
    Left reason -> pure (Left (False, "envelope-decode-failed: " <> reason))
    Right envelope -> case envelopeKind envelope of
      PurchaseKind -> runPurchase firestore stripe manager envelope
      RestorePurchaseKind -> runRestore firestore stripe manager envelope
      _ -> pure (Left (False, "unsupported kind for billing-worker"))

runPurchase ::
  FirestoreClient ->
  StripeConfig ->
  Http.Manager ->
  DispatchEnvelope ->
  IO (Either (Bool, String) ())
runPurchase firestore stripe manager envelope = do
  let actor = envelopeActor envelope
  let idempotency = envelopeIdempotencyKey envelope
  let plan = maybe PlanFree planForCode (envelopePlanCode envelope)
  customerId <- resolveStripeCustomerId actor
  let priceId = priceIdForPlan plan
  outcome <- createSubscription stripe manager customerId priceId idempotency
  case outcome of
    StripeRetryable reason -> pure (Left (True, reason))
    StripeTerminal reason -> pure (Left (False, reason))
    StripeSucceeded _subscriptionId -> do
      writeResult <- writeSubscriptionState firestore actor plan
      case writeResult of
        Left err -> pure (Left (True, "firestore-write-failed: " <> show err))
        Right () -> pure (Right ())

runRestore ::
  FirestoreClient ->
  StripeConfig ->
  Http.Manager ->
  DispatchEnvelope ->
  IO (Either (Bool, String) ())
runRestore firestore stripe manager envelope = do
  let actor = envelopeActor envelope
  customerId <- resolveStripeCustomerId actor
  outcome <- listActiveSubscriptions stripe manager customerId
  case outcome of
    StripeRetryable reason -> pure (Left (True, reason))
    StripeTerminal reason -> pure (Left (False, reason))
    StripeSucceeded _ -> do
      -- Restore re-asserts the current allowance. Without additional
      -- metadata we default to STANDARD_MONTHLY; Phase E will thread
      -- the real plan back from Stripe.
      writeResult <- writeSubscriptionState firestore actor PlanStandardMonthly
      case writeResult of
        Left err -> pure (Left (True, "firestore-write-failed: " <> show err))
        Right () -> pure (Right ())

-- | Placeholder until actor->customer linkage is persisted. Allows
-- feature tests to map via `VOCAS_BILLING_STRIPE_CUSTOMER` env.
resolveStripeCustomerId :: Text -> IO Text
resolveStripeCustomerId actor = do
  override <- lookupEnv "VOCAS_BILLING_STRIPE_CUSTOMER"
  pure (maybe ("cus_" <> actor) T.pack override)

priceIdForPlan :: Plan -> Text
priceIdForPlan PlanFree = "price_free"
priceIdForPlan PlanStandardMonthly = "price_standard_monthly"
priceIdForPlan PlanProMonthly = "price_pro_monthly"

die :: String -> IO a
die reason = do
  hPutStrLn stderr ("[vocastock] billing-worker cannot start: " <> reason)
  error reason

-- keep `planCodeText` reachable for quick debugging
_reservedPlanText :: Text
_reservedPlanText = planCodeText PlanFree
