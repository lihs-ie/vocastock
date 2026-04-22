module ExplanationWorker.WorkerRuntime
  ( ScenarioReport (..),
    WorkerScenario (..),
    parseWorkerScenarioLabel,
    renderScenarioReport,
    workerScenarioLabel,
    runScenarioReport
  )
where

import Data.List (intercalate)

import ExplanationWorker.CurrentExplanationHandoff
  ( CurrentAction (..),
    ExistingCurrent (..),
    renderCurrentAction
  )
import ExplanationWorker.ExplanationPersistence
  ( CompletedExplanationRecord,
    ExplanationStore (..),
    completedRecordFor,
    emptyExplanationStore,
    existingRecordFor
  )
import ExplanationWorker.FailureSummary
  ( ExplanationFailureSummary (..),
    Visibility,
    renderFailureCode,
    renderVisibility
  )
import ExplanationWorker.GenerationPort
  ( GenerationOutcome,
    malformedSuccessOutcome,
    nonRetryableFailureOutcome,
    outcomePayload,
    retryableFailureOutcome,
    successfulOutcome,
    timedOutOutcome
  )
import ExplanationWorker.WorkflowStateMachine
  ( RetryBudget (..),
    WorkflowOutcome (..),
    WorkflowState,
    duplicateOutcome,
    intakeFailureOutcome,
    renderWorkflowState,
    runGenerationOutcome
  )
import ExplanationWorker.WorkItemContract
  ( DuplicateDisposition (..),
    DuplicateStatus (..),
    IntakeFailure,
    ValidatedWorkItem,
    WorkItem (..),
    defaultWorkItem,
    duplicateDisposition,
    renderDuplicateDisposition,
    renderIntakeFailure,
    validatedBusinessKey,
    validateWorkItem
  )

data WorkerScenario
  = ScenarioSuccess
  | ScenarioRetryableFailure
  | ScenarioTerminalFailure
  | ScenarioTimeout
  | ScenarioDuplicateRunning
  | ScenarioDuplicateSucceeded
  | ScenarioInvalidTarget
  | ScenarioOwnershipMismatch
  | ScenarioPreconditionInvalid
  deriving (Eq, Show)

data ScenarioReport = ScenarioReport
  { reportScenario :: String,
    reportFinalState :: String,
    reportTrail :: [String],
    reportVisibility :: String,
    reportFailureCode :: String,
    reportRetryable :: Bool,
    reportCompletedSaved :: Bool,
    reportHandoffCompleted :: Bool,
    reportCurrentAction :: String,
    reportCurrentRetained :: Bool,
    reportDuplicateDisposition :: String
  }
  deriving (Eq, Show)

runScenarioReport :: WorkerScenario -> ScenarioReport
runScenarioReport scenario =
  let workflowOutcome = runScenario scenario
      failureCodeValue =
        case workflowFailureSummary workflowOutcome of
          Nothing -> "none"
          Just summaryValue -> renderFailureCode (summaryCode summaryValue)
      retryableValue =
        case workflowFailureSummary workflowOutcome of
          Nothing -> False
          Just summaryValue -> summaryRetryable summaryValue
   in ScenarioReport
        { reportScenario = workerScenarioLabel scenario,
          reportFinalState = renderWorkflowState (workflowFinalState workflowOutcome),
          reportTrail = map renderWorkflowState (workflowTrail workflowOutcome),
          reportVisibility = renderVisibility (workflowVisibility workflowOutcome),
          reportFailureCode = failureCodeValue,
          reportRetryable = retryableValue,
          reportCompletedSaved = maybe False (const True) (workflowCompletedRecord workflowOutcome),
          reportHandoffCompleted = workflowHandoffCompleted workflowOutcome,
          reportCurrentAction = renderCurrentAction (workflowCurrentAction workflowOutcome),
          reportCurrentRetained = currentWasRetained (workflowCurrentAction workflowOutcome),
          reportDuplicateDisposition =
            renderDuplicateDisposition (workflowDuplicateDisposition workflowOutcome)
        }

parseWorkerScenarioLabel :: String -> Maybe WorkerScenario
parseWorkerScenarioLabel scenarioLabel =
  case scenarioLabel of
    "success" -> Just ScenarioSuccess
    "retryable-failure" -> Just ScenarioRetryableFailure
    "terminal-failure" -> Just ScenarioTerminalFailure
    "timed-out" -> Just ScenarioTimeout
    "duplicate-running" -> Just ScenarioDuplicateRunning
    "duplicate-succeeded" -> Just ScenarioDuplicateSucceeded
    "invalid-target" -> Just ScenarioInvalidTarget
    "ownership-mismatch" -> Just ScenarioOwnershipMismatch
    "precondition-invalid" -> Just ScenarioPreconditionInvalid
    _ -> Nothing

