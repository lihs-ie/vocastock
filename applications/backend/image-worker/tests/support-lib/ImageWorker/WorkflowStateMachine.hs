module ImageWorker.WorkflowStateMachine
  ( RetryBudget (..),
    WorkflowOutcome (..),
    WorkflowState (..),
    deadLetterOutcome,
    duplicateOutcome,
    intakeFailureOutcome,
    renderWorkflowState,
    resolutionFailureOutcome,
    runImageOutcome
  )
where

import ImageWorker.AssetStoragePort
  ( AssetStorageOutcome (..),
    AssetStorageStatus (..),
    validateStoredAssetReference
  )
import ImageWorker.CurrentImageHandoff
  ( CurrentAction,
    ExistingCurrent,
    HandoffStatus (..),
    applyCurrentImageOutcome,
    retainExistingCurrent
  )
import ImageWorker.FailureSummary
  ( FailureCode (..),
    ImageFailureSummary,
    Visibility (..),
    failureSummaryFor
  )
import ImageWorker.ImageGenerationPort
  ( GenerationOutcome (..),
    GenerationStatus (..),
    validateCompletedPayload
  )
import ImageWorker.ImagePersistence
  ( CompletedImageVisibility (..),
    CompletedVisualImageRecord,
    ImageStore,
    SaveAction,
    SaveResult (..),
    existingRecordFor,
    markRecordCurrentApplied,
    markRecordRetainedNonCurrent,
    recordVisibility,
    saveCompletedImage
  )
import ImageWorker.TargetResolution
  ( CurrentPriority (..),
    ResolvedTarget (..),
    ResolutionFailure (..)
  )
import ImageWorker.WorkItemContract
  ( DuplicateDisposition (..),
    IntakeFailure (..),
    ValidatedWorkItem (..)
  )

data WorkflowState
  = Queued
  | Running
  | RetryScheduled Int
  | TimedOut Int
  | Succeeded
  | FailedFinal
  | DeadLettered
  deriving (Eq, Show)

data RetryBudget = RetryBudget
  { retryAttempt :: Int,
    retryLimit :: Int
  }
  deriving (Eq, Show)

data WorkflowOutcome = WorkflowOutcome
  { workflowTrail :: [WorkflowState],
    workflowFinalState :: WorkflowState,
    workflowVisibility :: Visibility,
    workflowFailureSummary :: Maybe ImageFailureSummary,
    workflowCurrentAction :: CurrentAction,
    workflowDuplicateDisposition :: DuplicateDisposition,
    workflowCompletedRecord :: Maybe CompletedVisualImageRecord,
    workflowSaveAction :: Maybe SaveAction,
    workflowStore :: ImageStore,
    workflowHandoffCompleted :: Bool
  }
  deriving (Eq, Show)

renderWorkflowState :: WorkflowState -> String
renderWorkflowState workflowState =
  case workflowState of
    Queued -> "queued"
    Running -> "running"
    RetryScheduled attempt -> "retry-scheduled-" ++ show attempt
    TimedOut attempt -> "timed-out-" ++ show attempt
    Succeeded -> "succeeded"
    FailedFinal -> "failed-final"
    DeadLettered -> "dead-lettered"

duplicateOutcome ::
  DuplicateDisposition ->
  ExistingCurrent ->
  ImageStore ->
  Maybe CompletedVisualImageRecord ->
  WorkflowOutcome
duplicateOutcome disposition existingCurrent imageStore maybeRecord =
  case disposition of
    ProcessFresh ->
      buildOutcome
        [Queued]
        Queued
        StatusOnly
        Nothing
        (retainExistingCurrent existingCurrent)
        ProcessFresh
        Nothing
        Nothing
        imageStore
        False
    IgnoreDuplicateInFlight ->
      buildOutcome
        [Queued, Running]
        Running
        StatusOnly
        (Just (failureSummaryFor FailureDuplicateInFlight 0))
        (retainExistingCurrent existingCurrent)
        disposition
        Nothing
        Nothing
        imageStore
        False
    ReuseCompletedDuplicate ->
      buildOutcome
        [Queued, Succeeded]
        Succeeded
        (maybe StatusOnly visibilityForRecord maybeRecord)
        Nothing
        (retainExistingCurrent existingCurrent)
        disposition
        maybeRecord
        Nothing
        imageStore
        False

intakeFailureOutcome ::
  ExistingCurrent -> ImageStore -> IntakeFailure -> WorkflowOutcome
intakeFailureOutcome existingCurrent imageStore intakeFailure =
  let failureCode =
        case intakeFailure of
          TriggerNotSupported -> FailureTriggerNotSupported
          PreconditionInvalid -> FailurePreconditionInvalid
   in buildOutcome
        [Queued, FailedFinal]
        FailedFinal
        StatusOnly
        (Just (failureSummaryFor failureCode 0))
        (retainExistingCurrent existingCurrent)
        ProcessFresh
        Nothing
        Nothing
        imageStore
        False

