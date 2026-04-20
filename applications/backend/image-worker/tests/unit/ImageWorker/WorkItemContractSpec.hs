module ImageWorker.WorkItemContractSpec (run) where

import ImageWorker.WorkItemContract
import TestSupport

run :: IO ()
run = do
  runNamed "accepts valid image generation work item" testAcceptsValidWorkItem
  runNamed "rejects unsupported trigger" testRejectsUnsupportedTrigger
  runNamed "rejects missing fields and invalid accepted order" testRejectsPreconditions
  runNamed "maps duplicate statuses" testMapsDuplicateStatuses
  runNamed "renders intake and duplicate labels" testRendersLabels
  runNamed "covers accessors and show instances" testAccessorsAndShow

testAcceptsValidWorkItem :: IO ()
testAcceptsValidWorkItem =
  case validateWorkItem defaultWorkItem of
    Left intakeFailure -> error ("unexpected failure: " ++ renderIntakeFailure intakeFailure)
    Right validatedWorkItem -> do
      assertEqual "identifier" "image-work-item-001" (validatedIdentifier validatedWorkItem)
      assertEqual "business key" "image-business-key-001" (validatedBusinessKey validatedWorkItem)
      assertEqual "explanation" "explanation-001" (validatedExplanation validatedWorkItem)
      assertEqual "learner" "learner-001" (validatedLearner validatedWorkItem)
      assertEqual "sense" (Just "sense-001") (validatedSense validatedWorkItem)
      assertEqual "reason" "request-image-generation-accepted" (validatedReason validatedWorkItem)
      assertEqual "correlation" "correlation-001" (validatedRequestCorrelation validatedWorkItem)
      assertEqual "accepted order" 3 (validatedAcceptedOrder validatedWorkItem)

testRejectsUnsupportedTrigger :: IO ()
testRejectsUnsupportedTrigger =
  assertEqual
    "unsupported trigger"
    (Left TriggerNotSupported)
    (validateWorkItem defaultWorkItem {workTrigger = UnsupportedTrigger "manual-retry"})

testRejectsPreconditions :: IO ()
testRejectsPreconditions = do
  assertEqual
    "missing request correlation"
    (Left PreconditionInvalid)
    (validateWorkItem defaultWorkItem {workRequestCorrelation = ""})
  assertEqual
    "invalid accepted order"
    (Left PreconditionInvalid)
    (validateWorkItem defaultWorkItem {workAcceptedOrder = 0})

testMapsDuplicateStatuses :: IO ()
testMapsDuplicateStatuses = do
  assertEqual "absent duplicate" ProcessFresh (duplicateDisposition DuplicateAbsent)
  assertEqual "queued duplicate" IgnoreDuplicateInFlight (duplicateDisposition DuplicateQueued)
  assertEqual "running duplicate" IgnoreDuplicateInFlight (duplicateDisposition DuplicateRunning)
  assertEqual "retry duplicate" IgnoreDuplicateInFlight (duplicateDisposition DuplicateRetryScheduled)
  assertEqual "completed duplicate" ReuseCompletedDuplicate (duplicateDisposition DuplicateSucceeded)

testRendersLabels :: IO ()
testRendersLabels = do
  assertEqual "trigger label" "trigger-not-supported" (renderIntakeFailure TriggerNotSupported)
  assertEqual "precondition label" "precondition-invalid" (renderIntakeFailure PreconditionInvalid)
  assertEqual "fresh duplicate" "fresh" (renderDuplicateDisposition ProcessFresh)
  assertEqual "inflight duplicate" "inflight-noop" (renderDuplicateDisposition IgnoreDuplicateInFlight)
  assertEqual "reuse duplicate" "reuse-completed" (renderDuplicateDisposition ReuseCompletedDuplicate)

testAccessorsAndShow :: IO ()
testAccessorsAndShow =
  case validateWorkItem defaultWorkItem of
    Left intakeFailure -> error ("unexpected failure: " ++ renderIntakeFailure intakeFailure)
    Right validatedWorkItem -> do
      assertEqual "trigger accessor" RequestImageGenerationAccepted (workTrigger defaultWorkItem)
      assertEqual "identifier accessor" "image-work-item-001" (workIdentifier defaultWorkItem)
      assertEqual "business key accessor" "image-business-key-001" (workBusinessKey defaultWorkItem)
      assertEqual "explanation accessor" "explanation-001" (workExplanation defaultWorkItem)
      assertEqual "learner accessor" "learner-001" (workLearner defaultWorkItem)
      assertEqual "sense accessor" (Just "sense-001") (workSense defaultWorkItem)
      assertEqual "reason accessor" "request-image-generation-accepted" (workReason defaultWorkItem)
      assertEqual "correlation accessor" "correlation-001" (workRequestCorrelation defaultWorkItem)
      assertEqual "accepted order accessor" 3 (workAcceptedOrder defaultWorkItem)
      assertEqual "validated equality" True (validatedWorkItem == validatedWorkItem)
      assertEqual "show trigger" "RequestImageGenerationAccepted" (show RequestImageGenerationAccepted)
      assertEqual "show intake failure" "PreconditionInvalid" (show PreconditionInvalid)
      assertEqual "show duplicate status" "DuplicateQueued" (show DuplicateQueued)
      assertEqual "show duplicate disposition" "ReuseCompletedDuplicate" (show ReuseCompletedDuplicate)
