module ImageWorker.WorkerRuntime
  ( ScenarioReport (..),
    WorkerScenario (..),
    parseWorkerScenarioLabel,
    renderScenarioReport,
    runScenarioReport,
    workerScenarioLabel
  )
where

import Data.List (intercalate)
import ImageWorker.AssetStoragePort
  ( AssetStorageOutcome,
    nonRetryableAssetStorageFailure,
    retryableAssetStorageFailure,
    stableStoredAsset,
    storageReference
  )
import ImageWorker.CurrentImageHandoff
  ( CurrentAction (..),
    ExistingCurrent (..),
    HandoffStatus (..),
    renderCurrentAction
  )
import ImageWorker.FailureSummary
  ( ImageFailureSummary (..),
    Visibility,
    renderFailureCode,
    renderVisibility
  )
import ImageWorker.ImageGenerationPort
  ( GenerationOutcome,
    malformedSuccessOutcome,
    nonRetryableFailureOutcome,
    retryableFailureOutcome,
    successfulOutcome,
    timedOutOutcome
  )
import ImageWorker.ImagePersistence
  ( CompletedVisualImageRecord (..),
    ImageStore (..),
    SaveResult (..),
    emptyImageStore,
    existingRecordFor,
    markRecordCurrentApplied,
    recordVisibility,
    renderCompletedImageVisibility,
    renderSaveAction,
    saveCompletedImage
  )
import ImageWorker.TargetResolution
  ( TargetContext (..),
    defaultTargetContext,
    resolveTarget
  )
import ImageWorker.WorkflowStateMachine
  ( RetryBudget (..),
    WorkflowOutcome (..),
    deadLetterOutcome,
    duplicateOutcome,
    intakeFailureOutcome,
    renderWorkflowState,
    resolutionFailureOutcome,
    runImageOutcome
  )
import ImageWorker.WorkItemContract
  ( DuplicateDisposition (..),
    DuplicateStatus (..),
    ValidatedWorkItem,
    WorkItem (..),
    defaultWorkItem,
    duplicateDisposition,
    renderDuplicateDisposition,
    validateWorkItem,
    validatedBusinessKey
  )

data WorkerScenario
  = ScenarioSuccess
  | ScenarioRetryableFailure
  | ScenarioTerminalFailure
  | ScenarioTimeout
  | ScenarioHandoffRetry
  | ScenarioStaleSuccess
  | ScenarioDuplicateRunning
  | ScenarioDuplicateSucceeded
  | ScenarioInvalidTarget
  | ScenarioOwnershipMismatch
  | ScenarioExplanationIncomplete
  | ScenarioSenseMismatch
  | ScenarioDeadLetter
  deriving (Eq, Show)