resolutionFailureOutcome ::
  ExistingCurrent -> ImageStore -> ResolutionFailure -> WorkflowOutcome
resolutionFailureOutcome existingCurrent imageStore resolutionFailure =
  let failureCode =
        case resolutionFailure of
          InvalidTarget -> FailureInvalidTarget
          OwnershipMismatch -> FailureOwnershipMismatch
          ExplanationNotCompleted -> FailureExplanationNotCompleted
          SenseMismatch -> FailureSenseMismatch
   in buildOutcome
        [Queued, FailedFinal]
        FailedFinal
        StatusOnly
        (Just (failureSummaryFor failureCode 0))
        (retainExistingCurrent existingCurrent)
        ProcessFresh
        Nothing
        Nothing
        imageStore
        False

deadLetterOutcome :: ExistingCurrent -> ImageStore -> WorkflowOutcome
deadLetterOutcome existingCurrent imageStore =
  buildOutcome
    [Queued, Running, DeadLettered]
    DeadLettered
    StatusOnly
    (Just (failureSummaryFor FailureOperatorReview 1))
    (retainExistingCurrent existingCurrent)
    ProcessFresh
    Nothing
    Nothing
    imageStore
    False

runImageOutcome ::
  RetryBudget ->
  ExistingCurrent ->
  ImageStore ->
  ValidatedWorkItem ->
  ResolvedTarget ->
  GenerationOutcome ->
  AssetStorageOutcome ->
  HandoffStatus ->
  WorkflowOutcome
runImageOutcome retryBudget existingCurrent imageStore validatedWorkItem resolvedTarget generationOutcome assetStorageOutcome handoffStatus =
  case outcomeStatus generationOutcome of
    GenerationSucceeded ->
      case outcomePayload generationOutcome >>= either (const Nothing) Just . validateCompletedPayload of
        Nothing ->
          terminalFailureOutcome existingCurrent imageStore FailureMalformedPayload
        Just _ ->
          runStoredImageOutcome
            retryBudget
            existingCurrent
            imageStore
            validatedWorkItem
            resolvedTarget
            assetStorageOutcome
            handoffStatus
    GenerationRetryableFailure ->
      retryableFailureOutcome retryBudget existingCurrent imageStore FailureRetryable
    GenerationTimedOut ->
      timedOutFailureOutcome retryBudget existingCurrent imageStore
    GenerationNonRetryableFailure ->
      terminalFailureOutcome existingCurrent imageStore FailureTerminal

runStoredImageOutcome ::
  RetryBudget ->
  ExistingCurrent ->
  ImageStore ->
  ValidatedWorkItem ->
  ResolvedTarget ->
  AssetStorageOutcome ->
  HandoffStatus ->
  WorkflowOutcome
runStoredImageOutcome retryBudget existingCurrent imageStore validatedWorkItem resolvedTarget assetStorageOutcome handoffStatus =
  case storageStatus assetStorageOutcome of
    AssetStorageRetryableFailure ->
      retryableFailureOutcome retryBudget existingCurrent imageStore FailureAssetStorageRetry
    AssetStorageNonRetryableFailure ->
      terminalFailureOutcome existingCurrent imageStore FailureTerminal
    AssetStored ->
      case storageReference assetStorageOutcome >>= either (const Nothing) Just . validateStoredAssetReference of
        Nothing ->
          terminalFailureOutcome existingCurrent imageStore FailureTerminal
        Just storedAssetReference ->
          let initialSave =
                saveCompletedImage
                  (validatedBusinessKey validatedWorkItem)
                  (resolvedExplanation resolvedTarget)
                  (resolvedSense resolvedTarget)
                  storedAssetReference
                  (resolvedAcceptedOrder resolvedTarget)
                  Nothing
                  imageStore
           in case resolvedCurrentPriority resolvedTarget of
                SupersededByNewerAccepted ->
                  let retainedSave =
                        markRecordRetainedNonCurrent
                          (validatedBusinessKey validatedWorkItem)
                          (saveStore initialSave)
                   in buildOutcome
                        [Queued, Running, Succeeded]
                        Succeeded
                        CompletedNonCurrent
                        Nothing
                        ( applyCurrentImageOutcome
                            (saveRecord retainedSave)
                            SupersededByNewerAccepted
                            existingCurrent
                            HandoffApplied
                        )
                        ProcessFresh
                        (Just (saveRecord retainedSave))
                        (Just (saveAction retainedSave))
                        (saveStore retainedSave)
                        False
                OwnsCurrentAdoption ->
                  case handoffStatus of
                    HandoffApplied ->
                      let (currentRecord, currentStore) =
                            markRecordCurrentApplied
                              (validatedBusinessKey validatedWorkItem)
                              (saveStore initialSave)
                       in buildOutcome
                            [Queued, Running, Succeeded]
                            Succeeded
                            CompletedCurrent
                            Nothing
                            ( applyCurrentImageOutcome
                                currentRecord
                                OwnsCurrentAdoption
                                existingCurrent
                                HandoffApplied
                            )
                            ProcessFresh
                            (Just currentRecord)
                            (Just (saveAction initialSave))
                            currentStore
                            True
                    HandoffRetryableFailure ->
                      buildOutcome
                        [Queued, Running, RetryScheduled (retryAttempt retryBudget)]
                        (RetryScheduled (retryAttempt retryBudget))
                        StatusOnly
                        (Just (failureSummaryFor FailureHandoffRetry (retryAttempt retryBudget)))
                        (retainExistingCurrent existingCurrent)
                        ProcessFresh
                        (Just (saveRecord initialSave))
                        (Just (saveAction initialSave))
                        (saveStore initialSave)
                        False

