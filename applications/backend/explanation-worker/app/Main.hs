module Main (main) where

import ExplanationWorker.WorkerRuntime
  ( WorkerScenario,
    parseWorkerScenarioLabel,
    renderScenarioReport,
    runScenarioReport
  )
import Control.Concurrent (threadDelay)
import Control.Monad (forever)
import System.Environment (lookupEnv)
import System.IO
  ( BufferMode (LineBuffering),
    hSetBuffering,
    stderr,
    stdout
  )

import ExplanationWorker.RuntimeHttp
  ( internalHttpEnabled,
    internalHttpPort,
    startInternalRuntimeServer
  )

data WorkerMode
  = StableRunMode
  | ValidateMode

data WorkerConfig = WorkerConfig
  { workerName :: String,
    workerMode :: WorkerMode,
    workerStableRunSeconds :: Int,
    workerPollIntervalSeconds :: Int,
    workerScenario :: Maybe WorkerScenario,
    workerInternalHttpEnabled :: Bool,
    workerInternalHttpPort :: Int
  }

main :: IO ()
main = do
  hSetBuffering stdout LineBuffering
  hSetBuffering stderr LineBuffering
  loadWorkerConfigFromEnvironment >>= workerMain

loadWorkerConfigFromEnvironment :: IO WorkerConfig
loadWorkerConfigFromEnvironment = do
  workerNameValue <- lookupOrDefault "VOCAS_WORKER_NAME" "explanation-worker"
  workerModeValue <- lookupOrDefault "VOCAS_WORKER_RUN_MODE" "stable"
  stableRunEnv <- lookupEnv "VOCAS_WORKER_STABLE_RUN_SECONDS"
  pollIntervalEnv <- lookupEnv "VOCAS_WORKER_POLL_INTERVAL_SECONDS"
  scenarioValue <- lookupEnv "VOCAS_EXPLANATION_WORKFLOW_SCENARIO"
  internalHttpEnabledValue <- lookupEnv "VOCAS_INTERNAL_HTTP_ENABLED"
  internalHttpPortValue <- lookupEnv "VOCAS_INTERNAL_HTTP_PORT"
  pure
    WorkerConfig
      { workerName = workerNameValue,
        workerMode = parseWorkerMode workerModeValue,
        workerStableRunSeconds = readIntOrDefault stableRunEnv 10,
        workerPollIntervalSeconds = readIntOrDefault pollIntervalEnv 30,
        workerScenario = scenarioValue >>= parseScenario,
        workerInternalHttpEnabled = internalHttpEnabled internalHttpEnabledValue,
        workerInternalHttpPort = internalHttpPort internalHttpPortValue
      }

workerMain :: WorkerConfig -> IO ()
workerMain workerConfig = do
  maybeStartInternalHttp workerConfig
  maybePrintScenario workerConfig
  case workerMode workerConfig of
    ValidateMode -> pure ()
    StableRunMode -> do
      threadDelay (workerStableRunSeconds workerConfig * 1000000)
      putStrLn $
        "[vocastock] " ++ workerName workerConfig ++ " entered stable-run mode"
      forever $ do
        putStrLn $
          "[vocastock] " ++ workerName workerConfig ++ " awaiting queue/subscription work"
        threadDelay (workerPollIntervalSeconds workerConfig * 1000000)

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

parseScenario :: String -> Maybe WorkerScenario
parseScenario = parseWorkerScenarioLabel

maybePrintScenario :: WorkerConfig -> IO ()
maybePrintScenario workerConfig =
  case workerScenario workerConfig of
    Nothing -> pure ()
    Just scenario -> putStrLn (renderScenarioReport (runScenarioReport scenario))

maybeStartInternalHttp :: WorkerConfig -> IO ()
maybeStartInternalHttp workerConfig =
  if workerInternalHttpEnabled workerConfig
    then do
      _ <- startInternalRuntimeServer (workerName workerConfig) (workerInternalHttpPort workerConfig)
      pure ()
    else pure ()
