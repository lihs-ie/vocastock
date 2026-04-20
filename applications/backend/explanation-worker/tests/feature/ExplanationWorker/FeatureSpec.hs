module ExplanationWorker.FeatureSpec (run) where

import Data.List (isInfixOf)
import FeatureSupport
import TestSupport

run :: IO ()
run =
  withFeatureRuntime $ \runtime -> do
    runNamed "validates success, retryable, and terminal scenarios" $
      testValidationScenarios runtime
    runNamed "maps invalid target, ownership mismatch, and duplicates" $
      testFailureAndDuplicateScenarios runtime
    runNamed "starts as a long-running consumer" $
      testStableWorker runtime

testValidationScenarios :: FeatureRuntime -> IO ()
testValidationScenarios runtime = do
  success <- runValidation runtime "success"
  assertField success "final_state" "succeeded"
  assertField success "visibility" "completed-current"
  assertField success "completed_saved" "true"
  assertField success "handoff_completed" "true"

  retryable <- runValidation runtime "retryable-failure"
  assertField retryable "final_state" "retry-scheduled-1"
  assertField retryable "visibility" "status-only"
  assertField retryable "failure_code" "retryable-failure"
  assertField retryable "current_retained" "true"

  terminal <- runValidation runtime "terminal-failure"
  assertField terminal "final_state" "failed-final"
  assertField terminal "visibility" "status-only"
  assertField terminal "failure_code" "malformed-payload"
  assertField terminal "current_retained" "true"

testFailureAndDuplicateScenarios :: FeatureRuntime -> IO ()
testFailureAndDuplicateScenarios runtime = do
  invalidTarget <- runValidation runtime "invalid-target"
  assertField invalidTarget "final_state" "failed-final"
  assertField invalidTarget "failure_code" "invalid-target"
  assertField invalidTarget "completed_saved" "false"

  ownershipMismatch <- runValidation runtime "ownership-mismatch"
  assertField ownershipMismatch "final_state" "dead-lettered"
  assertField ownershipMismatch "failure_code" "ownership-mismatch"
  assertField ownershipMismatch "current_retained" "true"

  duplicateRunning <- runValidation runtime "duplicate-running"
  assertField duplicateRunning "final_state" "running"
  assertField duplicateRunning "duplicate" "inflight-noop"

  duplicateSucceeded <- runValidation runtime "duplicate-succeeded"
  assertField duplicateSucceeded "final_state" "succeeded"
  assertField duplicateSucceeded "duplicate" "reuse-completed"

testStableWorker :: FeatureRuntime -> IO ()
testStableWorker runtime = do
  startStableWorker runtime
  waitForStableWorker runtime
  logs <- workerLogs runtime
  assertTrue "stable-run log" ("entered stable-run mode" `isInfixOf` logs)
  assertTrue "polling log" ("awaiting queue/subscription work" `isInfixOf` logs)
