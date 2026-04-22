module Main (main) where

import BillingWorker.PullLoop (runPullLoop)
import BillingWorker.WorkerRuntime
  ( WorkerScenario,
    parseWorkerScenarioLabel,
    renderScenarioReport,
    runScenarioReport
  )
import Control.Concurrent (threadDelay)
import Control.Monad (forever)
import Data.Char (toLower)
import System.Environment (lookupEnv)
import System.IO
  ( BufferMode (LineBuffering),
    hSetBuffering,
    stderr,
    stdout
  )

data WorkerMode
  = StableRunMode
  | ValidateMode

data WorkerConfig = WorkerConfig
  { workerName :: String,
    workerMode :: WorkerMode,
    workerStableRunSeconds :: Int,
    workerPollIntervalSeconds :: Int,
    workerScenario :: Maybe WorkerScenario
  }

main :: IO ()
main = do
  hSetBuffering stdout LineBuffering
  hSetBuffering stderr LineBuffering
  loadWorkerConfigFromEnvironment >>= workerMain

loadWorkerConfigFromEnvironment :: IO WorkerConfig
loadWorkerConfigFromEnvironment = do
  workerNameValue <- lookupOrDefault "VOCAS_WORKER_NAME" "billing-worker"
  workerModeValue <- lookupOrDefault "VOCAS_WORKER_RUN_MODE" "stable"
  stableRunEnv <- lookupEnv "VOCAS_WORKER_STABLE_RUN_SECONDS"
  pollIntervalEnv <- lookupEnv "VOCAS_WORKER_POLL_INTERVAL_SECONDS"
  scenarioValue <- lookupEnv "VOCAS_BILLING_WORKFLOW_SCENARIO"
  pure
    WorkerConfig
      { workerName = workerNameValue,
        workerMode = parseWorkerMode workerModeValue,
        workerStableRunSeconds = readIntOrDefault stableRunEnv 10,
        workerPollIntervalSeconds = readIntOrDefault pollIntervalEnv 30,
        workerScenario = scenarioValue >>= parseWorkerScenarioLabel
      }

workerMain :: WorkerConfig -> IO ()
workerMain workerConfig = do
  maybePrintScenario workerConfig
  case workerMode workerConfig of
    ValidateMode -> pure ()
    StableRunMode -> do
      productionMode <- resolveProductionMode
      if productionMode
        then runPullLoop
        else stableRunFallback workerConfig

stableRunFallback :: WorkerConfig -> IO ()
stableRunFallback workerConfig = do
  threadDelay (workerStableRunSeconds workerConfig * 1000000)
  putStrLn $
    "[vocastock] " ++ workerName workerConfig ++ " entered stable-run mode"
  forever $ do
    putStrLn $
      "[vocastock] " ++ workerName workerConfig ++ " awaiting queue/subscription work"
    threadDelay (workerPollIntervalSeconds workerConfig * 1000000)

resolveProductionMode :: IO Bool
resolveProductionMode = do
  raw <- lookupEnv "VOCAS_PRODUCTION_ADAPTERS"
  pure $ case fmap (map toLower) raw of
    Just "true" -> True
    Just "1" -> True
    Just "yes" -> True
    _ -> False

lookupOrDefault :: String -> String -> IO String
lookupOrDefault key defaultValue = do
  value <- lookupEnv key
  pure (maybe defaultValue id value)

readIntOrDefault :: Maybe String -> Int -> Int
readIntOrDefault maybeValue defaultValue =
  case maybeValue >>= readMaybeInt of
    Just parsed -> parsed
    Nothing -> defaultValue

readMaybeInt :: String -> Maybe Int
readMaybeInt value =
  case reads value of
    [(parsed, "")] -> Just parsed
    _ -> Nothing

parseWorkerMode :: String -> WorkerMode
parseWorkerMode workerModeValue =
  case workerModeValue of
    "validate" -> ValidateMode
    _ -> StableRunMode

maybePrintScenario :: WorkerConfig -> IO ()
maybePrintScenario workerConfig =
  case workerScenario workerConfig of
    Nothing -> pure ()
    Just scenario -> putStrLn (renderScenarioReport (runScenarioReport scenario))
