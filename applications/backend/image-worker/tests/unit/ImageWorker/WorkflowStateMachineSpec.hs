module ImageWorker.WorkflowStateMachineSpec (run) where

import ImageWorker.AssetStoragePort
import ImageWorker.CurrentImageHandoff
import ImageWorker.FailureSummary
import ImageWorker.ImageGenerationPort
import ImageWorker.ImagePersistence
import ImageWorker.TargetResolution
import ImageWorker.WorkflowStateMachine
import ImageWorker.WorkItemContract
import TestSupport

run :: IO ()
run = do
  runNamed "transitions queued to succeeded" testSuccessTransition
  runNamed "retains stale success as non-current" testStaleSuccessTransition
  runNamed "keeps saved candidate on handoff retry" testHandoffRetryTransition
  runNamed "keeps current on retryable failure and timeout" testRetryAndTimeoutTransitions
  runNamed "maps asset storage retry and invalid asset references" testAssetStorageTransitions
  runNamed "maps terminal and dead-letter failures" testTerminalAndDeadLetterTransitions
  runNamed "maps duplicate paths" testDuplicateTransitions
  runNamed "maps intake and resolution failures" testValidationFailureTransitions
  runNamed "renders workflow states" testRenderWorkflowStates
  runNamed "covers workflow accessors and show instances" testAccessorsAndShow

validatedWorkItem :: ValidatedWorkItem
validatedWorkItem =
  case validateWorkItem defaultWorkItem of
    Left intakeFailure -> error ("unexpected validation failure: " ++ renderIntakeFailure intakeFailure)
    Right value -> value

resolvedTarget :: ResolvedTarget
resolvedTarget =
  case resolveTarget validatedWorkItem defaultTargetContext of
    Left resolutionFailure -> error ("unexpected resolution failure: " ++ renderResolutionFailure resolutionFailure)
    Right value -> value

testSuccessTransition :: IO ()
testSuccessTransition = do
  let outcome =
        runImageOutcome
          RetryBudget {retryAttempt = 1, retryLimit = 2}
          NoCurrent
          emptyImageStore
          validatedWorkItem
          resolvedTarget
          successfulOutcome
          stableStoredAsset
          HandoffApplied
  assertEqual "final state" Succeeded (workflowFinalState outcome)
  assertEqual "trail" [Queued, Running, Succeeded] (workflowTrail outcome)
  assertEqual "visibility" CompletedCurrent (workflowVisibility outcome)
  assertEqual "save action" (Just SaveCreated) (workflowSaveAction outcome)
  assertEqual "current action" (CurrentSwitched "image-business-key-001-image") (workflowCurrentAction outcome)
  assertEqual "record visibility" (Just CurrentApplied) (recordVisibility <$> workflowCompletedRecord outcome)
  assertTrue "handoff completed" (workflowHandoffCompleted outcome)

testStaleSuccessTransition :: IO ()
testStaleSuccessTransition = do
  let staleTarget = resolvedTarget {resolvedCurrentPriority = SupersededByNewerAccepted}
      outcome =
        runImageOutcome
          RetryBudget {retryAttempt = 1, retryLimit = 2}
          (ExistingCurrent "existing-current-image-001")
          emptyImageStore
          validatedWorkItem
          staleTarget
          successfulOutcome
          stableStoredAsset
          HandoffApplied
  assertEqual "final state" Succeeded (workflowFinalState outcome)
  assertEqual "visibility" CompletedNonCurrent (workflowVisibility outcome)
  assertEqual "save action" (Just SaveRetainedNonCurrent) (workflowSaveAction outcome)
  assertEqual "current action" "superseded-by-newer-request" (renderCurrentAction (workflowCurrentAction outcome))
  assertEqual "record visibility" (Just RetainedNonCurrent) (recordVisibility <$> workflowCompletedRecord outcome)
  assertEqual "handoff completed" False (workflowHandoffCompleted outcome)

