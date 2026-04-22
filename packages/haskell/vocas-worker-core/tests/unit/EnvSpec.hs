{-# LANGUAGE OverloadedStrings #-}

module EnvSpec (run) where

import System.Environment (setEnv, unsetEnv)
import Vocas.Worker.Core.Env
  ( productionAdaptersEnabled,
    productionAdaptersEnv,
    resolveBaseUrl,
    resolveEmulatorHost,
    resolveProjectId,
    firestoreEmulatorHostEnv,
    firebaseProjectEnv,
  )

run :: IO Bool
run = do
  putStrLn "# EnvSpec"
  cases <- sequence [caseProductionAdaptersEnabled, caseResolveProjectId, caseResolveEmulatorHost, caseResolveBaseUrl]
  pure (all id cases)

assertEq :: (Eq a, Show a) => String -> a -> a -> IO Bool
assertEq label expected actual =
  if expected == actual
    then do
      putStrLn ("  ok  " ++ label)
      pure True
    else do
      putStrLn
        ( "  FAIL "
            ++ label
            ++ "\n    expected="
            ++ show expected
            ++ "\n    actual="
            ++ show actual
        )
      pure False

caseProductionAdaptersEnabled :: IO Bool
caseProductionAdaptersEnabled = do
  unsetEnv productionAdaptersEnv
  defaultDisabled <- productionAdaptersEnabled
  setEnv productionAdaptersEnv "true"
  enabledByTrue <- productionAdaptersEnabled
  setEnv productionAdaptersEnv "YES"
  enabledByYes <- productionAdaptersEnabled
  setEnv productionAdaptersEnv "false"
  disabledByFalse <- productionAdaptersEnabled
  unsetEnv productionAdaptersEnv
  results <-
    sequence
      [ assertEq "default disabled" False defaultDisabled,
        assertEq "enabled by true" True enabledByTrue,
        assertEq "enabled by YES" True enabledByYes,
        assertEq "disabled by false" False disabledByFalse
      ]
  pure (all id results)

caseResolveProjectId :: IO Bool
caseResolveProjectId = do
  unsetEnv firebaseProjectEnv
  defaultValue <- resolveProjectId
  setEnv firebaseProjectEnv "custom-project"
  overridden <- resolveProjectId
  unsetEnv firebaseProjectEnv
  results <-
    sequence
      [ assertEq "falls back to demo project" "demo-vocastock" defaultValue,
        assertEq "honours FIREBASE_PROJECT" "custom-project" overridden
      ]
  pure (all id results)

caseResolveEmulatorHost :: IO Bool
caseResolveEmulatorHost = do
  unsetEnv firestoreEmulatorHostEnv
  unsetValue <- resolveEmulatorHost firestoreEmulatorHostEnv
  setEnv firestoreEmulatorHostEnv "127.0.0.1:18080"
  setValue <- resolveEmulatorHost firestoreEmulatorHostEnv
  setEnv firestoreEmulatorHostEnv "   "
  whitespaceValue <- resolveEmulatorHost firestoreEmulatorHostEnv
  unsetEnv firestoreEmulatorHostEnv
  results <-
    sequence
      [ assertEq "unset -> Nothing" Nothing unsetValue,
        assertEq "resolves host:port" (Just "127.0.0.1:18080") setValue,
        assertEq "whitespace-only -> Nothing" Nothing whitespaceValue
      ]
  pure (all id results)

caseResolveBaseUrl :: IO Bool
caseResolveBaseUrl = do
  unsetEnv "TEST_API_BASE_URL"
  fallback <- resolveBaseUrl "TEST_API_BASE_URL" "https://api.example.com"
  setEnv "TEST_API_BASE_URL" "http://127.0.0.1:9000"
  overridden <- resolveBaseUrl "TEST_API_BASE_URL" "https://api.example.com"
  unsetEnv "TEST_API_BASE_URL"
  results <-
    sequence
      [ assertEq "uses default when unset" "https://api.example.com" fallback,
        assertEq "uses override when set" "http://127.0.0.1:9000" overridden
      ]
  pure (all id results)
