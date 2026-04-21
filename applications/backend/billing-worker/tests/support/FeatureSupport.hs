module FeatureSupport
  ( FeatureRuntime,
    ValidationResult,
    assertField,
    runValidation,
    startStableWorker,
    waitForStableWorker,
    withFeatureRuntime,
    workerLogs
  )
where

import Control.Concurrent (threadDelay)
import Control.Exception (bracket)
import Data.Char (toLower)
import Data.IORef (IORef, newIORef, readIORef, writeIORef)
import Data.List (isInfixOf, isPrefixOf)
import qualified Data.Map.Strict as Map
import Data.Time.Clock.POSIX (getPOSIXTime)
import System.Directory
  ( copyFile,
    createDirectoryIfMissing,
    doesFileExist,
    getCurrentDirectory,
    removeFile
  )
import System.Environment (getEnv)
import System.Exit (ExitCode (..))
import System.FilePath ((</>), takeDirectory)
import System.IO.Error (catchIOError)
import System.Process (CreateProcess (cwd), proc, readCreateProcessWithExitCode)
import TestSupport (assertEqual)

constBillingWorkerService :: String
constBillingWorkerService = "billing-worker"

constEmulatorContainerName :: String
constEmulatorContainerName = "vocastock-firebase-emulators"

defaultFirestorePort :: Int
defaultFirestorePort = 18080

defaultStoragePort :: Int
defaultStoragePort = 19199

defaultAuthPort :: Int
defaultAuthPort = 19099

defaultReadyBudgetSeconds :: Int
defaultReadyBudgetSeconds = 30

defaultEmulatorReadyBudgetSeconds :: String
defaultEmulatorReadyBudgetSeconds = "300"

featureReuseEnv :: String
featureReuseEnv = "VOCAS_FEATURE_REUSE_RUNNING"

featureSkipBuildEnv :: String
featureSkipBuildEnv = "VOCAS_FEATURE_SKIP_BUILD"

data FeatureRuntime = FeatureRuntime
  { runtimeRepoRoot :: FilePath,
    runtimeComposeFile :: FilePath,
    runtimeEnvFile :: FilePath,
    runtimeStartedEmulators :: Bool,
    runtimeStartedWorker :: IORef Bool
  }

newtype ValidationResult = ValidationResult
  { validationFields :: Map.Map String String
  }

withFeatureRuntime :: (FeatureRuntime -> IO a) -> IO a
withFeatureRuntime = bracket startRuntime cleanupRuntime

startStableWorker :: FeatureRuntime -> IO ()
startStableWorker runtime = do
  args <- composeArgs runtime ["up", "-d"] >>= withBuildFlag
  runCommandStrict (runtimeRepoRoot runtime) "docker" (args ++ [constBillingWorkerService])
  writeIORef (runtimeStartedWorker runtime) True
  pure ()
  where
    withBuildFlag args = do
      skipBuild <- envFlag featureSkipBuildEnv
      pure $
        if skipBuild
          then args
          else args ++ ["--build"]

waitForStableWorker :: FeatureRuntime -> IO ()
waitForStableWorker runtime = poll defaultReadyBudgetSeconds
  where
    poll remaining = do
      logs <- workerLogs runtime
      if "entered stable-run mode" `isInfixOf` logs
        then pure ()
        else
          if remaining <= 0
            then error "billing-worker did not enter stable-run mode in time"
            else threadDelay 1000000 >> poll (remaining - 1)

workerLogs :: FeatureRuntime -> IO String
workerLogs runtime = do
  args <- composeArgs runtime ["logs", "--no-color", constBillingWorkerService]
  runCommandStrict (runtimeRepoRoot runtime) "docker" args

runValidation :: FeatureRuntime -> String -> IO ValidationResult
runValidation runtime scenario = do
  args <-
    composeArgs
      runtime
      [ "run",
        "--rm",
        "--no-deps",
        "-e",
        "VOCAS_WORKER_RUN_MODE=validate",
        "-e",
        "VOCAS_BILLING_WORKFLOW_SCENARIO=" ++ scenario,
        constBillingWorkerService
      ]
  stdout <- runCommandStrict (runtimeRepoRoot runtime) "docker" args
  pure (parseValidationResult stdout)

assertField :: ValidationResult -> String -> String -> IO ()
assertField (ValidationResult fields) key expected =
  assertEqual ("unexpected value for " ++ key) (Just expected) (Map.lookup key fields)