testHandoffRetryTransition :: IO ()
testHandoffRetryTransition = do
  let outcome =
        runImageOutcome
          RetryBudget {retryAttempt = 1, retryLimit = 2}
          (ExistingCurrent "existing-current-image-001")
          emptyImageStore
          validatedWorkItem
          resolvedTarget
          successfulOutcome
          stableStoredAsset
          HandoffRetryableFailure
  assertEqual "final state" (RetryScheduled 1) (workflowFinalState outcome)
  assertEqual "visibility" StatusOnly (workflowVisibility outcome)
  assertEqual "failure code" (Just FailureHandoffRetry) (summaryCode <$> workflowFailureSummary outcome)
  assertEqual "current retained" (CurrentRetained (Just "existing-current-image-001")) (workflowCurrentAction outcome)
  assertEqual "record visibility" (Just HiddenUntilHandoff) (recordVisibility <$> workflowCompletedRecord outcome)
  assertEqual "handoff completed" False (workflowHandoffCompleted outcome)

testRetryAndTimeoutTransitions :: IO ()
testRetryAndTimeoutTransitions = do
  let retryableOutcome =
        runImageOutcome
          RetryBudget {retryAttempt = 1, retryLimit = 2}
          (ExistingCurrent "existing-current-image-001")
          emptyImageStore
          validatedWorkItem
          resolvedTarget
          retryableFailureOutcome
          stableStoredAsset
          HandoffApplied
      timedOutRetryOutcome =
        runImageOutcome
          RetryBudget {retryAttempt = 1, retryLimit = 2}
          (ExistingCurrent "existing-current-image-001")
          emptyImageStore
          validatedWorkItem
          resolvedTarget
          timedOutOutcome
          stableStoredAsset
          HandoffApplied
      timedOutFinalOutcome =
        runImageOutcome
          RetryBudget {retryAttempt = 2, retryLimit = 2}
          (ExistingCurrent "existing-current-image-001")
          emptyImageStore
          validatedWorkItem
          resolvedTarget
          timedOutOutcome
          stableStoredAsset
          HandoffApplied
  assertEqual "retryable state" (RetryScheduled 1) (workflowFinalState retryableOutcome)
  assertEqual "retryable code" (Just FailureRetryable) (summaryCode <$> workflowFailureSummary retryableOutcome)
  assertEqual "timed out retry state" (RetryScheduled 1) (workflowFinalState timedOutRetryOutcome)
  assertEqual "timed out retry trail" [Queued, Running, TimedOut 1, RetryScheduled 1] (workflowTrail timedOutRetryOutcome)
  assertEqual "timed out final state" FailedFinal (workflowFinalState timedOutFinalOutcome)
  assertEqual "timed out final code" (Just FailureTimedOut) (summaryCode <$> workflowFailureSummary timedOutFinalOutcome)

testAssetStorageTransitions :: IO ()
testAssetStorageTransitions = do
  let assetRetryOutcome =
        runImageOutcome
          RetryBudget {retryAttempt = 1, retryLimit = 2}
          (ExistingCurrent "existing-current-image-001")
          emptyImageStore
          validatedWorkItem
          resolvedTarget
          successfulOutcome
          retryableAssetStorageFailure
          HandoffApplied
      invalidStoredAssetOutcome =
        runImageOutcome
          RetryBudget {retryAttempt = 1, retryLimit = 2}
          (ExistingCurrent "existing-current-image-001")
          emptyImageStore
          validatedWorkItem
          resolvedTarget
          successfulOutcome
          stableStoredAsset
            { storageReference =
                Just
                  StoredAssetReference
                    { assetReference = "",
                      assetChecksum = ""
                    }
            }
          HandoffApplied
  assertEqual "asset retry state" (RetryScheduled 1) (workflowFinalState assetRetryOutcome)
  assertEqual "asset retry code" (Just FailureAssetStorageRetry) (summaryCode <$> workflowFailureSummary assetRetryOutcome)
  assertEqual "invalid stored asset state" FailedFinal (workflowFinalState invalidStoredAssetOutcome)
  assertEqual "invalid stored asset code" (Just FailureTerminal) (summaryCode <$> workflowFailureSummary invalidStoredAssetOutcome)

