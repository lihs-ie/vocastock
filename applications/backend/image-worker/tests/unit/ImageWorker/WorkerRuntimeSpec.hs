module ImageWorker.WorkerRuntimeSpec (run) where

import ImageWorker.WorkerRuntime
import TestSupport

run :: IO ()
run = do
  runNamed "reports a completed success scenario" testSuccessScenario
  runNamed "reports retryable, timeout, and handoff retry scenarios" testRetryableScenarios
  runNamed "reports stale success, terminal, and duplicate scenarios" testStaleAndDuplicateScenarios
  runNamed "reports validation and dead-letter scenarios" testFailureScenarios
  runNamed "renders scenario output for validation scripts" testRenderScenarioOutput
  runNamed "parses and renders scenario labels" testScenarioLabels
  runNamed "covers every scenario label roundtrip" testAllScenarioLabels
  runNamed "covers report accessors and show instances" testAccessorsAndShow

testSuccessScenario :: IO ()
testSuccessScenario =
  let report = runScenarioReport ScenarioSuccess
   in do
        assertEqual "final state" "succeeded" (reportFinalState report)
        assertEqual "visibility" "completed-current" (reportVisibility report)
        assertEqual "save action" "created" (reportSaveAction report)
        assertEqual "record visibility" "current-applied" (reportRecordVisibility report)
        assertTrue "image saved" (reportImageSaved report)

testRetryableScenarios :: IO ()
testRetryableScenarios = do
  let retryableReport = runScenarioReport ScenarioRetryableFailure
      timeoutReport = runScenarioReport ScenarioTimeout
      handoffRetryReport = runScenarioReport ScenarioHandoffRetry
  assertEqual "retryable state" "retry-scheduled-1" (reportFinalState retryableReport)
  assertEqual "retryable code" "retryable-failure" (reportFailureCode retryableReport)
  assertEqual "retryable flag" True (reportRetryable retryableReport)
  assertEqual "timeout state" "retry-scheduled-1" (reportFinalState timeoutReport)
  assertEqual "timeout code" "timed-out" (reportFailureCode timeoutReport)
  assertEqual "handoff retry state" "retry-scheduled-1" (reportFinalState handoffRetryReport)
  assertEqual "handoff retry code" "handoff-retry" (reportFailureCode handoffRetryReport)
  assertEqual "handoff retry visibility" "status-only" (reportVisibility handoffRetryReport)
  assertEqual "handoff retry image saved" True (reportImageSaved handoffRetryReport)
  assertEqual "handoff retry record visibility" "hidden-until-handoff" (reportRecordVisibility handoffRetryReport)

testStaleAndDuplicateScenarios :: IO ()
testStaleAndDuplicateScenarios = do
  let staleReport = runScenarioReport ScenarioStaleSuccess
      terminalReport = runScenarioReport ScenarioTerminalFailure
      duplicateRunningReport = runScenarioReport ScenarioDuplicateRunning
      duplicateSucceededReport = runScenarioReport ScenarioDuplicateSucceeded
  assertEqual "stale state" "succeeded" (reportFinalState staleReport)
  assertEqual "stale visibility" "completed-non-current" (reportVisibility staleReport)
  assertEqual "stale current action" "superseded-by-newer-request" (reportCurrentAction staleReport)
  assertEqual "stale record visibility" "retained-non-current" (reportRecordVisibility staleReport)
  assertEqual "terminal state" "failed-final" (reportFinalState terminalReport)
  assertEqual "terminal code" "malformed-payload" (reportFailureCode terminalReport)
  assertEqual "duplicate running state" "running" (reportFinalState duplicateRunningReport)
  assertEqual "duplicate running disposition" "inflight-noop" (reportDuplicateDisposition duplicateRunningReport)
  assertEqual "duplicate succeeded state" "succeeded" (reportFinalState duplicateSucceededReport)
  assertEqual "duplicate succeeded disposition" "reuse-completed" (reportDuplicateDisposition duplicateSucceededReport)