startRuntime :: IO FeatureRuntime
startRuntime = do
  repoRoot <- findRepoRoot =<< getCurrentDirectory
  let composeFile = repoRoot </> "docker/applications/compose.yaml"
      firebaseEnvPrimary = repoRoot </> "docker/firebase/env/.env"
      firebaseEnvFallback = repoRoot </> "docker/firebase/env/.env.example"
  firebaseEnv <- loadEnvFile =<< resolveEnvFile firebaseEnvPrimary firebaseEnvFallback
  let firestorePort = portFromEnv firebaseEnv "FIREBASE_FIRESTORE_PORT" defaultFirestorePort
      storagePort = portFromEnv firebaseEnv "FIREBASE_STORAGE_PORT" defaultStoragePort
      authPort = portFromEnv firebaseEnv "FIREBASE_AUTH_PORT" defaultAuthPort
  applicationEnvFile <- ensureApplicationEnvFile repoRoot
  envFile <- writeFeatureEnvFile repoRoot applicationEnvFile firestorePort storagePort authPort
  reuseRunning <- shouldReuseRunningEmulators repoRoot
  if reuseRunning
    then pure ()
    else startEmulators repoRoot
  buildWorkerImage repoRoot composeFile envFile
  removeStaleWorkerContainer repoRoot composeFile envFile
  startedWorkerRef <- newIORef False
  pure
    FeatureRuntime
      { runtimeRepoRoot = repoRoot,
        runtimeComposeFile = composeFile,
        runtimeEnvFile = envFile,
        runtimeStartedEmulators = not reuseRunning,
        runtimeStartedWorker = startedWorkerRef
      }

cleanupRuntime :: FeatureRuntime -> IO ()
cleanupRuntime runtime = do
  let repoRoot = runtimeRepoRoot runtime
  startedWorker <- readIORef (runtimeStartedWorker runtime)
  if startedWorker
    then do
      _ <- tryRunCommand repoRoot "docker" =<< composeArgs runtime ["down"]
      pure ()
    else pure ()
  if runtimeStartedEmulators runtime
    then do
      _ <- tryRunCommand repoRoot "bash" [repoRoot </> "scripts/firebase/stop_emulators.sh"]
      pure ()
    else pure ()
  catchIOError (removeFile (runtimeEnvFile runtime)) (\_ -> pure ())

findRepoRoot :: FilePath -> IO FilePath
findRepoRoot current = do
  let marker = current </> "docker/applications/compose.yaml"
      parent = takeDirectory current
  exists <- doesFileExist marker
  if exists
    then pure current
    else
      if parent == current
        then error "repository root with docker/applications/compose.yaml not found"
        else findRepoRoot parent

resolveEnvFile :: FilePath -> FilePath -> IO FilePath
resolveEnvFile primary fallback = do
  primaryExists <- doesFileExist primary
  pure (if primaryExists then primary else fallback)

ensureApplicationEnvFile :: FilePath -> IO FilePath
ensureApplicationEnvFile repoRoot = do
  let envFile = repoRoot </> "docker/applications/env/.env"
      template = repoRoot </> "docker/applications/env/.env.example"
  envExists <- doesFileExist envFile
  if envExists
    then pure envFile
    else copyFile template envFile >> pure envFile

writeFeatureEnvFile :: FilePath -> FilePath -> Int -> Int -> Int -> IO FilePath
writeFeatureEnvFile repoRoot baseEnvFile firestorePort storagePort authPort = do
  let logsDir = repoRoot </> ".artifacts/ci/logs"
  createDirectoryIfMissing True logsDir
  suffix <- uniqueSuffix
  baseContents <- readFile baseEnvFile
  let envFile = logsDir </> ("billing-worker-feature-" ++ suffix ++ ".env")
      contents =
        ensureTrailingNewline baseContents
          ++ "VOCAS_WORKER_STABLE_RUN_SECONDS=1\n"
          ++ "VOCAS_WORKER_POLL_INTERVAL_SECONDS=1\n"
          ++ "FIRESTORE_EMULATOR_HOST=host.docker.internal:"
          ++ show firestorePort
          ++ "\n"
          ++ "STORAGE_EMULATOR_HOST=host.docker.internal:"
          ++ show storagePort
          ++ "\n"
          ++ "FIREBASE_AUTH_EMULATOR_HOST=host.docker.internal:"
          ++ show authPort
          ++ "\n"
  writeFile envFile contents
  pure envFile

uniqueSuffix :: IO String
uniqueSuffix = do
  posix <- getPOSIXTime
  pure (show (round (posix * 1000000) :: Integer))

ensureTrailingNewline :: String -> String
ensureTrailingNewline contents =
  if null contents || last contents == '\n'
    then contents
    else contents ++ "\n"

loadEnvFile :: FilePath -> IO (Map.Map String String)
loadEnvFile path = do
  contents <- readFile path
  pure $
    Map.fromList $
      foldr parseLine [] (lines contents)
  where
    parseLine line acc =
      case trim line of
        [] -> acc
        ('#' : _) -> acc
        trimmed ->
          case break (== '=') trimmed of
            (key, '=' : value) -> (trim key, trim value) : acc
            _ -> acc