testTerminalAndDeadLetterTransitions :: IO ()
testTerminalAndDeadLetterTransitions = do
  let malformedOutcome =
        runImageOutcome
          RetryBudget {retryAttempt = 1, retryLimit = 2}
          (ExistingCurrent "existing-current-image-001")
          emptyImageStore
          validatedWorkItem
          resolvedTarget
          malformedSuccessOutcome
          stableStoredAsset
          HandoffApplied
      storageTerminalOutcome =
        runImageOutcome
          RetryBudget {retryAttempt = 1, retryLimit = 2}
          (ExistingCurrent "existing-current-image-001")
          emptyImageStore
          validatedWorkItem
          resolvedTarget
          successfulOutcome
          nonRetryableAssetStorageFailure
          HandoffApplied
      deadLettered =
        deadLetterOutcome
          (ExistingCurrent "existing-current-image-001")
          emptyImageStore
  assertEqual "malformed final state" FailedFinal (workflowFinalState malformedOutcome)
  assertEqual "malformed code" (Just FailureMalformedPayload) (summaryCode <$> workflowFailureSummary malformedOutcome)
  assertEqual "storage terminal state" FailedFinal (workflowFinalState storageTerminalOutcome)
  assertEqual "storage terminal code" (Just FailureTerminal) (summaryCode <$> workflowFailureSummary storageTerminalOutcome)
  assertEqual "dead letter state" DeadLettered (workflowFinalState deadLettered)
  assertEqual "dead letter code" (Just FailureOperatorReview) (summaryCode <$> workflowFailureSummary deadLettered)

testDuplicateTransitions :: IO ()
testDuplicateTransitions = do
  let completedRecord =
        completedRecordFor
          "image-business-key-001"
          "explanation-001"
          (Just "sense-001")
          StoredAssetReference
            { assetReference = "gs://vocastock/images/image-business-key-001.png",
              assetChecksum = "checksum-001"
            }
          3
          Nothing
      freshOutcome =
        duplicateOutcome ProcessFresh (ExistingCurrent "existing-current-image-001") emptyImageStore Nothing
      inflightOutcome =
        duplicateOutcome IgnoreDuplicateInFlight (ExistingCurrent "existing-current-image-001") emptyImageStore Nothing
      reuseOutcome =
        duplicateOutcome
          ReuseCompletedDuplicate
          (ExistingCurrent "existing-current-image-001")
          (ImageStore [("image-business-key-001", completedRecord {recordVisibility = CurrentApplied})])
          (Just completedRecord {recordVisibility = CurrentApplied})
      retainedOutcome =
        duplicateOutcome
          ReuseCompletedDuplicate
          (ExistingCurrent "existing-current-image-001")
          (ImageStore [("image-business-key-001", completedRecord {recordVisibility = RetainedNonCurrent})])
          (Just completedRecord {recordVisibility = RetainedNonCurrent})
      hiddenOutcome =
        duplicateOutcome
          ReuseCompletedDuplicate
          (ExistingCurrent "existing-current-image-001")
          (ImageStore [("image-business-key-001", completedRecord {recordVisibility = HiddenUntilHandoff})])
          (Just completedRecord {recordVisibility = HiddenUntilHandoff})
  assertEqual "fresh final state" Queued (workflowFinalState freshOutcome)
  assertEqual "inflight final state" Running (workflowFinalState inflightOutcome)
  assertEqual "inflight failure" (Just FailureDuplicateInFlight) (summaryCode <$> workflowFailureSummary inflightOutcome)
  assertEqual "reuse final state" Succeeded (workflowFinalState reuseOutcome)
  assertEqual "reuse visibility" CompletedCurrent (workflowVisibility reuseOutcome)
  assertEqual "reuse record" True (maybe False (const True) (workflowCompletedRecord reuseOutcome))
  assertEqual "retained reuse visibility" CompletedNonCurrent (workflowVisibility retainedOutcome)
  assertEqual "hidden reuse visibility" StatusOnly (workflowVisibility hiddenOutcome)