retryableFailureOutcome ::
  RetryBudget ->
  ExistingCurrent ->
  ImageStore ->
  FailureCode ->
  WorkflowOutcome
retryableFailureOutcome retryBudget existingCurrent imageStore failureCode =
  buildOutcome
    [Queued, Running, RetryScheduled (retryAttempt retryBudget)]
    (RetryScheduled (retryAttempt retryBudget))
    StatusOnly
    (Just (failureSummaryFor failureCode (retryAttempt retryBudget)))
    (retainExistingCurrent existingCurrent)
    ProcessFresh
    Nothing
    Nothing
    imageStore
    False

timedOutFailureOutcome ::
  RetryBudget -> ExistingCurrent -> ImageStore -> WorkflowOutcome
timedOutFailureOutcome retryBudget existingCurrent imageStore
  | retryAttempt retryBudget < retryLimit retryBudget =
      buildOutcome
        [Queued, Running, TimedOut (retryAttempt retryBudget), RetryScheduled (retryAttempt retryBudget)]
        (RetryScheduled (retryAttempt retryBudget))
        StatusOnly
        (Just (failureSummaryFor FailureTimedOut (retryAttempt retryBudget)))
        (retainExistingCurrent existingCurrent)
        ProcessFresh
        Nothing
        Nothing
        imageStore
        False
  | otherwise =
      buildOutcome
        [Queued, Running, TimedOut (retryAttempt retryBudget), FailedFinal]
        FailedFinal
        StatusOnly
        (Just (failureSummaryFor FailureTimedOut (retryAttempt retryBudget)))
        (retainExistingCurrent existingCurrent)
        ProcessFresh
        Nothing
        Nothing
        imageStore
        False

terminalFailureOutcome ::
  ExistingCurrent -> ImageStore -> FailureCode -> WorkflowOutcome
terminalFailureOutcome existingCurrent imageStore failureCode =
  buildOutcome
    [Queued, Running, FailedFinal]
    FailedFinal
    StatusOnly
    (Just (failureSummaryFor failureCode 1))
    (retainExistingCurrent existingCurrent)
    ProcessFresh
    Nothing
    Nothing
    imageStore
    False

visibilityForRecord :: CompletedVisualImageRecord -> Visibility
visibilityForRecord completedVisualImageRecord =
  case recordVisibility completedVisualImageRecord of
    HiddenUntilHandoff -> StatusOnly
    CurrentApplied -> CompletedCurrent
    RetainedNonCurrent -> CompletedNonCurrent

buildOutcome ::
  [WorkflowState] ->
  WorkflowState ->
  Visibility ->
  Maybe ImageFailureSummary ->
  CurrentAction ->
  DuplicateDisposition ->
  Maybe CompletedVisualImageRecord ->
  Maybe SaveAction ->
  ImageStore ->
  Bool ->
  WorkflowOutcome
buildOutcome
  workflowTrailValue
  workflowFinalStateValue
  workflowVisibilityValue
  workflowFailureSummaryValue
  workflowCurrentActionValue
  workflowDuplicateDispositionValue
  workflowCompletedRecordValue
  workflowSaveActionValue
  workflowStoreValue
  workflowHandoffCompletedValue =
    WorkflowOutcome
      { workflowTrail = workflowTrailValue,
        workflowFinalState = workflowFinalStateValue,
        workflowVisibility = workflowVisibilityValue,
        workflowFailureSummary = workflowFailureSummaryValue,
        workflowCurrentAction = workflowCurrentActionValue,
        workflowDuplicateDisposition = workflowDuplicateDispositionValue,
        workflowCompletedRecord = workflowCompletedRecordValue,
        workflowSaveAction = workflowSaveActionValue,
        workflowStore = workflowStoreValue,
        workflowHandoffCompleted = workflowHandoffCompletedValue
      }
