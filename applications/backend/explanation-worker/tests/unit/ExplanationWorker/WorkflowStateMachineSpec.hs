module ExplanationWorker.WorkflowStateMachineSpec (run) where

import ExplanationWorker.CurrentExplanationHandoff
import ExplanationWorker.ExplanationPersistence
import ExplanationWorker.FailureSummary
import ExplanationWorker.GenerationPort
import ExplanationWorker.WorkflowStateMachine
import ExplanationWorker.WorkItemContract
import TestSupport

run :: IO ()
run = do
  runNamed "transitions queued to succeeded" testSuccessTransition
  runNamed "reuses an existing completed record on success" testSuccessReuseTransition
  runNamed "keeps current on retryable failure" testRetryableFailureTransition
  runNamed "maps timeout into retry-scheduled" testTimedOutTransition
  runNamed "maps exhausted timeout and terminal failures" testTerminalTransitions
  runNamed "maps duplicate paths" testDuplicateTransitions
  runNamed "renders workflow states" testRenderWorkflowStates
  runNamed "maps intake failures into terminal outcomes" testIntakeFailureTransition
  runNamed "covers workflow accessors and show instances" testAccessorsAndShow

validatedWorkItem :: ValidatedWorkItem
validatedWorkItem =
  case validateWorkItem defaultWorkItem of
    Left failure -> error ("unexpected validation failure: " ++ renderIntakeFailure failure)
    Right value -> value

testSuccessTransition :: IO ()
testSuccessTransition = do
  let outcome =
        runGenerationOutcome
          RetryBudget {retryAttempt = 1, retryLimit = 2}
          NoCurrent
          emptyExplanationStore
          validatedWorkItem
          successfulOutcome
  assertEqual "final state" Succeeded (workflowFinalState outcome)
  assertEqual "trail" [Queued, Running, Succeeded] (workflowTrail outcome)
  assertEqual "save action" (Just SaveCreated) (workflowSaveAction outcome)
  assertEqual "visibility" CompletedCurrent (workflowVisibility outcome)
  assertEqual "failure summary on success" Nothing (workflowFailureSummary outcome)
  assertEqual "current action on success" (CurrentSwitched "business-key-001-completed") (workflowCurrentAction outcome)
  assertEqual "completed record present" True (maybe False (const True) (workflowCompletedRecord outcome))
  assertEqual "duplicate disposition" ProcessFresh (workflowDuplicateDisposition outcome)
  assertEqual "store length" 1 (length (explanationEntries (workflowStore outcome)))
  assertTrue "handoff completed" (workflowHandoffCompleted outcome)

testSuccessReuseTransition :: IO ()
testSuccessReuseTransition = do
  let payload =
        case outcomePayload successfulOutcome of
          Nothing -> error "expected successful payload"
          Just payloadValue -> payloadValue
      existingRecord =
        completedRecordFor "business-key-001" "vocabulary-expression-001" payload
      outcome =
        runGenerationOutcome
          RetryBudget {retryAttempt = 1, retryLimit = 2}
          (ExistingCurrent "old-current")
          (ExplanationStore [("business-key-001", existingRecord)])
          validatedWorkItem
          successfulOutcome
  assertEqual "save action reused" (Just SaveReused) (workflowSaveAction outcome)
  assertEqual "completed record reused" (Just existingRecord) (workflowCompletedRecord outcome)
  assertEqual "current switched" (CurrentSwitched "business-key-001-completed") (workflowCurrentAction outcome)
  assertEqual "reused visibility" CompletedCurrent (workflowVisibility outcome)
  assertEqual "reused failure summary" Nothing (workflowFailureSummary outcome)
  assertEqual "reused duplicate disposition" ProcessFresh (workflowDuplicateDisposition outcome)
  assertEqual "reused handoff" True (workflowHandoffCompleted outcome)
  assertEqual "reused store length" 1 (length (explanationEntries (workflowStore outcome)))

testRetryableFailureTransition :: IO ()
testRetryableFailureTransition = do
  let outcome =
        runGenerationOutcome
          RetryBudget {retryAttempt = 1, retryLimit = 2}
          (ExistingCurrent "existing-current-001")
          emptyExplanationStore
          validatedWorkItem
          retryableFailureOutcome
  assertEqual "retry scheduled" (RetryScheduled 1) (workflowFinalState outcome)
  assertEqual "retry failure code" (Just FailureRetryable) (summaryCode <$> workflowFailureSummary outcome)
  assertEqual "retained current" (CurrentRetained (Just "existing-current-001")) (workflowCurrentAction outcome)
  assertEqual "retry visibility" StatusOnly (workflowVisibility outcome)
  assertEqual "retry completed record" Nothing (workflowCompletedRecord outcome)
  assertEqual "retry duplicate disposition" ProcessFresh (workflowDuplicateDisposition outcome)
  assertEqual "retry save action" Nothing (workflowSaveAction outcome)
  assertEqual "retry store" emptyExplanationStore (workflowStore outcome)
  assertEqual "retry handoff" False (workflowHandoffCompleted outcome)

