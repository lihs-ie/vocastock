module ExplanationWorker.WorkflowStateMachine
  ( RetryBudget (..),
    WorkflowOutcome (..),
    WorkflowState (..),
    duplicateOutcome,
    intakeFailureOutcome,
    renderWorkflowState,
    runGenerationOutcome,
    successOutcome
  )
where

import ExplanationWorker.CurrentExplanationHandoff
  ( CurrentAction,
    ExistingCurrent,
    applyCurrentExplanationSuccess,
    retainExistingCurrent
  )
import ExplanationWorker.ExplanationPersistence
  ( CompletedExplanationRecord,
    ExplanationStore,
    SaveAction,
    SaveResult (..),
    existingRecordFor,
    saveCompletedExplanation
  )
import ExplanationWorker.FailureSummary
  ( ExplanationFailureSummary,
    FailureCode (..),
    Visibility (..),
    failureSummaryFor
  )
import ExplanationWorker.GenerationPort
  ( GenerationOutcome (..),
    GenerationStatus (..),
    validateCompletedPayload
  )
import ExplanationWorker.WorkItemContract
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
    workflowFailureSummary :: Maybe ExplanationFailureSummary,
    workflowCurrentAction :: CurrentAction,
    workflowDuplicateDisposition :: DuplicateDisposition,
    workflowCompletedRecord :: Maybe CompletedExplanationRecord,
    workflowSaveAction :: Maybe SaveAction,
    workflowStore :: ExplanationStore,
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

successOutcome :: ExistingCurrent -> SaveResult -> WorkflowOutcome
successOutcome existingCurrent saveResult =
  WorkflowOutcome
    { workflowTrail = [Queued, Running, Succeeded],
      workflowFinalState = Succeeded,
      workflowVisibility = CompletedCurrent,
      workflowFailureSummary = Nothing,
      workflowCurrentAction =
        applyCurrentExplanationSuccess (saveRecord saveResult) existingCurrent,
      workflowDuplicateDisposition = ProcessFresh,
      workflowCompletedRecord = Just (saveRecord saveResult),
      workflowSaveAction = Just (saveAction saveResult),
      workflowStore = saveStore saveResult,
      workflowHandoffCompleted = True
    }

duplicateOutcome ::
  DuplicateDisposition ->
  ExistingCurrent ->
  ExplanationStore ->
  Maybe CompletedExplanationRecord ->
  WorkflowOutcome
duplicateOutcome disposition existingCurrent store maybeRecord =
  case disposition of
    ProcessFresh ->
      WorkflowOutcome
        { workflowTrail = [Queued],
          workflowFinalState = Queued,
          workflowVisibility = StatusOnly,
          workflowFailureSummary = Nothing,
          workflowCurrentAction = retainExistingCurrent existingCurrent,
          workflowDuplicateDisposition = ProcessFresh,
          workflowCompletedRecord = Nothing,
          workflowSaveAction = Nothing,
          workflowStore = store,
          workflowHandoffCompleted = False
        }
    IgnoreDuplicateInFlight ->
      WorkflowOutcome
        { workflowTrail = [Queued, Running],
          workflowFinalState = Running,
          workflowVisibility = StatusOnly,
          workflowFailureSummary = Just (failureSummaryFor FailureDuplicateInFlight),
          workflowCurrentAction = retainExistingCurrent existingCurrent,
          workflowDuplicateDisposition = disposition,
          workflowCompletedRecord = Nothing,
          workflowSaveAction = Nothing,
          workflowStore = store,
          workflowHandoffCompleted = False
        }
    ReuseCompletedDuplicate ->
      WorkflowOutcome
        { workflowTrail = [Queued, Succeeded],
          workflowFinalState = Succeeded,
          workflowVisibility = CompletedCurrent,
          workflowFailureSummary = Nothing,
          workflowCurrentAction = retainExistingCurrent existingCurrent,
          workflowDuplicateDisposition = disposition,
          workflowCompletedRecord = maybeRecord,
          workflowSaveAction = Nothing,
          workflowStore = store,
          workflowHandoffCompleted = False
        }

intakeFailureOutcome ::
  ExistingCurrent -> ExplanationStore -> IntakeFailure -> WorkflowOutcome
intakeFailureOutcome existingCurrent store intakeFailure =
  let (finalState, failureCode) =
        case intakeFailure of
          InvalidTarget -> (FailedFinal, FailureInvalidTarget)
          OwnershipMismatch -> (DeadLettered, FailureOwnershipMismatch)
          PreconditionInvalid -> (FailedFinal, FailurePreconditionInvalid)
          TriggerNotSupported -> (FailedFinal, FailureTriggerNotSupported)
          ExplanationSuppressed -> (FailedFinal, FailureExplanationSuppressed)
   in WorkflowOutcome
        { workflowTrail = [Queued, finalState],
          workflowFinalState = finalState,
          workflowVisibility = StatusOnly,
          workflowFailureSummary = Just (failureSummaryFor failureCode),
          workflowCurrentAction = retainExistingCurrent existingCurrent,
          workflowDuplicateDisposition = ProcessFresh,
          workflowCompletedRecord = Nothing,
          workflowSaveAction = Nothing,
          workflowStore = store,
          workflowHandoffCompleted = False
        }