data ScenarioReport = ScenarioReport
  { reportScenario :: String,
    reportFinalState :: String,
    reportTrail :: [String],
    reportVisibility :: String,
    reportFailureCode :: String,
    reportRetryable :: Bool,
    reportImageSaved :: Bool,
    reportHandoffCompleted :: Bool,
    reportCurrentAction :: String,
    reportCurrentRetained :: Bool,
    reportDuplicateDisposition :: String,
    reportSaveAction :: String,
    reportRecordVisibility :: String
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
      saveActionValue =
        case workflowSaveAction workflowOutcome of
          Nothing -> "none"
          Just saveActionValue' -> renderSaveAction saveActionValue'
      recordVisibilityValue =
        case workflowCompletedRecord workflowOutcome of
          Nothing -> "none"
          Just completedRecord ->
            renderCompletedImageVisibility (recordVisibility completedRecord)
   in ScenarioReport
        { reportScenario = workerScenarioLabel scenario,
          reportFinalState = renderWorkflowState (workflowFinalState workflowOutcome),
          reportTrail = map renderWorkflowState (workflowTrail workflowOutcome),
          reportVisibility = renderVisibility (workflowVisibility workflowOutcome),
          reportFailureCode = failureCodeValue,
          reportRetryable = retryableValue,
          reportImageSaved = maybe False (const True) (workflowCompletedRecord workflowOutcome),
          reportHandoffCompleted = workflowHandoffCompleted workflowOutcome,
          reportCurrentAction = renderCurrentAction (workflowCurrentAction workflowOutcome),
          reportCurrentRetained = currentWasRetained (workflowCurrentAction workflowOutcome),
          reportDuplicateDisposition =
            renderDuplicateDisposition (workflowDuplicateDisposition workflowOutcome),
          reportSaveAction = saveActionValue,
          reportRecordVisibility = recordVisibilityValue
        }

parseWorkerScenarioLabel :: String -> Maybe WorkerScenario
parseWorkerScenarioLabel scenarioLabel =
  case scenarioLabel of
    "success" -> Just ScenarioSuccess
    "retryable-failure" -> Just ScenarioRetryableFailure
    "terminal-failure" -> Just ScenarioTerminalFailure
    "timed-out" -> Just ScenarioTimeout
    "handoff-retry" -> Just ScenarioHandoffRetry
    "stale-success" -> Just ScenarioStaleSuccess
    "duplicate-running" -> Just ScenarioDuplicateRunning
    "duplicate-succeeded" -> Just ScenarioDuplicateSucceeded
    "invalid-target" -> Just ScenarioInvalidTarget
    "ownership-mismatch" -> Just ScenarioOwnershipMismatch
    "explanation-incomplete" -> Just ScenarioExplanationIncomplete
    "sense-mismatch" -> Just ScenarioSenseMismatch
    "dead-letter" -> Just ScenarioDeadLetter
    _ -> Nothing

renderScenarioReport :: ScenarioReport -> String
renderScenarioReport report =
  intercalate
    " "
    [ "VOCAS_IMAGE_RESULT",
      "scenario=" ++ reportScenario report,
      "final_state=" ++ reportFinalState report,
      "trail=" ++ intercalate "," (reportTrail report),
      "visibility=" ++ reportVisibility report,
      "failure_code=" ++ reportFailureCode report,
      "retryable=" ++ renderBool (reportRetryable report),
      "image_saved=" ++ renderBool (reportImageSaved report),
      "handoff_completed=" ++ renderBool (reportHandoffCompleted report),
      "current_action=" ++ reportCurrentAction report,
      "current_retained=" ++ renderBool (reportCurrentRetained report),
      "duplicate=" ++ reportDuplicateDisposition report,
      "save_action=" ++ reportSaveAction report,
      "record_visibility=" ++ reportRecordVisibility report
    ]

currentWasRetained :: CurrentAction -> Bool
currentWasRetained currentAction =
  case currentAction of
    CurrentSwitched _ -> False
    CurrentRetained _ -> True
    CurrentSuperseded _ -> True

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
              case resolveTarget validatedWorkItem (targetContextForScenario scenario) of
                Left resolutionFailure ->
                  resolutionFailureOutcome existingCurrentValue initialStore resolutionFailure
                Right resolvedTarget ->
                  case scenario of
                    ScenarioDeadLetter ->
                      deadLetterOutcome existingCurrentValue initialStore
                    _ ->
                      runImageOutcome
                        retryBudget
                        existingCurrentValue
                        initialStore
                        validatedWorkItem
                        resolvedTarget
                        (generationOutcomeForScenario scenario)
                        (assetOutcomeForScenario scenario)
                        (handoffStatusForScenario scenario)
            dispositionValue ->
              duplicateOutcome
                dispositionValue
                existingCurrentValue
                initialStore
                (existingRecordFor (validatedBusinessKey validatedWorkItem) initialStore)

generationOutcomeForScenario :: WorkerScenario -> GenerationOutcome
generationOutcomeForScenario scenario =
  case scenario of
    ScenarioRetryableFailure -> retryableFailureOutcome
    ScenarioTerminalFailure -> malformedSuccessOutcome
    ScenarioTimeout -> timedOutOutcome
    _ -> successfulOutcome

assetOutcomeForScenario :: WorkerScenario -> AssetStorageOutcome
assetOutcomeForScenario _ = stableStoredAsset

handoffStatusForScenario :: WorkerScenario -> HandoffStatus
handoffStatusForScenario scenario =
  case scenario of
    ScenarioHandoffRetry -> HandoffRetryableFailure
    _ -> HandoffApplied

workItemForScenario :: WorkerScenario -> WorkItem
workItemForScenario scenario =
  case scenario of
    ScenarioStaleSuccess -> defaultWorkItem {workAcceptedOrder = 1}
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
    ScenarioDuplicateSucceeded -> ExistingCurrent "image-business-key-001-image"
    _ -> ExistingCurrent "existing-current-image-001"

initialStoreForScenario :: WorkerScenario -> ImageStore
initialStoreForScenario scenario =
  case scenario of
    ScenarioDuplicateSucceeded ->
      case duplicateCompletedRecord of
        Just completedRecord ->
          ImageStore [("image-business-key-001", completedRecord)]
        Nothing -> emptyImageStore
    _ -> emptyImageStore

targetContextForScenario :: WorkerScenario -> TargetContext
targetContextForScenario scenario =
  case scenario of
    ScenarioStaleSuccess ->
      defaultTargetContext {targetLatestAcceptedOrder = 2}
    ScenarioInvalidTarget ->
      defaultTargetContext {targetExists = False}
    ScenarioOwnershipMismatch ->
      defaultTargetContext {targetOwnedByLearner = False}
    ScenarioExplanationIncomplete ->
      defaultTargetContext {targetExplanationCompleted = False}
    ScenarioSenseMismatch ->
      defaultTargetContext {targetSenseMatches = False}
    _ -> defaultTargetContext

duplicateCompletedRecord :: Maybe CompletedVisualImageRecord
duplicateCompletedRecord =
  case stableStoredAsset of
    storageOutcome ->
      case storageReference storageOutcome of
        Nothing -> Nothing
        Just storedAssetReference ->
          let saveResult =
                saveCompletedImage
                  "image-business-key-001"
                  "explanation-001"
                  (Just "sense-001")
                  storedAssetReference
                  3
                  Nothing
                  emptyImageStore
              (currentRecord, _) =
                markRecordCurrentApplied "image-business-key-001" (saveStore saveResult)
           in Just currentRecord

workerScenarioLabel :: WorkerScenario -> String
workerScenarioLabel scenario =
  case scenario of
    ScenarioSuccess -> "success"
    ScenarioRetryableFailure -> "retryable-failure"
    ScenarioTerminalFailure -> "terminal-failure"
    ScenarioTimeout -> "timed-out"
    ScenarioHandoffRetry -> "handoff-retry"
    ScenarioStaleSuccess -> "stale-success"
    ScenarioDuplicateRunning -> "duplicate-running"
    ScenarioDuplicateSucceeded -> "duplicate-succeeded"
    ScenarioInvalidTarget -> "invalid-target"
    ScenarioOwnershipMismatch -> "ownership-mismatch"
    ScenarioExplanationIncomplete -> "explanation-incomplete"
    ScenarioSenseMismatch -> "sense-mismatch"
    ScenarioDeadLetter -> "dead-letter"
