module BillingWorker.FeatureSpec (run) where

import Data.List (isInfixOf)
import FeatureSupport
import TestSupport

run :: IO ()
run =
  withFeatureRuntime $ \runtime -> do
    runNamed "validates success, retryable, and terminal scenarios" $
      testValidationScenarios runtime
    runNamed "maps duplicate, invalid target, ownership mismatch, and dead letter" $
      testFailureAndDuplicateScenarios runtime
    runNamed "validates notification reconciliation success and failure paths" $
      testNotificationScenarios runtime
    runNamed "starts as a long-running consumer" $
      testStableWorker runtime

testValidationScenarios :: FeatureRuntime -> IO ()
testValidationScenarios runtime = do
  success <- runValidation runtime "success"
  assertField success "final_state" "succeeded"
  assertField success "visibility" "completed-current"
  assertField success "completed_saved" "true"
  assertField success "handoff_completed" "true"
  assertField success "source" "purchase-verification"

  retryable <- runValidation runtime "retryable-failure"
  assertField retryable "final_state" "retry-scheduled-1"
  assertField retryable "visibility" "status-only"
  assertField retryable "failure_code" "retryable-verification"
  assertField retryable "public_status" "retry-scheduled"
  assertField retryable "current_retained" "true"

  terminal <- runValidation runtime "terminal-failure"
  assertField terminal "final_state" "failed-final"
  assertField terminal "visibility" "status-only"
  assertField terminal "failure_code" "terminal"
  assertField terminal "public_status" "failed-final"
  assertField terminal "current_retained" "true"

testFailureAndDuplicateScenarios :: FeatureRuntime -> IO ()
testFailureAndDuplicateScenarios runtime = do
  timedOut <- runValidation runtime "timed-out"
  assertField timedOut "final_state" "retry-scheduled-1"
  assertField timedOut "failure_code" "timed-out"
  assertField timedOut "public_status" "timed-out"

  retryExhausted <- runValidation runtime "retry-exhausted"
  assertField retryExhausted "final_state" "failed-final"
  assertField retryExhausted "failure_code" "timed-out"

  invalidTarget <- runValidation runtime "invalid-target"
  assertField invalidTarget "final_state" "failed-final"
  assertField invalidTarget "failure_code" "precondition-invalid"

  ownershipMismatch <- runValidation runtime "ownership-mismatch"
  assertField ownershipMismatch "final_state" "dead-lettered"
  assertField ownershipMismatch "failure_code" "ownership-mismatch"

  duplicateRunning <- runValidation runtime "duplicate-running"
  assertField duplicateRunning "final_state" "running"
  assertField duplicateRunning "duplicate" "inflight-noop"

  duplicateSucceeded <- runValidation runtime "duplicate-succeeded"
  assertField duplicateSucceeded "final_state" "succeeded"
  assertField duplicateSucceeded "duplicate" "reuse-completed"
  assertField duplicateSucceeded "current_retained" "true"

testNotificationScenarios :: FeatureRuntime -> IO ()
testNotificationScenarios runtime = do
  reconciled <- runValidation runtime "notification-reconciled"
  assertField reconciled "final_state" "succeeded"
  assertField reconciled "visibility" "completed-current"
  assertField reconciled "completed_saved" "true"
  assertField reconciled "handoff_completed" "true"
  assertField reconciled "source" "notification-reconciliation"

  retryable <- runValidation runtime "notification-retryable"
  assertField retryable "final_state" "retry-scheduled-1"
  assertField retryable "failure_code" "retryable-notification-ingest"
  assertField retryable "source" "notification-reconciliation"

  terminal <- runValidation runtime "notification-terminal"
  assertField terminal "final_state" "failed-final"
  assertField terminal "failure_code" "malformed-notification"

  stale <- runValidation runtime "notification-stale"
  assertField stale "final_state" "failed-final"
  assertField stale "failure_code" "stale-notification"

  deadLetter <- runValidation runtime "notification-dead-letter"
  assertField deadLetter "final_state" "dead-lettered"
  assertField deadLetter "failure_code" "operator-review"

testStableWorker :: FeatureRuntime -> IO ()
testStableWorker runtime = do
  startStableWorker runtime
  waitForStableWorker runtime
  logs <- workerLogs runtime
  assertTrue "stable-run log" ("entered stable-run mode" `isInfixOf` logs)
  assertTrue "polling log" ("awaiting queue/subscription work" `isInfixOf` logs)