testTimedOutTransition :: IO ()
testTimedOutTransition = do
  let outcome =
        runGenerationOutcome
          RetryBudget {retryAttempt = 1, retryLimit = 2}
          (ExistingCurrent "existing-current-001")
          emptyExplanationStore
          validatedWorkItem
          timedOutOutcome
  assertEqual "timeout final state" (RetryScheduled 1) (workflowFinalState outcome)
  assertEqual "trail includes timeout" [Queued, Running, TimedOut 1, RetryScheduled 1] (workflowTrail outcome)
  assertEqual "timeout visibility" StatusOnly (workflowVisibility outcome)
  assertEqual "timeout failure code" (Just FailureTimedOut) (summaryCode <$> workflowFailureSummary outcome)
  assertEqual "timeout current action" (CurrentRetained (Just "existing-current-001")) (workflowCurrentAction outcome)
  assertEqual "timeout duplicate disposition" ProcessFresh (workflowDuplicateDisposition outcome)
  assertEqual "timeout completed record" Nothing (workflowCompletedRecord outcome)
  assertEqual "timeout save action" Nothing (workflowSaveAction outcome)
  assertEqual "timeout store" emptyExplanationStore (workflowStore outcome)
  assertEqual "timeout handoff" False (workflowHandoffCompleted outcome)

testTerminalTransitions :: IO ()
testTerminalTransitions = do
  let exhaustedTimeoutOutcome =
        runGenerationOutcome
          RetryBudget {retryAttempt = 2, retryLimit = 2}
          (ExistingCurrent "existing-current-001")
          emptyExplanationStore
          validatedWorkItem
          timedOutOutcome
      malformedOutcome =
        runGenerationOutcome
          RetryBudget {retryAttempt = 1, retryLimit = 2}
          (ExistingCurrent "existing-current-001")
          emptyExplanationStore
          validatedWorkItem
          malformedSuccessOutcome
      nonRetryableOutcome =
        runGenerationOutcome
          RetryBudget {retryAttempt = 1, retryLimit = 2}
          (ExistingCurrent "existing-current-001")
          emptyExplanationStore
          validatedWorkItem
          nonRetryableFailureOutcome
  assertEqual "timeout exhausted final state" FailedFinal (workflowFinalState exhaustedTimeoutOutcome)
  assertEqual "timeout exhausted code" (Just FailureTimedOut) (summaryCode <$> workflowFailureSummary exhaustedTimeoutOutcome)
  assertEqual "timeout exhausted trail" [Queued, Running, TimedOut 2, FailedFinal] (workflowTrail exhaustedTimeoutOutcome)
  assertEqual "timeout exhausted current" (CurrentRetained (Just "existing-current-001")) (workflowCurrentAction exhaustedTimeoutOutcome)
  assertEqual "timeout exhausted duplicate" ProcessFresh (workflowDuplicateDisposition exhaustedTimeoutOutcome)
  assertEqual "timeout exhausted completed record" Nothing (workflowCompletedRecord exhaustedTimeoutOutcome)
  assertEqual "malformed final state" FailedFinal (workflowFinalState malformedOutcome)
  assertEqual "malformed code" (Just FailureMalformedPayload) (summaryCode <$> workflowFailureSummary malformedOutcome)
  assertEqual "malformed visibility" StatusOnly (workflowVisibility malformedOutcome)
  assertEqual "malformed current" (CurrentRetained (Just "existing-current-001")) (workflowCurrentAction malformedOutcome)
  assertEqual "malformed duplicate" ProcessFresh (workflowDuplicateDisposition malformedOutcome)
  assertEqual "malformed completed record" Nothing (workflowCompletedRecord malformedOutcome)
  assertEqual "malformed save action" Nothing (workflowSaveAction malformedOutcome)
  assertEqual "malformed handoff" False (workflowHandoffCompleted malformedOutcome)
  assertEqual "non retryable final state" FailedFinal (workflowFinalState nonRetryableOutcome)
  assertEqual "non retryable code" (Just FailureTerminal) (summaryCode <$> workflowFailureSummary nonRetryableOutcome)
  assertEqual "non retryable current" (CurrentRetained (Just "existing-current-001")) (workflowCurrentAction nonRetryableOutcome)
  assertEqual "non retryable duplicate" ProcessFresh (workflowDuplicateDisposition nonRetryableOutcome)
  assertEqual "non retryable completed record" Nothing (workflowCompletedRecord nonRetryableOutcome)
  assertEqual "non retryable save action" Nothing (workflowSaveAction nonRetryableOutcome)
  assertEqual "non retryable store" emptyExplanationStore (workflowStore nonRetryableOutcome)
  assertEqual "non retryable handoff" False (workflowHandoffCompleted nonRetryableOutcome)