testFailureScenarios :: IO ()
testFailureScenarios = do
  let invalidTargetReport = runScenarioReport ScenarioInvalidTarget
      ownershipReport = runScenarioReport ScenarioOwnershipMismatch
      explanationIncompleteReport = runScenarioReport ScenarioExplanationIncomplete
      senseMismatchReport = runScenarioReport ScenarioSenseMismatch
      deadLetterReport = runScenarioReport ScenarioDeadLetter
  assertEqual "invalid target" "invalid-target" (reportFailureCode invalidTargetReport)
  assertEqual "ownership mismatch" "ownership-mismatch" (reportFailureCode ownershipReport)
  assertEqual "explanation incomplete" "explanation-not-completed" (reportFailureCode explanationIncompleteReport)
  assertEqual "sense mismatch" "sense-mismatch" (reportFailureCode senseMismatchReport)
  assertEqual "dead letter state" "dead-lettered" (reportFinalState deadLetterReport)
  assertEqual "dead letter code" "operator-review" (reportFailureCode deadLetterReport)

testRenderScenarioOutput :: IO ()
testRenderScenarioOutput = do
  assertEqual
    "success output"
    "VOCAS_IMAGE_RESULT scenario=success final_state=succeeded trail=queued,running,succeeded visibility=completed-current failure_code=none retryable=false image_saved=true handoff_completed=true current_action=switched current_retained=false duplicate=fresh save_action=created record_visibility=current-applied"
    (renderScenarioReport (runScenarioReport ScenarioSuccess))
  assertEqual
    "stale success output"
    "VOCAS_IMAGE_RESULT scenario=stale-success final_state=succeeded trail=queued,running,succeeded visibility=completed-non-current failure_code=none retryable=false image_saved=true handoff_completed=false current_action=superseded-by-newer-request current_retained=true duplicate=fresh save_action=retained-non-current record_visibility=retained-non-current"
    (renderScenarioReport (runScenarioReport ScenarioStaleSuccess))

testScenarioLabels :: IO ()
testScenarioLabels = do
  assertEqual "parse success" (Just ScenarioSuccess) (parseWorkerScenarioLabel "success")
  assertEqual "parse stale" (Just ScenarioStaleSuccess) (parseWorkerScenarioLabel "stale-success")
  assertEqual "parse missing" Nothing (parseWorkerScenarioLabel "unknown")
  assertEqual "render handoff retry" "handoff-retry" (workerScenarioLabel ScenarioHandoffRetry)
  assertEqual "render dead letter" "dead-letter" (workerScenarioLabel ScenarioDeadLetter)

testAllScenarioLabels :: IO ()
testAllScenarioLabels =
  mapM_
    assertScenarioLabel
    [ (ScenarioSuccess, "success"),
      (ScenarioRetryableFailure, "retryable-failure"),
      (ScenarioTerminalFailure, "terminal-failure"),
      (ScenarioTimeout, "timed-out"),
      (ScenarioHandoffRetry, "handoff-retry"),
      (ScenarioStaleSuccess, "stale-success"),
      (ScenarioDuplicateRunning, "duplicate-running"),
      (ScenarioDuplicateSucceeded, "duplicate-succeeded"),
      (ScenarioInvalidTarget, "invalid-target"),
      (ScenarioOwnershipMismatch, "ownership-mismatch"),
      (ScenarioExplanationIncomplete, "explanation-incomplete"),
      (ScenarioSenseMismatch, "sense-mismatch"),
      (ScenarioDeadLetter, "dead-letter")
    ]
  where
    assertScenarioLabel (scenario, label) = do
      assertEqual ("render label " ++ label) label (workerScenarioLabel scenario)
      assertEqual ("parse label " ++ label) (Just scenario) (parseWorkerScenarioLabel label)

testAccessorsAndShow :: IO ()
testAccessorsAndShow = do
  let successReport = runScenarioReport ScenarioSuccess
      deadLetterReport = runScenarioReport ScenarioDeadLetter
  assertEqual "trail accessor" ["queued", "running", "succeeded"] (reportTrail successReport)
  assertEqual "current retained accessor" True (reportCurrentRetained deadLetterReport)
  assertEqual "report equality" True (successReport == successReport)
  assertEqual "show scenario" True ("ScenarioSuccess" `elem` words (show ScenarioSuccess))
  assertEqual "show report" True ("ScenarioReport" `elem` words (show successReport))
