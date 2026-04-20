module ImageWorker.FeatureSpec (run) where

import Data.List (isInfixOf)
import FeatureSupport
import TestSupport

run :: IO ()
run =
  withFeatureRuntime $ \runtime -> do
    runNamed "validates success, retryable, and terminal scenarios" $
      testValidationScenarios runtime
    runNamed "maps stale success, handoff retry, duplicates, and deterministic failures" $
      testFailureAndDuplicateScenarios runtime
    runNamed "starts as a long-running consumer" $
      testStableWorker runtime

testValidationScenarios :: FeatureRuntime -> IO ()
testValidationScenarios runtime = do
  success <- runValidation runtime "success"
  assertField success "final_state" "succeeded"
  assertField success "visibility" "completed-current"
  assertField success "image_saved" "true"
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
  handoffRetry <- runValidation runtime "handoff-retry"
  assertField handoffRetry "final_state" "retry-scheduled-1"
  assertField handoffRetry "failure_code" "handoff-retry"
  assertField handoffRetry "image_saved" "true"
  assertField handoffRetry "record_visibility" "hidden-until-handoff"

  staleSuccess <- runValidation runtime "stale-success"
  assertField staleSuccess "final_state" "succeeded"
  assertField staleSuccess "visibility" "completed-non-current"
  assertField staleSuccess "current_action" "superseded-by-newer-request"
  assertField staleSuccess "record_visibility" "retained-non-current"

  invalidTarget <- runValidation runtime "invalid-target"
  assertField invalidTarget "final_state" "failed-final"
  assertField invalidTarget "failure_code" "invalid-target"

  ownershipMismatch <- runValidation runtime "ownership-mismatch"
  assertField ownershipMismatch "final_state" "failed-final"
  assertField ownershipMismatch "failure_code" "ownership-mismatch"

  explanationIncomplete <- runValidation runtime "explanation-incomplete"
  assertField explanationIncomplete "failure_code" "explanation-not-completed"

  senseMismatch <- runValidation runtime "sense-mismatch"
  assertField senseMismatch "failure_code" "sense-mismatch"

  duplicateRunning <- runValidation runtime "duplicate-running"
  assertField duplicateRunning "final_state" "running"
  assertField duplicateRunning "duplicate" "inflight-noop"

  duplicateSucceeded <- runValidation runtime "duplicate-succeeded"
  assertField duplicateSucceeded "final_state" "succeeded"
  assertField duplicateSucceeded "duplicate" "reuse-completed"

  deadLetter <- runValidation runtime "dead-letter"
  assertField deadLetter "final_state" "dead-lettered"
  assertField deadLetter "failure_code" "operator-review"

testStableWorker :: FeatureRuntime -> IO ()
testStableWorker runtime = do
  startStableWorker runtime
  waitForStableWorker runtime
  logs <- workerLogs runtime
  assertTrue "stable-run log" ("entered stable-run mode" `isInfixOf` logs)
  assertTrue "polling log" ("awaiting queue/subscription work" `isInfixOf` logs)