testDuplicateTransitions :: IO ()
testDuplicateTransitions = do
  let payload =
        case outcomePayload successfulOutcome of
          Nothing -> error "expected successful payload"
          Just payloadValue -> payloadValue
      completedRecord =
        completedRecordFor "business-key-001" "vocabulary-expression-001" payload
      freshOutcome =
        duplicateOutcome ProcessFresh (ExistingCurrent "existing-current-001") emptyExplanationStore Nothing
      inflightOutcome =
        duplicateOutcome
          IgnoreDuplicateInFlight
          (ExistingCurrent "existing-current-001")
          emptyExplanationStore
          Nothing
      reuseOutcome =
        duplicateOutcome
          ReuseCompletedDuplicate
          (ExistingCurrent "existing-current-001")
          (ExplanationStore [("business-key-001", completedRecord)])
          (Just completedRecord)
  assertEqual "fresh duplicate queued" Queued (workflowFinalState freshOutcome)
  assertEqual "fresh duplicate trail" [Queued] (workflowTrail freshOutcome)
  assertEqual "fresh duplicate visibility" StatusOnly (workflowVisibility freshOutcome)
  assertEqual "fresh duplicate failure summary" Nothing (workflowFailureSummary freshOutcome)
  assertEqual "fresh duplicate current action" (CurrentRetained (Just "existing-current-001")) (workflowCurrentAction freshOutcome)
  assertEqual "fresh duplicate disposition" ProcessFresh (workflowDuplicateDisposition freshOutcome)
  assertEqual "fresh duplicate completed record" Nothing (workflowCompletedRecord freshOutcome)
  assertEqual "fresh duplicate save action" Nothing (workflowSaveAction freshOutcome)
  assertEqual "fresh duplicate store" emptyExplanationStore (workflowStore freshOutcome)
  assertEqual "fresh duplicate handoff" False (workflowHandoffCompleted freshOutcome)
  assertEqual "inflight duplicate running" Running (workflowFinalState inflightOutcome)
  assertEqual "inflight duplicate code" (Just FailureDuplicateInFlight) (summaryCode <$> workflowFailureSummary inflightOutcome)
  assertEqual "inflight duplicate visibility" StatusOnly (workflowVisibility inflightOutcome)
  assertEqual "inflight duplicate current action" (CurrentRetained (Just "existing-current-001")) (workflowCurrentAction inflightOutcome)
  assertEqual "inflight duplicate completed record" Nothing (workflowCompletedRecord inflightOutcome)
  assertEqual "inflight duplicate save action" Nothing (workflowSaveAction inflightOutcome)
  assertEqual "inflight duplicate store" emptyExplanationStore (workflowStore inflightOutcome)
  assertEqual "inflight duplicate handoff" False (workflowHandoffCompleted inflightOutcome)
  assertEqual "reuse duplicate succeeded" Succeeded (workflowFinalState reuseOutcome)
  assertEqual "reuse duplicate visibility" CompletedCurrent (workflowVisibility reuseOutcome)
  assertEqual "reuse duplicate current action" (CurrentRetained (Just "existing-current-001")) (workflowCurrentAction reuseOutcome)
  assertEqual "reuse duplicate duplicate disposition" ReuseCompletedDuplicate (workflowDuplicateDisposition reuseOutcome)
  assertEqual "reuse duplicate completed record" (Just completedRecord) (workflowCompletedRecord reuseOutcome)
  assertEqual "reuse duplicate store" (ExplanationStore [("business-key-001", completedRecord)]) (workflowStore reuseOutcome)
  assertEqual "reuse duplicate save action" Nothing (workflowSaveAction reuseOutcome)
  assertEqual "reuse duplicate handoff" False (workflowHandoffCompleted reuseOutcome)

testRenderWorkflowStates :: IO ()
testRenderWorkflowStates = do
  assertEqual "queued render" "queued" (renderWorkflowState Queued)
  assertEqual "running render" "running" (renderWorkflowState Running)
  assertEqual "retry render" "retry-scheduled-1" (renderWorkflowState (RetryScheduled 1))
  assertEqual "timeout render" "timed-out-2" (renderWorkflowState (TimedOut 2))
  assertEqual "succeeded render" "succeeded" (renderWorkflowState Succeeded)
  assertEqual "failed final render" "failed-final" (renderWorkflowState FailedFinal)
  assertEqual "dead letter render" "dead-lettered" (renderWorkflowState DeadLettered)

