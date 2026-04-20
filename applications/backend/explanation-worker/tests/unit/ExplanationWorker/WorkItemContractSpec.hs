module ExplanationWorker.WorkItemContractSpec (run) where

import ExplanationWorker.WorkItemContract
import TestSupport

run :: IO ()
run = do
  runNamed "accepts valid registration work item" testAcceptsValidWorkItem
  runNamed "rejects suppressed explanation work" testRejectsSuppressedWorkItem
  runNamed "rejects unsupported trigger" testRejectsUnsupportedTrigger
  runNamed "rejects invalid target and ownership mismatch" testRejectsTargetAndOwnership
  runNamed "rejects missing fields and invalid preconditions" testRejectsPreconditions
  runNamed "maps duplicate statuses" testMapsDuplicateStatuses
  runNamed "renders failure and duplicate labels" testRendersLabels
  runNamed "covers accessors and show instances" testAccessorsAndShow

testAcceptsValidWorkItem :: IO ()
testAcceptsValidWorkItem =
  case validateWorkItem defaultWorkItem of
    Left failure -> error ("unexpected failure: " ++ renderIntakeFailure failure)
    Right validated -> do
      assertEqual "business key" "business-key-001" (validatedBusinessKey validated)
      assertEqual "vocabulary expression" "vocabulary-expression-001" (validatedVocabularyExpression validated)
      assertEqual "learner" "learner-001" (validatedLearner validated)
      assertEqual "normalized text" "look up" (validatedNormalizedVocabularyExpressionText validated)
      assertEqual "request correlation" "correlation-001" (validatedRequestCorrelation validated)

testRejectsSuppressedWorkItem :: IO ()
testRejectsSuppressedWorkItem =
  assertEqual
    "suppressed work item"
    (Left ExplanationSuppressed)
    (validateWorkItem defaultWorkItem {workStartExplanation = False})

testRejectsUnsupportedTrigger :: IO ()
testRejectsUnsupportedTrigger =
  assertEqual
    "unsupported trigger"
    (Left TriggerNotSupported)
    ( validateWorkItem
        defaultWorkItem
          { workTrigger = UnsupportedTrigger "manual-retry"
          }
    )

testRejectsTargetAndOwnership :: IO ()
testRejectsTargetAndOwnership = do
  assertEqual
    "invalid target"
    (Left InvalidTarget)
    (validateWorkItem defaultWorkItem {workTargetExists = False})
  assertEqual
    "ownership mismatch"
    (Left OwnershipMismatch)
    (validateWorkItem defaultWorkItem {workOwnershipMatches = False})

testRejectsPreconditions :: IO ()
testRejectsPreconditions = do
  assertEqual
    "missing request correlation"
    (Left PreconditionInvalid)
    (validateWorkItem defaultWorkItem {workRequestCorrelation = ""})
  assertEqual
    "explicit precondition invalid"
    (Left PreconditionInvalid)
    (validateWorkItem defaultWorkItem {workPreconditionValid = False})

testMapsDuplicateStatuses :: IO ()
testMapsDuplicateStatuses = do
  assertEqual "absent duplicate" ProcessFresh (duplicateDisposition DuplicateAbsent)
  assertEqual "queued duplicate" IgnoreDuplicateInFlight (duplicateDisposition DuplicateQueued)
  assertEqual "running duplicate" IgnoreDuplicateInFlight (duplicateDisposition DuplicateRunning)
  assertEqual "retry duplicate" IgnoreDuplicateInFlight (duplicateDisposition DuplicateRetryScheduled)
  assertEqual "completed duplicate" ReuseCompletedDuplicate (duplicateDisposition DuplicateSucceeded)

testRendersLabels :: IO ()
testRendersLabels = do
  assertEqual "trigger failure" "trigger-not-supported" (renderIntakeFailure TriggerNotSupported)
  assertEqual "suppressed failure" "start-explanation-suppressed" (renderIntakeFailure ExplanationSuppressed)
  assertEqual "invalid target failure" "invalid-target" (renderIntakeFailure InvalidTarget)
  assertEqual "ownership failure" "ownership-mismatch" (renderIntakeFailure OwnershipMismatch)
  assertEqual "precondition failure" "precondition-invalid" (renderIntakeFailure PreconditionInvalid)
  assertEqual "fresh duplicate" "fresh" (renderDuplicateDisposition ProcessFresh)
  assertEqual "inflight duplicate" "inflight-noop" (renderDuplicateDisposition IgnoreDuplicateInFlight)
  assertEqual "reuse duplicate" "reuse-completed" (renderDuplicateDisposition ReuseCompletedDuplicate)

testAccessorsAndShow :: IO ()
testAccessorsAndShow =
  case validateWorkItem defaultWorkItem of
    Left failure -> error ("unexpected failure: " ++ renderIntakeFailure failure)
    Right validated -> do
      assertEqual "trigger accessor" RegistrationAccepted (workTrigger defaultWorkItem)
      assertEqual "business key accessor" "business-key-001" (workBusinessKey defaultWorkItem)
      assertEqual "vocabulary accessor" "vocabulary-expression-001" (workVocabularyExpression defaultWorkItem)
      assertEqual "learner accessor" "learner-001" (workLearner defaultWorkItem)
      assertEqual "normalized accessor" "look up" (workNormalizedVocabularyExpressionText defaultWorkItem)
      assertEqual "correlation accessor" "correlation-001" (workRequestCorrelation defaultWorkItem)
      assertEqual "start explanation accessor" True (workStartExplanation defaultWorkItem)
      assertEqual "target exists accessor" True (workTargetExists defaultWorkItem)
      assertEqual "ownership accessor" True (workOwnershipMatches defaultWorkItem)
      assertEqual "precondition accessor" True (workPreconditionValid defaultWorkItem)
      assertEqual "validated equality" True (validated == validated)
      assertEqual "work item equality" True (defaultWorkItem == defaultWorkItem)
      assertEqual "trigger equality" True (RegistrationAccepted == RegistrationAccepted)
      assertEqual "intake failure equality" True (TriggerNotSupported == TriggerNotSupported)
      assertEqual "duplicate status equality" True (DuplicateQueued == DuplicateQueued)
      assertEqual "duplicate disposition equality" True (ProcessFresh == ProcessFresh)
      assertEqual "show registration trigger" "RegistrationAccepted" (show RegistrationAccepted)
      assertEqual "show trigger" "UnsupportedTrigger \"manual\"" (show (UnsupportedTrigger "manual"))
      assertTrue "show work item" ("WorkItem" `elem` words (show defaultWorkItem))
      assertTrue "show validated" ("ValidatedWorkItem" `elem` words (show validated))
      assertEqual "show intake failure" "OwnershipMismatch" (show OwnershipMismatch)
      assertEqual "show duplicate status" "DuplicateQueued" (show DuplicateQueued)
      assertEqual "show duplicate disposition" "ReuseCompletedDuplicate" (show ReuseCompletedDuplicate)
