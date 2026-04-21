module BillingWorker.WorkerRuntimeSpec (run) where

import Data.List (isInfixOf)

import BillingWorker.WorkerRuntime
import TestSupport

run :: IO ()
run = do
  runNamed "renders scenario labels" testRendersScenarioLabels
  runNamed "parses scenario labels" testParsesScenarioLabels
  runNamed "purchase success scenario report" testPurchaseSuccessReport
  runNamed "purchase retryable scenario report" testPurchaseRetryableReport
  runNamed "purchase terminal scenario report" testPurchaseTerminalReport
  runNamed "purchase timeout scenario report" testPurchaseTimeoutReport
  runNamed "duplicate inflight scenario report" testDuplicateInflightReport
  runNamed "duplicate succeeded scenario report" testDuplicateSucceededReport
  runNamed "retry exhausted scenario report" testRetryExhaustedReport
  runNamed "invalid target scenario report" testInvalidTargetReport
  runNamed "ownership mismatch scenario report" testOwnershipMismatchReport
  runNamed "notification reconciled scenario report" testNotificationReconciledReport
  runNamed "notification retryable scenario report" testNotificationRetryableReport
  runNamed "notification terminal scenario report" testNotificationTerminalReport
  runNamed "notification stale scenario report" testNotificationStaleReport
  runNamed "notification dead letter scenario report" testNotificationDeadLetterReport
  runNamed "renders scenario report" testRendersScenarioReport

testRendersScenarioLabels :: IO ()
testRendersScenarioLabels = do
  assertEqual "label success" "success" (workerScenarioLabel ScenarioSuccess)
  assertEqual "label retryable" "retryable-failure" (workerScenarioLabel ScenarioRetryableFailure)
  assertEqual "label terminal" "terminal-failure" (workerScenarioLabel ScenarioTerminalFailure)
  assertEqual "label timed-out" "timed-out" (workerScenarioLabel ScenarioTimeout)
  assertEqual "label duplicate-running" "duplicate-running" (workerScenarioLabel ScenarioDuplicateRunning)
  assertEqual "label duplicate-succeeded" "duplicate-succeeded" (workerScenarioLabel ScenarioDuplicateSucceeded)
  assertEqual "label retry-exhausted" "retry-exhausted" (workerScenarioLabel ScenarioRetryExhausted)
  assertEqual "label invalid-target" "invalid-target" (workerScenarioLabel ScenarioInvalidTarget)
  assertEqual "label ownership-mismatch" "ownership-mismatch" (workerScenarioLabel ScenarioOwnershipMismatch)
  assertEqual "label notification-reconciled" "notification-reconciled" (workerScenarioLabel ScenarioNotificationReconciled)
  assertEqual "label notification-retryable" "notification-retryable" (workerScenarioLabel ScenarioNotificationRetryable)
  assertEqual "label notification-terminal" "notification-terminal" (workerScenarioLabel ScenarioNotificationTerminal)
  assertEqual "label notification-stale" "notification-stale" (workerScenarioLabel ScenarioNotificationStale)
  assertEqual "label notification-dead-letter" "notification-dead-letter" (workerScenarioLabel ScenarioNotificationDeadLetter)
  assertTrue "show ScenarioSuccess" (not (null (show ScenarioSuccess)))
  assertTrue "show report" (not (null (show (runScenarioReport ScenarioSuccess))))

testParsesScenarioLabels :: IO ()
testParsesScenarioLabels = do
  assertEqual "success" (Just ScenarioSuccess) (parseWorkerScenarioLabel "success")
  assertEqual "retryable-failure" (Just ScenarioRetryableFailure) (parseWorkerScenarioLabel "retryable-failure")
  assertEqual "terminal-failure" (Just ScenarioTerminalFailure) (parseWorkerScenarioLabel "terminal-failure")
  assertEqual "timed-out" (Just ScenarioTimeout) (parseWorkerScenarioLabel "timed-out")
  assertEqual "duplicate-running" (Just ScenarioDuplicateRunning) (parseWorkerScenarioLabel "duplicate-running")
  assertEqual "duplicate-succeeded" (Just ScenarioDuplicateSucceeded) (parseWorkerScenarioLabel "duplicate-succeeded")
  assertEqual "retry-exhausted" (Just ScenarioRetryExhausted) (parseWorkerScenarioLabel "retry-exhausted")
  assertEqual "invalid-target" (Just ScenarioInvalidTarget) (parseWorkerScenarioLabel "invalid-target")
  assertEqual "ownership-mismatch" (Just ScenarioOwnershipMismatch) (parseWorkerScenarioLabel "ownership-mismatch")
  assertEqual "notification-reconciled" (Just ScenarioNotificationReconciled) (parseWorkerScenarioLabel "notification-reconciled")
  assertEqual "notification-retryable" (Just ScenarioNotificationRetryable) (parseWorkerScenarioLabel "notification-retryable")
  assertEqual "notification-terminal" (Just ScenarioNotificationTerminal) (parseWorkerScenarioLabel "notification-terminal")
  assertEqual "notification-stale" (Just ScenarioNotificationStale) (parseWorkerScenarioLabel "notification-stale")
  assertEqual "notification-dead-letter" (Just ScenarioNotificationDeadLetter) (parseWorkerScenarioLabel "notification-dead-letter")
  assertEqual "unknown" Nothing (parseWorkerScenarioLabel "unknown")