runGenerationOutcome ::
  RetryBudget ->
  ExistingCurrent ->
  ExplanationStore ->
  ValidatedWorkItem ->
  GenerationOutcome ->
  WorkflowOutcome
runGenerationOutcome retryBudget existingCurrent store validatedWorkItem generationOutcome =
  case outcomeStatus generationOutcome of
    GenerationSucceeded ->
      case outcomePayload generationOutcome >>= either (const Nothing) Just . validateCompletedPayload of
        Just payload ->
          let saveResult =
                saveCompletedExplanation
                  (validatedBusinessKey validatedWorkItem)
                  (validatedVocabularyExpression validatedWorkItem)
                  payload
                  store
           in successOutcome existingCurrent saveResult
        Nothing ->
          terminalFailureOutcome existingCurrent store FailureMalformedPayload
    GenerationRetryableFailure ->
      retryableFailureOutcome retryBudget existingCurrent store
    GenerationTimedOut ->
      timedOutFailureOutcome retryBudget existingCurrent store
    GenerationNonRetryableFailure ->
      terminalFailureOutcome existingCurrent store FailureTerminal

retryableFailureOutcome ::
  RetryBudget -> ExistingCurrent -> ExplanationStore -> WorkflowOutcome
retryableFailureOutcome retryBudget existingCurrent store =
  WorkflowOutcome
    { workflowTrail =
        [Queued, Running, RetryScheduled (retryAttempt retryBudget)],
      workflowFinalState = RetryScheduled (retryAttempt retryBudget),
      workflowVisibility = StatusOnly,
      workflowFailureSummary = Just (failureSummaryFor FailureRetryable),
      workflowCurrentAction = retainExistingCurrent existingCurrent,
      workflowDuplicateDisposition = ProcessFresh,
      workflowCompletedRecord = Nothing,
      workflowSaveAction = Nothing,
      workflowStore = store,
      workflowHandoffCompleted = False
    }

timedOutFailureOutcome ::
  RetryBudget -> ExistingCurrent -> ExplanationStore -> WorkflowOutcome
timedOutFailureOutcome retryBudget existingCurrent store
  | retryAttempt retryBudget < retryLimit retryBudget =
      WorkflowOutcome
        { workflowTrail =
            [Queued, Running, TimedOut (retryAttempt retryBudget), RetryScheduled (retryAttempt retryBudget)],
          workflowFinalState = RetryScheduled (retryAttempt retryBudget),
          workflowVisibility = StatusOnly,
          workflowFailureSummary = Just (failureSummaryFor FailureTimedOut),
          workflowCurrentAction = retainExistingCurrent existingCurrent,
          workflowDuplicateDisposition = ProcessFresh,
          workflowCompletedRecord = Nothing,
          workflowSaveAction = Nothing,
          workflowStore = store,
          workflowHandoffCompleted = False
        }
  | otherwise =
      WorkflowOutcome
        { workflowTrail =
            [Queued, Running, TimedOut (retryAttempt retryBudget), FailedFinal],
          workflowFinalState = FailedFinal,
          workflowVisibility = StatusOnly,
          workflowFailureSummary = Just (failureSummaryFor FailureTimedOut),
          workflowCurrentAction = retainExistingCurrent existingCurrent,
          workflowDuplicateDisposition = ProcessFresh,
          workflowCompletedRecord = Nothing,
          workflowSaveAction = Nothing,
          workflowStore = store,
          workflowHandoffCompleted = False
        }

terminalFailureOutcome ::
  ExistingCurrent -> ExplanationStore -> FailureCode -> WorkflowOutcome
terminalFailureOutcome existingCurrent store failureCode =
  let finalState =
        case failureCode of
          FailureOwnershipMismatch -> DeadLettered
          _ -> FailedFinal
   in WorkflowOutcome
        { workflowTrail = [Queued, Running, finalState],
          workflowFinalState = finalState,
          workflowVisibility = StatusOnly,
          workflowFailureSummary = Just (failureSummaryFor failureCode),
          workflowCurrentAction = retainExistingCurrent existingCurrent,
          workflowDuplicateDisposition = ProcessFresh,
          workflowCompletedRecord = Nothing,
          workflowSaveAction = Nothing,
          workflowStore = store,
          workflowHandoffCompleted = False
        }