portFromEnv :: Map.Map String String -> String -> Int -> Int
portFromEnv envMap key fallback =
  case Map.lookup key envMap >>= readMaybeInt of
    Just value -> value
    Nothing -> fallback

readMaybeInt :: String -> Maybe Int
readMaybeInt value =
  case reads value of
    [(parsed, "")] -> Just parsed
    _ -> Nothing

shouldReuseRunningEmulators :: FilePath -> IO Bool
shouldReuseRunningEmulators repoRoot = do
  reuse <- envFlag featureReuseEnv
  running <- emulatorContainerRunning repoRoot
  pure (reuse || running)

emulatorContainerRunning :: FilePath -> IO Bool
emulatorContainerRunning repoRoot = do
  output <- tryRunCommand repoRoot "docker" ["ps", "--format", "{{.Names}}"]
  pure $
    maybe
      False
      (any (== constEmulatorContainerName) . lines)
      output

startEmulators :: FilePath -> IO ()
startEmulators repoRoot = do
  readyBudget <- maybe defaultEmulatorReadyBudgetSeconds id <$> lookupEnvMaybe "VOCAS_EMULATOR_READY_BUDGET_SECONDS"
  _ <- runCommandStrict repoRoot "bash" [repoRoot </> "scripts/firebase/start_emulators.sh"]
  _ <- runCommandStrict repoRoot "bash" [repoRoot </> "scripts/firebase/smoke_local_stack.sh", readyBudget]
  pure ()

buildWorkerImage :: FilePath -> FilePath -> FilePath -> IO ()
buildWorkerImage repoRoot composeFile envFile = do
  skipBuild <- envFlag featureSkipBuildEnv
  if skipBuild
    then pure ()
    else do
      args <- composeArgs' composeFile envFile ["build", constBillingWorkerService]
      _ <- runCommandStrict repoRoot "docker" args
      pure ()

removeStaleWorkerContainer :: FilePath -> FilePath -> FilePath -> IO ()
removeStaleWorkerContainer repoRoot composeFile envFile = do
  args <- composeArgs' composeFile envFile ["rm", "-sf", constBillingWorkerService]
  _ <- tryRunCommand repoRoot "docker" args
  pure ()

composeArgs :: FeatureRuntime -> [String] -> IO [String]
composeArgs runtime extra =
  composeArgs' (runtimeComposeFile runtime) (runtimeEnvFile runtime) extra

composeArgs' :: FilePath -> FilePath -> [String] -> IO [String]
composeArgs' composeFile envFile extra =
  pure $
    [ "compose",
      "--env-file",
      envFile,
      "-f",
      composeFile
    ]
      ++ extra

runCommandStrict :: FilePath -> String -> [String] -> IO String
runCommandStrict repoRoot program args = do
  (exitCode, stdout, stderr) <- readCreateProcessWithExitCode ((proc program args) {cwd = Just repoRoot}) ""
  case exitCode of
    ExitSuccess -> pure stdout
    ExitFailure _ ->
      error $
        "command failed: "
          ++ unwords (program : args)
          ++ "\nstdout:\n"
          ++ stdout
          ++ "\nstderr:\n"
          ++ stderr

tryRunCommand :: FilePath -> String -> [String] -> IO (Maybe String)
tryRunCommand repoRoot program args = do
  (exitCode, stdout, _) <- readCreateProcessWithExitCode ((proc program args) {cwd = Just repoRoot}) ""
  pure $
    case exitCode of
      ExitSuccess -> Just stdout
      ExitFailure _ -> Nothing

lookupEnvMaybe :: String -> IO (Maybe String)
lookupEnvMaybe key = catchIOError (Just <$> getEnvCompat key) (\_ -> pure Nothing)

getEnvCompat :: String -> IO String
getEnvCompat = getEnv

envFlag :: String -> IO Bool
envFlag key = do
  value <- lookupEnvMaybe key
  pure $
    maybe
      False
      (\raw -> map toLower (trim raw) `elem` ["1", "true", "yes", "on"])
      value

parseValidationResult :: String -> ValidationResult
parseValidationResult stdout =
  case filter ("VOCAS_BILLING_RESULT " `isPrefixOf`) (lines stdout) of
    (line : _) -> ValidationResult (Map.fromList (map parseToken (tail (words line))))
    [] -> error ("missing validation result in output:\n" ++ stdout)
  where
    parseToken token =
      case break (== '=') token of
        (key, '=' : value) -> (key, value)
        _ -> error ("unexpected validation token: " ++ token)

trim :: String -> String
trim = trimRight . trimLeft
  where
    trimLeft = dropWhile (`elem` [' ', '\t'])
    trimRight = reverse . trimLeft . reverse