testPurchaseSuccessReport :: IO ()
testPurchaseSuccessReport = do
  let report = runScenarioReport ScenarioSuccess
  assertEqual "final state" "succeeded" (reportFinalState report)
  assertEqual "visibility" "completed-current" (reportVisibility report)
  assertEqual "failure code" "none" (reportFailureCode report)
  assertEqual "handoff completed" True (reportHandoffCompleted report)
  assertEqual "completed saved" True (reportCompletedSaved report)
  assertEqual "source" "purchase-verification" (reportSource report)

testPurchaseRetryableReport :: IO ()
testPurchaseRetryableReport = do
  let report = runScenarioReport ScenarioRetryableFailure
  assertEqual "final state" "retry-scheduled-1" (reportFinalState report)
  assertEqual "failure code" "retryable-verification" (reportFailureCode report)
  assertEqual "public status" "retry-scheduled" (reportPublicStatus report)
  assertEqual "retryable" True (reportRetryable report)
  assertEqual "completed saved" False (reportCompletedSaved report)

testPurchaseTerminalReport :: IO ()
testPurchaseTerminalReport = do
  let report = runScenarioReport ScenarioTerminalFailure
  assertEqual "final state" "failed-final" (reportFinalState report)
  assertEqual "failure code" "terminal" (reportFailureCode report)
  assertEqual "public status" "failed-final" (reportPublicStatus report)
  assertEqual "retryable" False (reportRetryable report)

testPurchaseTimeoutReport :: IO ()
testPurchaseTimeoutReport = do
  let report = runScenarioReport ScenarioTimeout
  assertEqual "final state" "retry-scheduled-1" (reportFinalState report)
  assertEqual "failure code" "timed-out" (reportFailureCode report)
  assertEqual "public status" "timed-out" (reportPublicStatus report)

testDuplicateInflightReport :: IO ()
testDuplicateInflightReport = do
  let report = runScenarioReport ScenarioDuplicateRunning
  assertEqual "final state" "running" (reportFinalState report)
  assertEqual "duplicate" "inflight-noop" (reportDuplicateDisposition report)

testDuplicateSucceededReport :: IO ()
testDuplicateSucceededReport = do
  let report = runScenarioReport ScenarioDuplicateSucceeded
  assertEqual "final state" "succeeded" (reportFinalState report)
  assertEqual "duplicate" "reuse-completed" (reportDuplicateDisposition report)
  assertEqual "current retained" True (reportCurrentRetained report)

testRetryExhaustedReport :: IO ()
testRetryExhaustedReport = do
  let report = runScenarioReport ScenarioRetryExhausted
  assertEqual "final state" "failed-final" (reportFinalState report)

testInvalidTargetReport :: IO ()
testInvalidTargetReport = do
  let report = runScenarioReport ScenarioInvalidTarget
  assertEqual "final state" "failed-final" (reportFinalState report)
  assertEqual "failure code" "precondition-invalid" (reportFailureCode report)

testOwnershipMismatchReport :: IO ()
testOwnershipMismatchReport = do
  let report = runScenarioReport ScenarioOwnershipMismatch
  assertEqual "final state" "dead-lettered" (reportFinalState report)
  assertEqual "failure code" "ownership-mismatch" (reportFailureCode report)

testNotificationReconciledReport :: IO ()
testNotificationReconciledReport = do
  let report = runScenarioReport ScenarioNotificationReconciled
  assertEqual "final state" "succeeded" (reportFinalState report)
  assertEqual "source" "notification-reconciliation" (reportSource report)

testNotificationRetryableReport :: IO ()
testNotificationRetryableReport = do
  let report = runScenarioReport ScenarioNotificationRetryable
  assertEqual "final state" "retry-scheduled-1" (reportFinalState report)
  assertEqual "failure code" "retryable-notification-ingest" (reportFailureCode report)

testNotificationTerminalReport :: IO ()
testNotificationTerminalReport = do
  let report = runScenarioReport ScenarioNotificationTerminal
  assertEqual "final state" "failed-final" (reportFinalState report)
  assertEqual "failure code" "malformed-notification" (reportFailureCode report)

testNotificationStaleReport :: IO ()
testNotificationStaleReport = do
  let report = runScenarioReport ScenarioNotificationStale
  assertEqual "final state" "failed-final" (reportFinalState report)
  assertEqual "failure code" "stale-notification" (reportFailureCode report)

testNotificationDeadLetterReport :: IO ()
testNotificationDeadLetterReport = do
  let report = runScenarioReport ScenarioNotificationDeadLetter
  assertEqual "final state" "dead-lettered" (reportFinalState report)
  assertEqual "failure code" "operator-review" (reportFailureCode report)

testRendersScenarioReport :: IO ()
testRendersScenarioReport = do
  let report = runScenarioReport ScenarioSuccess
      rendered = renderScenarioReport report
  assertTrue "starts with result prefix" ("VOCAS_BILLING_RESULT" `isInfixOf` rendered)
  assertTrue "contains scenario" ("scenario=success" `isInfixOf` rendered)
  assertTrue "contains final state" ("final_state=succeeded" `isInfixOf` rendered)
  assertTrue "contains handoff completed" ("handoff_completed=true" `isInfixOf` rendered)
  assertTrue "contains source" ("source=purchase-verification" `isInfixOf` rendered)
