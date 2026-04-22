{-# LANGUAGE OverloadedStrings #-}

-- |
-- Live-fixture test for `ImageWorker.StabilityAdapter`. Starts the
-- `StabilityDevProvider` warp server inside the test binary and
-- exercises the real http-conduit transport path.
module ImageWorker.StabilityAdapterSpec (run) where

import qualified Data.ByteString as BS
import qualified Data.Text as T
import qualified Network.HTTP.Conduit as Http

import ImageWorker.StabilityAdapter
  ( ImageOutcome (..),
    StabilityConfig (..),
    generateImage,
  )
import StabilityDevProvider (DevProviderScenario (..), withDevProvider)
import TestSupport (assertEqual, assertTrue, runNamed)

run :: IO ()
run = runNamed "ImageWorker.StabilityAdapter (live fixture)" $ do
  caseSuccess
  caseRetryable5xx
  caseThrottled429
  caseTerminal400
  caseMalformed

configFor :: Int -> StabilityConfig
configFor port =
  StabilityConfig
    { stabilityApiKey = "dev-test-key",
      stabilityBaseUrl = T.pack ("http://127.0.0.1:" <> show port),
      stabilityEngineId = "stable-diffusion-v1-6"
    }

invokeAdapter :: Int -> IO ImageOutcome
invokeAdapter port = do
  manager <- Http.newManager Http.tlsManagerSettings
  generateImage (configFor port) manager "illustration of run" "correlation-test"

isSucceeded :: ImageOutcome -> Bool
isSucceeded (ImageSucceeded _) = True
isSucceeded _ = False

caseSuccess :: IO ()
caseSuccess =
  withDevProvider ScenarioSuccess $ \port -> do
    outcome <- invokeAdapter port
    assertTrue "success outcome" (isSucceeded outcome)
    case outcome of
      ImageSucceeded bytes ->
        assertTrue "PNG bytes non-empty" (BS.length bytes > 0)
      _ -> error "expected ImageSucceeded"

caseRetryable5xx :: IO ()
caseRetryable5xx =
  withDevProvider ScenarioRetryable5xx $ \port -> do
    outcome <- invokeAdapter port
    case outcome of
      ImageRetryable reason -> assertTrue "retryable reason" (not (null reason))
      other -> error ("expected ImageRetryable, got " <> show other)

caseThrottled429 :: IO ()
caseThrottled429 =
  withDevProvider ScenarioThrottled429 $ \port -> do
    outcome <- invokeAdapter port
    case outcome of
      ImageRetryable _ -> assertEqual "throttle retryable" True True
      other -> error ("expected ImageRetryable, got " <> show other)

caseTerminal400 :: IO ()
caseTerminal400 =
  withDevProvider ScenarioTerminal400 $ \port -> do
    outcome <- invokeAdapter port
    case outcome of
      ImageTerminal _ -> assertEqual "terminal reason" True True
      other -> error ("expected ImageTerminal, got " <> show other)

caseMalformed :: IO ()
caseMalformed =
  withDevProvider ScenarioMalformedBody $ \port -> do
    outcome <- invokeAdapter port
    case outcome of
      ImageTerminal _ -> assertEqual "malformed terminal" True True
      other -> error ("expected ImageTerminal, got " <> show other)