renderScenarioReport :: ScenarioReport -> String
renderScenarioReport report =
  intercalate
    " "
    [ "VOCAS_EXPLANATION_RESULT",
      "scenario=" ++ reportScenario report,
      "final_state=" ++ reportFinalState report,
      "trail=" ++ intercalate "," (reportTrail report),
      "visibility=" ++ reportVisibility report,
      "failure_code=" ++ reportFailureCode report,
      "retryable=" ++ renderBool (reportRetryable report),
      "completed_saved=" ++ renderBool (reportCompletedSaved report),
      "handoff_completed=" ++ renderBool (reportHandoffCompleted report),
      "current_action=" ++ reportCurrentAction report,
      "current_retained=" ++ renderBool (reportCurrentRetained report),
      "duplicate=" ++ reportDuplicateDisposition report
    ]

currentWasRetained :: CurrentAction -> Bool
currentWasRetained currentAction =
  case currentAction of
    CurrentSwitched _ -> False
    CurrentRetained _ -> True

renderBool :: Bool -> String
renderBool value =
  if value
    then "true"
    else "false"

runScenario :: WorkerScenario -> WorkflowOutcome
runScenario scenario =
  let existingCurrentValue = existingCurrentForScenario scenario
      initialStore = initialStoreForScenario scenario
      workItem = workItemForScenario scenario
      retryBudget = RetryBudget {retryAttempt = 1, retryLimit = 2}
   in case validateWorkItem workItem of
        Left intakeFailure ->
          intakeFailureOutcome existingCurrentValue initialStore intakeFailure
        Right validatedWorkItem ->
          case duplicateDisposition (duplicateStatusForScenario scenario) of
            ProcessFresh ->
              runGenerationOutcome
                retryBudget
                existingCurrentValue
                initialStore
                validatedWorkItem
                (generationOutcomeForScenario scenario)
            dispositionValue ->
              duplicateOutcome
                dispositionValue
                existingCurrentValue
                initialStore
                (existingRecordFor (validatedBusinessKey validatedWorkItem) initialStore)

generationOutcomeForScenario :: WorkerScenario -> GenerationOutcome
generationOutcomeForScenario scenario =
  case scenario of
    ScenarioSuccess -> successfulOutcome
    ScenarioRetryableFailure -> retryableFailureOutcome
    ScenarioTerminalFailure -> malformedSuccessOutcome
    ScenarioTimeout -> timedOutOutcome
    ScenarioDuplicateRunning -> nonRetryableFailureOutcome
    ScenarioDuplicateSucceeded -> successfulOutcome
    ScenarioInvalidTarget -> successfulOutcome
    ScenarioOwnershipMismatch -> successfulOutcome
    ScenarioPreconditionInvalid -> successfulOutcome

workItemForScenario :: WorkerScenario -> WorkItem
workItemForScenario scenario =
  case scenario of
    ScenarioInvalidTarget -> defaultWorkItem {workTargetExists = False}
    ScenarioOwnershipMismatch -> defaultWorkItem {workOwnershipMatches = False}
    ScenarioPreconditionInvalid -> defaultWorkItem {workPreconditionValid = False}
    _ -> defaultWorkItem

duplicateStatusForScenario :: WorkerScenario -> DuplicateStatus
duplicateStatusForScenario scenario =
  case scenario of
    ScenarioDuplicateRunning -> DuplicateRunning
    ScenarioDuplicateSucceeded -> DuplicateSucceeded
    _ -> DuplicateAbsent

existingCurrentForScenario :: WorkerScenario -> ExistingCurrent
existingCurrentForScenario scenario =
  case scenario of
    ScenarioSuccess -> NoCurrent
    ScenarioDuplicateSucceeded -> ExistingCurrent "business-key-001-completed"
    _ -> ExistingCurrent "existing-current-001"

initialStoreForScenario :: WorkerScenario -> ExplanationStore
initialStoreForScenario scenario =
  case scenario of
    ScenarioDuplicateSucceeded ->
      let payload = case outcomePayload successfulOutcome of
            Just payloadValue -> payloadValue
            Nothing -> error "successful outcome should provide a payload"
          existingRecord =
            completedRecordFor "business-key-001" "vocabulary-expression-001" payload
       in ExplanationStore [("business-key-001", existingRecord)]
    _ -> emptyExplanationStore

workerScenarioLabel :: WorkerScenario -> String
workerScenarioLabel scenario =
  case scenario of
    ScenarioSuccess -> "success"
    ScenarioRetryableFailure -> "retryable-failure"
    ScenarioTerminalFailure -> "terminal-failure"
    ScenarioTimeout -> "timed-out"
    ScenarioDuplicateRunning -> "duplicate-running"
    ScenarioDuplicateSucceeded -> "duplicate-succeeded"
    ScenarioInvalidTarget -> "invalid-target"
    ScenarioOwnershipMismatch -> "ownership-mismatch"
    ScenarioPreconditionInvalid -> "precondition-invalid"