testValidationFailureTransitions :: IO ()
testValidationFailureTransitions = do
  let intakeOutcome =
        intakeFailureOutcome
          (ExistingCurrent "existing-current-image-001")
          emptyImageStore
          PreconditionInvalid
      triggerOutcome =
        intakeFailureOutcome
          (ExistingCurrent "existing-current-image-001")
          emptyImageStore
          TriggerNotSupported
      invalidTargetOutcome =
        resolutionFailureOutcome
          (ExistingCurrent "existing-current-image-001")
          emptyImageStore
          InvalidTarget
      ownershipOutcome =
        resolutionFailureOutcome
          (ExistingCurrent "existing-current-image-001")
          emptyImageStore
          OwnershipMismatch
      incompleteOutcome =
        resolutionFailureOutcome
          (ExistingCurrent "existing-current-image-001")
          emptyImageStore
          ExplanationNotCompleted
      senseOutcome =
        resolutionFailureOutcome
          (ExistingCurrent "existing-current-image-001")
          emptyImageStore
          SenseMismatch
  assertEqual "intake state" FailedFinal (workflowFinalState intakeOutcome)
  assertEqual "intake code" (Just FailurePreconditionInvalid) (summaryCode <$> workflowFailureSummary intakeOutcome)
  assertEqual "trigger code" (Just FailureTriggerNotSupported) (summaryCode <$> workflowFailureSummary triggerOutcome)
  assertEqual "invalid target code" (Just FailureInvalidTarget) (summaryCode <$> workflowFailureSummary invalidTargetOutcome)
  assertEqual "ownership code" (Just FailureOwnershipMismatch) (summaryCode <$> workflowFailureSummary ownershipOutcome)
  assertEqual "incomplete code" (Just FailureExplanationNotCompleted) (summaryCode <$> workflowFailureSummary incompleteOutcome)
  assertEqual "sense code" (Just FailureSenseMismatch) (summaryCode <$> workflowFailureSummary senseOutcome)

testRenderWorkflowStates :: IO ()
testRenderWorkflowStates = do
  assertEqual "queued label" "queued" (renderWorkflowState Queued)
  assertEqual "running label" "running" (renderWorkflowState Running)
  assertEqual "retry label" "retry-scheduled-1" (renderWorkflowState (RetryScheduled 1))
  assertEqual "timed out label" "timed-out-2" (renderWorkflowState (TimedOut 2))
  assertEqual "succeeded label" "succeeded" (renderWorkflowState Succeeded)
  assertEqual "failed label" "failed-final" (renderWorkflowState FailedFinal)
  assertEqual "dead letter label" "dead-lettered" (renderWorkflowState DeadLettered)

testAccessorsAndShow :: IO ()
testAccessorsAndShow = do
  let outcome =
        runImageOutcome
          RetryBudget {retryAttempt = 1, retryLimit = 2}
          NoCurrent
          emptyImageStore
          validatedWorkItem
          resolvedTarget
          successfulOutcome
          stableStoredAsset
          HandoffApplied
  assertEqual "workflow equality" True (outcome == outcome)
  assertEqual "retry budget equality" True (RetryBudget 1 2 == RetryBudget 1 2)
  assertEqual "show workflow state" "Succeeded" (show Succeeded)
  assertEqual "show retry budget" "RetryBudget {retryAttempt = 1, retryLimit = 2}" (show (RetryBudget 1 2))
  assertEqual "show outcome" True ("WorkflowOutcome" `elem` words (show outcome))
