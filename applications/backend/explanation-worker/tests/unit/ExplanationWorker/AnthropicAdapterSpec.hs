{-# LANGUAGE OverloadedStrings #-}

-- |
-- Integration-style unit test: starts `AnthropicDevProvider` on a free
-- port and exercises the real `http-conduit` adapter end-to-end. No
-- mocks are involved — the fixture is a live HTTP server inside the
-- test binary.
module ExplanationWorker.AnthropicAdapterSpec (run) where

import qualified Data.Text as T
import qualified Network.HTTP.Conduit as Http

import AnthropicDevProvider (DevProviderScenario (..), withDevProvider)
import ExplanationWorker.AnthropicAdapter
  ( AnthropicConfig (..),
    generateExplanation,
  )
import ExplanationWorker.GenerationPort
  ( CompletedExplanationPayload (..),
    GenerationOutcome (..),
    GenerationStatus (..),
  )
import TestSupport (assertEqual, assertTrue, runNamed)

run :: IO ()
run = runNamed "ExplanationWorker.AnthropicAdapter (live fixture)" $ do
  caseSuccess
  caseRetryable5xx
  caseThrottled429
  caseTerminal400
  caseMalformed

configFor :: Int -> AnthropicConfig
configFor port =
  AnthropicConfig
    { anthropicApiKey = "dev-test-key",
      anthropicBaseUrl = T.pack ("http://127.0.0.1:" <> show port),
      anthropicModel = "claude-sonnet-4-6"
    }

invokeAdapter :: Int -> IO GenerationOutcome
invokeAdapter port = do
  manager <- Http.newManager Http.tlsManagerSettings
  generateExplanation (configFor port) manager "run" "correlation-test"

caseSuccess :: IO ()
caseSuccess =
  withDevProvider ScenarioSuccess $ \port -> do
    outcome <- invokeAdapter port
    assertEqual "success status" GenerationSucceeded (outcomeStatus outcome)
    case outcomePayload outcome of
      Just payload -> do
        assertEqual "sense count" 1 (payloadSenseCount payload)
        assertTrue "has frequency" (payloadHasFrequency payload)
        assertTrue "has sophistication" (payloadHasSophistication payload)
      Nothing -> error "success case expected payload"

caseRetryable5xx :: IO ()
caseRetryable5xx =
  withDevProvider ScenarioRetryable5xx $ \port -> do
    outcome <- invokeAdapter port
    assertEqual "retryable status" GenerationRetryableFailure (outcomeStatus outcome)

caseThrottled429 :: IO ()
caseThrottled429 =
  withDevProvider ScenarioThrottled429 $ \port -> do
    outcome <- invokeAdapter port
    assertEqual
      "throttle mapped to retryable"
      GenerationRetryableFailure
      (outcomeStatus outcome)

caseTerminal400 :: IO ()
caseTerminal400 =
  withDevProvider ScenarioTerminal400 $ \port -> do
    outcome <- invokeAdapter port
    assertEqual "terminal status" GenerationNonRetryableFailure (outcomeStatus outcome)

caseMalformed :: IO ()
caseMalformed =
  withDevProvider ScenarioMalformedBody $ \port -> do
    outcome <- invokeAdapter port
    assertEqual "malformed status keeps succeeded" GenerationSucceeded (outcomeStatus outcome)
    assertEqual "malformed payload is Nothing" Nothing (outcomePayload outcome)