testIntakeFailureTransition :: IO ()
testIntakeFailureTransition = do
  let ownershipOutcome =
        intakeFailureOutcome
          (ExistingCurrent "existing-current-001")
          emptyExplanationStore
          OwnershipMismatch
      invalidTargetOutcome =
        intakeFailureOutcome
          (ExistingCurrent "existing-current-001")
          emptyExplanationStore
          InvalidTarget
      preconditionOutcome =
        intakeFailureOutcome
          (ExistingCurrent "existing-current-001")
          emptyExplanationStore
          PreconditionInvalid
      unsupportedTriggerOutcome =
        intakeFailureOutcome
          (ExistingCurrent "existing-current-001")
          emptyExplanationStore
          TriggerNotSupported
      suppressedOutcome =
        intakeFailureOutcome
          (ExistingCurrent "existing-current-001")
          emptyExplanationStore
          ExplanationSuppressed
  assertEqual "dead-letter final state" DeadLettered (workflowFinalState ownershipOutcome)
  assertEqual "ownership code" (Just FailureOwnershipMismatch) (summaryCode <$> workflowFailureSummary ownershipOutcome)
  assertEqual "invalid target final state" FailedFinal (workflowFinalState invalidTargetOutcome)
  assertEqual "invalid target trail" [Queued, FailedFinal] (workflowTrail invalidTargetOutcome)
  assertEqual "invalid target visibility" StatusOnly (workflowVisibility invalidTargetOutcome)
  assertEqual "invalid target current" (CurrentRetained (Just "existing-current-001")) (workflowCurrentAction invalidTargetOutcome)
  assertEqual "invalid target duplicate" ProcessFresh (workflowDuplicateDisposition invalidTargetOutcome)
  assertEqual "invalid target completed record" Nothing (workflowCompletedRecord invalidTargetOutcome)
  assertEqual "invalid target save action" Nothing (workflowSaveAction invalidTargetOutcome)
  assertEqual "invalid target store" emptyExplanationStore (workflowStore invalidTargetOutcome)
  assertEqual "invalid target handoff" False (workflowHandoffCompleted invalidTargetOutcome)
  assertEqual "precondition code" (Just FailurePreconditionInvalid) (summaryCode <$> workflowFailureSummary preconditionOutcome)
  assertEqual "precondition final state" FailedFinal (workflowFinalState preconditionOutcome)
  assertEqual "unsupported trigger code" (Just FailureTriggerNotSupported) (summaryCode <$> workflowFailureSummary unsupportedTriggerOutcome)
  assertEqual "unsupported trigger final state" FailedFinal (workflowFinalState unsupportedTriggerOutcome)
  assertEqual "suppressed code" (Just FailureExplanationSuppressed) (summaryCode <$> workflowFailureSummary suppressedOutcome)
  assertEqual "suppressed current retained" (CurrentRetained (Just "existing-current-001")) (workflowCurrentAction suppressedOutcome)
  assertEqual "suppressed duplicate" ProcessFresh (workflowDuplicateDisposition suppressedOutcome)
  assertEqual "suppressed completed record" Nothing (workflowCompletedRecord suppressedOutcome)
  assertEqual "suppressed save action" Nothing (workflowSaveAction suppressedOutcome)
  assertEqual "suppressed store" emptyExplanationStore (workflowStore suppressedOutcome)
  assertEqual "suppressed handoff" False (workflowHandoffCompleted suppressedOutcome)

testAccessorsAndShow :: IO ()
testAccessorsAndShow = do
  let outcome =
        runGenerationOutcome
          RetryBudget {retryAttempt = 1, retryLimit = 2}
          NoCurrent
          emptyExplanationStore
          validatedWorkItem
          successfulOutcome
      retryBudget = RetryBudget {retryAttempt = 1, retryLimit = 2}
  assertEqual "workflow store accessor" 1 (length (explanationEntries (workflowStore outcome)))
  assertEqual "retry budget equality" True (retryBudget == retryBudget)
  assertEqual "workflow outcome equality" True (outcome == outcome)
  assertTrue "show retry budget" ("RetryBudget" `elem` words (show retryBudget))
  assertTrue "show workflow outcome" ("WorkflowOutcome" `elem` words (show outcome))
  assertTrue "show workflow state" ("Succeeded" `elem` words (show Succeeded))
