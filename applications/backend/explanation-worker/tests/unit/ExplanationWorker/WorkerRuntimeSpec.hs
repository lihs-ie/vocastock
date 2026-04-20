module ExplanationWorker.WorkerRuntimeSpec (run) where

import ExplanationWorker.WorkerRuntime
import TestSupport

run :: IO ()
run = do
  runNamed "reports a completed success scenario" testSuccessScenario
  runNamed "reports retryable and timeout scenarios" testRetryableScenario
  runNamed "reports terminal and duplicate scenarios" testTerminalAndDuplicateScenarios
  runNamed "reports validation failures" testValidationFailureScenarios
  runNamed "renders scenario output for validation scripts" testRenderScenarioOutput
  runNamed "covers report accessors and show instances" testAccessorsAndShow

testSuccessScenario :: IO ()
testSuccessScenario =
  let report = runScenarioReport ScenarioSuccess
   in do
        assertEqual "final state" "succeeded" (reportFinalState report)
        assertEqual "visibility" "completed-current" (reportVisibility report)
        assertTrue "completed saved" (reportCompletedSaved report)

testRetryableScenario :: IO ()
testRetryableScenario =
  let retryableReport = runScenarioReport ScenarioRetryableFailure
      timeoutReport = runScenarioReport ScenarioTimeout
   in do
        assertEqual "retry state" "retry-scheduled-1" (reportFinalState retryableReport)
        assertEqual "retry failure code" "retryable-failure" (reportFailureCode retryableReport)
        assertEqual "retry trail" ["queued", "running", "retry-scheduled-1"] (reportTrail retryableReport)
        assertEqual "retry flag" True (reportRetryable retryableReport)
        assertEqual "retry handoff" False (reportHandoffCompleted retryableReport)
        assertTrue "retained current" (reportCurrentRetained retryableReport)
        assertEqual "timeout state" "retry-scheduled-1" (reportFinalState timeoutReport)
        assertEqual "timeout failure code" "timed-out" (reportFailureCode timeoutReport)
        assertEqual "timeout trail" ["queued", "running", "timed-out-1", "retry-scheduled-1"] (reportTrail timeoutReport)

testTerminalAndDuplicateScenarios :: IO ()
testTerminalAndDuplicateScenarios = do
  let terminalReport = runScenarioReport ScenarioTerminalFailure
      duplicateRunningReport = runScenarioReport ScenarioDuplicateRunning
      duplicateSucceededReport = runScenarioReport ScenarioDuplicateSucceeded
  assertEqual "terminal final state" "failed-final" (reportFinalState terminalReport)
  assertEqual "terminal failure code" "malformed-payload" (reportFailureCode terminalReport)
  assertEqual "duplicate running state" "running" (reportFinalState duplicateRunningReport)
  assertEqual "duplicate running disposition" "inflight-noop" (reportDuplicateDisposition duplicateRunningReport)
  assertEqual "duplicate running failure" "duplicate-in-flight" (reportFailureCode duplicateRunningReport)
  assertEqual "duplicate succeeded state" "succeeded" (reportFinalState duplicateSucceededReport)
  assertEqual "duplicate succeeded disposition" "reuse-completed" (reportDuplicateDisposition duplicateSucceededReport)
  assertEqual "duplicate succeeded action" "retained-existing" (reportCurrentAction duplicateSucceededReport)
  assertEqual "duplicate succeeded handoff" False (reportHandoffCompleted duplicateSucceededReport)
  assertEqual "duplicate succeeded trail" ["queued", "succeeded"] (reportTrail duplicateSucceededReport)

testValidationFailureScenarios :: IO ()
testValidationFailureScenarios = do
  let invalidTargetReport = runScenarioReport ScenarioInvalidTarget
      ownershipReport = runScenarioReport ScenarioOwnershipMismatch
      preconditionReport = runScenarioReport ScenarioPreconditionInvalid
  assertEqual "invalid target" "failed-final" (reportFinalState invalidTargetReport)
  assertEqual "invalid target code" "invalid-target" (reportFailureCode invalidTargetReport)
  assertEqual "ownership mismatch" "dead-lettered" (reportFinalState ownershipReport)
  assertEqual "ownership mismatch code" "ownership-mismatch" (reportFailureCode ownershipReport)
  assertEqual "precondition invalid code" "precondition-invalid" (reportFailureCode preconditionReport)
  assertEqual "ownership retained" True (reportCurrentRetained ownershipReport)

testRenderScenarioOutput :: IO ()
testRenderScenarioOutput =
  let successRendered = renderScenarioReport (runScenarioReport ScenarioSuccess)
      retryableRendered = renderScenarioReport (runScenarioReport ScenarioRetryableFailure)
      duplicateRendered = renderScenarioReport (runScenarioReport ScenarioDuplicateSucceeded)
   in do
        assertEqual
          "exact rendered output"
          "VOCAS_EXPLANATION_RESULT scenario=success final_state=succeeded trail=queued,running,succeeded visibility=completed-current failure_code=none retryable=false completed_saved=true handoff_completed=true current_action=switched current_retained=false duplicate=fresh"
          successRendered
        assertEqual
          "retryable rendered output"
          "VOCAS_EXPLANATION_RESULT scenario=retryable-failure final_state=retry-scheduled-1 trail=queued,running,retry-scheduled-1 visibility=status-only failure_code=retryable-failure retryable=true completed_saved=false handoff_completed=false current_action=retained-existing current_retained=true duplicate=fresh"
          retryableRendered
        assertEqual
          "duplicate rendered output"
          "VOCAS_EXPLANATION_RESULT scenario=duplicate-succeeded final_state=succeeded trail=queued,succeeded visibility=completed-current failure_code=none retryable=false completed_saved=true handoff_completed=false current_action=retained-existing current_retained=true duplicate=reuse-completed"
          duplicateRendered

testAccessorsAndShow :: IO ()
testAccessorsAndShow = do
  let successReport = runScenarioReport ScenarioSuccess
      duplicateReport = runScenarioReport ScenarioDuplicateSucceeded
      retryableReport = runScenarioReport ScenarioRetryableFailure
  assertEqual "trail accessor" ["queued", "running", "succeeded"] (reportTrail successReport)
  assertEqual "retryable accessor" True (reportRetryable retryableReport)
  assertEqual "handoff accessor" False (reportHandoffCompleted duplicateReport)
  assertEqual "report equality" True (successReport == successReport)
  assertTrue "show scenario" ("ScenarioSuccess" `elem` words (show ScenarioSuccess))
  assertTrue "show report" ("ScenarioReport" `elem` words (show successReport))
