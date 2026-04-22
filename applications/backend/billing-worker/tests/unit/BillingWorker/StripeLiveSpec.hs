{-# LANGUAGE OverloadedStrings #-}

-- |
-- Live-fixture test for `BillingWorker.StripePort`. Starts the
-- `StripeDevProvider` warp server and exercises the real http-conduit
-- adapter end-to-end.
module BillingWorker.StripeLiveSpec (run) where

import qualified Data.Text as T
import qualified Network.HTTP.Conduit as Http

import BillingWorker.StripePort
  ( StripeConfig (..),
    StripeOutcome (..),
    createSubscription,
    listActiveSubscriptions,
  )
import StripeDevProvider (DevProviderScenario (..), withDevProvider)
import TestSupport (assertEqual, assertTrue, runNamed)

run :: IO Bool
run = runNamed "BillingWorker.StripePort (live fixture)" $ do
  results <-
    sequence
      [ caseCreateSuccess,
        caseCreateRetryable,
        caseCreateThrottled,
        caseCreateTerminal,
        caseCreateMalformed,
        caseListWithSubscription,
        caseListEmpty
      ]
  pure (all id results)

configFor :: Int -> StripeConfig
configFor port =
  StripeConfig
    { stripeSecretKey = "sk_test_dev",
      stripeBaseUrl = T.pack ("http://127.0.0.1:" <> show port)
    }

invokeCreate :: Int -> IO StripeOutcome
invokeCreate port = do
  manager <- Http.newManager Http.tlsManagerSettings
  createSubscription (configFor port) manager "cus_stub_demo" "price_standard_monthly" "k-create"

invokeList :: Int -> IO StripeOutcome
invokeList port = do
  manager <- Http.newManager Http.tlsManagerSettings
  listActiveSubscriptions (configFor port) manager "cus_stub_demo"

caseCreateSuccess :: IO Bool
caseCreateSuccess = withDevProvider ScenarioSuccess $ \port -> do
  outcome <- invokeCreate port
  case outcome of
    StripeSucceeded subscriptionId ->
      assertEqual "subscription id" "sub_test_created" subscriptionId
    other -> assertTrue ("expected success got " <> show other) False

caseCreateRetryable :: IO Bool
caseCreateRetryable = withDevProvider ScenarioRetryable5xx $ \port -> do
  outcome <- invokeCreate port
  case outcome of
    StripeRetryable _ -> assertTrue "retryable outcome" True
    other -> assertTrue ("expected retryable got " <> show other) False

caseCreateThrottled :: IO Bool
caseCreateThrottled = withDevProvider ScenarioThrottled429 $ \port -> do
  outcome <- invokeCreate port
  case outcome of
    StripeRetryable _ -> assertTrue "throttle as retryable" True
    other -> assertTrue ("expected retryable got " <> show other) False

caseCreateTerminal :: IO Bool
caseCreateTerminal = withDevProvider ScenarioTerminal400 $ \port -> do
  outcome <- invokeCreate port
  case outcome of
    StripeTerminal _ -> assertTrue "terminal outcome" True
    other -> assertTrue ("expected terminal got " <> show other) False

caseCreateMalformed :: IO Bool
caseCreateMalformed = withDevProvider ScenarioMalformedBody $ \port -> do
  outcome <- invokeCreate port
  case outcome of
    StripeTerminal _ -> assertTrue "malformed body terminal" True
    other -> assertTrue ("expected terminal got " <> show other) False

caseListWithSubscription :: IO Bool
caseListWithSubscription = withDevProvider ScenarioSuccess $ \port -> do
  outcome <- invokeList port
  case outcome of
    StripeSucceeded subscriptionId ->
      assertEqual "existing subscription id" "sub_test_existing" subscriptionId
    other -> assertTrue ("expected existing sub got " <> show other) False

caseListEmpty :: IO Bool
caseListEmpty = withDevProvider ScenarioRestoreEmpty $ \port -> do
  outcome <- invokeList port
  case outcome of
    StripeTerminal _ -> assertTrue "empty list terminal" True
    other -> assertTrue ("expected terminal got " <> show other) False
