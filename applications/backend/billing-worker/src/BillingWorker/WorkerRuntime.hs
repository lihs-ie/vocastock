module BillingWorker.WorkerRuntime
  ( ScenarioReport (..),
    WorkerScenario (..),
    parseWorkerScenarioLabel,
    renderScenarioReport,
    runScenarioReport,
    workerScenarioLabel
  )
where

import Data.List (intercalate)

import BillingWorker.BillingPersistence
  ( CompletedBillingPayload (..),
    CompletedBillingRecord,
    RecordSource (..),
    completedRecordFor,
    emptyBillingStore
  )
import BillingWorker.CurrentSubscriptionHandoff
  ( CurrentAction (..),
    ExistingCurrent (..),
    HandoffStatus (..),
    renderCurrentAction
  )
import BillingWorker.FailureSummary
  ( BillingFailureSummary (..),
    Visibility,
    renderFailureCode,
    renderPublicStatus,
    renderVisibility
  )
import BillingWorker.NotificationPort
  ( NotificationIngestOutcome,
    NotificationPayload (..),
    NotificationSource (..),
    malformedNotificationOutcome,
    nonRetryableNotificationOutcome,
    reconciledNotificationOutcome,
    retryableNotificationOutcome,
    staleNotificationOutcome,
    timedOutNotificationOutcome
  )
import BillingWorker.PurchaseVerificationPort
  ( VerificationOutcome,
    VerificationPayload (..),
    malformedVerifiedOutcome,
    nonRetryableVerificationOutcome,
    retryableVerificationOutcome,
    successfulVerificationOutcome,
    timedOutVerificationOutcome
  )
import BillingWorker.WorkflowStateMachine
  ( RetryBudget (..),
    WorkflowOutcome (..),
    WorkflowState,
    deadLetterOutcome,
    duplicateOutcome,
    intakeFailureOutcome,
    ownershipMismatchOutcome,
    renderWorkflowState,
    runNotificationOutcome,
    runVerificationOutcome
  )
import BillingWorker.WorkItemContract
  ( DuplicateDisposition (..),
    DuplicateStatus (..),
    IntakeFailure,
    ValidatedWorkItem,
    WorkItem (..),
    WorkTrigger (..),
    defaultNotificationWorkItem,
    defaultPurchaseWorkItem,
    duplicateDisposition,
    renderDuplicateDisposition,
    renderIntakeFailure,
    validateWorkItem
  )

data WorkerScenario
  = ScenarioSuccess
  | ScenarioRetryableFailure
  | ScenarioTerminalFailure
  | ScenarioTimeout
  | ScenarioDuplicateRunning
  | ScenarioDuplicateSucceeded
  | ScenarioRetryExhausted
  | ScenarioInvalidTarget
  | ScenarioOwnershipMismatch
  | ScenarioNotificationReconciled
  | ScenarioNotificationRetryable
  | ScenarioNotificationTerminal
  | ScenarioNotificationStale
  | ScenarioNotificationDeadLetter
  deriving (Eq, Show)

data ScenarioReport = ScenarioReport
  { reportScenario :: String,
    reportFinalState :: String,
    reportTrail :: [String],
    reportVisibility :: String,
    reportFailureCode :: String,
    reportPublicStatus :: String,
    reportRetryable :: Bool,
    reportCompletedSaved :: Bool,
    reportHandoffCompleted :: Bool,
    reportCurrentAction :: String,
    reportCurrentRetained :: Bool,
    reportDuplicateDisposition :: String,
    reportSource :: String
  }
  deriving (Eq, Show)

runScenarioReport :: WorkerScenario -> ScenarioReport
runScenarioReport scenario =
  let workflowOutcome = runScenario scenario
      failureCodeValue =
        case workflowFailureSummary workflowOutcome of
          Nothing -> "none"
          Just summaryValue -> renderFailureCode (summaryCode summaryValue)
      publicStatusValue =
        case workflowFailureSummary workflowOutcome of
          Nothing -> "none"
          Just summaryValue -> renderPublicStatus (summaryPublicStatus summaryValue)
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
          reportPublicStatus = publicStatusValue,
          reportRetryable = retryableValue,
          reportCompletedSaved = maybe False (const True) (workflowCompletedRecord workflowOutcome),
          reportHandoffCompleted = workflowHandoffCompleted workflowOutcome,
          reportCurrentAction = renderCurrentAction (workflowCurrentAction workflowOutcome),
          reportCurrentRetained = currentWasRetained (workflowCurrentAction workflowOutcome),
          reportDuplicateDisposition =
            renderDuplicateDisposition (workflowDuplicateDisposition workflowOutcome),
          reportSource = sourceForScenario scenario
        }

workerScenarioLabel :: WorkerScenario -> String
workerScenarioLabel scenario =
  case scenario of
    ScenarioSuccess -> "success"
    ScenarioRetryableFailure -> "retryable-failure"
    ScenarioTerminalFailure -> "terminal-failure"
    ScenarioTimeout -> "timed-out"
    ScenarioDuplicateRunning -> "duplicate-running"
    ScenarioDuplicateSucceeded -> "duplicate-succeeded"
    ScenarioRetryExhausted -> "retry-exhausted"
    ScenarioInvalidTarget -> "invalid-target"
    ScenarioOwnershipMismatch -> "ownership-mismatch"
    ScenarioNotificationReconciled -> "notification-reconciled"
    ScenarioNotificationRetryable -> "notification-retryable"
    ScenarioNotificationTerminal -> "notification-terminal"
    ScenarioNotificationStale -> "notification-stale"
    ScenarioNotificationDeadLetter -> "notification-dead-letter"

parseWorkerScenarioLabel :: String -> Maybe WorkerScenario
parseWorkerScenarioLabel scenarioLabel =
  case scenarioLabel of
    "success" -> Just ScenarioSuccess
    "retryable-failure" -> Just ScenarioRetryableFailure
    "terminal-failure" -> Just ScenarioTerminalFailure
    "timed-out" -> Just ScenarioTimeout
    "duplicate-running" -> Just ScenarioDuplicateRunning
    "duplicate-succeeded" -> Just ScenarioDuplicateSucceeded
    "retry-exhausted" -> Just ScenarioRetryExhausted
    "invalid-target" -> Just ScenarioInvalidTarget
    "ownership-mismatch" -> Just ScenarioOwnershipMismatch
    "notification-reconciled" -> Just ScenarioNotificationReconciled
    "notification-retryable" -> Just ScenarioNotificationRetryable
    "notification-terminal" -> Just ScenarioNotificationTerminal
    "notification-stale" -> Just ScenarioNotificationStale
    "notification-dead-letter" -> Just ScenarioNotificationDeadLetter
    _ -> Nothing

renderScenarioReport :: ScenarioReport -> String
renderScenarioReport report =
  intercalate
    " "
    [ "VOCAS_BILLING_RESULT",
      "scenario=" ++ reportScenario report,
      "final_state=" ++ reportFinalState report,
      "trail=" ++ intercalate "," (reportTrail report),
      "visibility=" ++ reportVisibility report,
      "failure_code=" ++ reportFailureCode report,
      "public_status=" ++ reportPublicStatus report,
      "retryable=" ++ renderBool (reportRetryable report),
      "completed_saved=" ++ renderBool (reportCompletedSaved report),
      "handoff_completed=" ++ renderBool (reportHandoffCompleted report),
      "current_action=" ++ reportCurrentAction report,
      "current_retained=" ++ renderBool (reportCurrentRetained report),
      "duplicate=" ++ reportDuplicateDisposition report,
      "source=" ++ reportSource report
    ]

currentWasRetained :: CurrentAction -> Bool
currentWasRetained currentAction =
  case currentAction of
    CurrentRetained _ -> True
    _ -> False

renderBool :: Bool -> String
renderBool value =
  if value then "true" else "false"

sourceForScenario :: WorkerScenario -> String
sourceForScenario scenario =
  case scenario of
    ScenarioSuccess -> "purchase-verification"
    ScenarioRetryableFailure -> "purchase-verification"
    ScenarioTerminalFailure -> "purchase-verification"
    ScenarioTimeout -> "purchase-verification"
    ScenarioDuplicateRunning -> "purchase-verification"
    ScenarioDuplicateSucceeded -> "purchase-verification"
    ScenarioRetryExhausted -> "purchase-verification"
    ScenarioInvalidTarget -> "purchase-verification"
    ScenarioOwnershipMismatch -> "purchase-verification"
    ScenarioNotificationReconciled -> "notification-reconciliation"
    ScenarioNotificationRetryable -> "notification-reconciliation"
    ScenarioNotificationTerminal -> "notification-reconciliation"
    ScenarioNotificationStale -> "notification-reconciliation"
    ScenarioNotificationDeadLetter -> "notification-reconciliation"

runScenario :: WorkerScenario -> WorkflowOutcome
runScenario scenario =
  case scenario of
    ScenarioSuccess ->
      runPurchaseVerificationScenario
        (successfulVerificationOutcome "verification-request-001" defaultVerifiedPayload)
        HandoffApplied
        (freshBudget 3)
    ScenarioRetryableFailure ->
      runPurchaseVerificationScenario
        (retryableVerificationOutcome "verification-request-002" "verification-temporarily-unavailable")
        HandoffApplied
        (freshBudget 3)
    ScenarioTerminalFailure ->
      runPurchaseVerificationScenario
        (nonRetryableVerificationOutcome "verification-request-003" "signature-invalid")
        HandoffApplied
        (freshBudget 3)
    ScenarioTimeout ->
      runPurchaseVerificationScenario
        (timedOutVerificationOutcome "verification-request-004")
        HandoffApplied
        (RetryBudget {retryAttempt = 1, retryLimit = 3})
    ScenarioDuplicateRunning ->
      runDuplicateScenario DuplicateRunning Nothing
    ScenarioDuplicateSucceeded ->
      runDuplicateScenario DuplicateSucceeded (Just reuseCompletedRecord)
    ScenarioRetryExhausted ->
      runPurchaseVerificationScenario
        (timedOutVerificationOutcome "verification-request-005")
        HandoffApplied
        (RetryBudget {retryAttempt = 3, retryLimit = 3})
    ScenarioInvalidTarget ->
      intakeFailureOutcome NoCurrent emptyBillingStore preconditionInvalidFailure
    ScenarioOwnershipMismatch ->
      ownershipMismatchOutcome NoCurrent emptyBillingStore
    ScenarioNotificationReconciled ->
      runNotificationScenario
        ( reconciledNotificationOutcome
            "notification-request-001"
            AppStoreNotification
            defaultNotificationPayload
        )
        HandoffApplied
        (freshBudget 3)
    ScenarioNotificationRetryable ->
      runNotificationScenario
        ( retryableNotificationOutcome
            "notification-request-002"
            AppStoreNotification
            "notification-temporarily-unavailable"
        )
        HandoffApplied
        (freshBudget 3)
    ScenarioNotificationTerminal ->
      runNotificationScenario
        ( nonRetryableNotificationOutcome
            "notification-request-003"
            GooglePlayNotification
            "notification-malformed"
        )
        HandoffApplied
        (freshBudget 3)
    ScenarioNotificationStale ->
      runNotificationScenario
        ( staleNotificationOutcome
            "notification-request-004"
            AppStoreNotification
            stalePayload
        )
        HandoffApplied
        (freshBudget 3)
    ScenarioNotificationDeadLetter ->
      deadLetterOutcome NoCurrent emptyBillingStore

runPurchaseVerificationScenario ::
  VerificationOutcome -> HandoffStatus -> RetryBudget -> WorkflowOutcome
runPurchaseVerificationScenario verificationOutcome handoffStatus retryBudget =
  case validateWorkItem defaultPurchaseWorkItem of
    Left intakeFailure ->
      intakeFailureOutcome NoCurrent emptyBillingStore intakeFailure
    Right validated ->
      runVerificationOutcome
        retryBudget
        NoCurrent
        emptyBillingStore
        validated
        verificationOutcome
        handoffStatus

runNotificationScenario ::
  NotificationIngestOutcome -> HandoffStatus -> RetryBudget -> WorkflowOutcome
runNotificationScenario notificationIngestOutcome handoffStatus retryBudget =
  case validateWorkItem defaultNotificationWorkItem of
    Left intakeFailure ->
      intakeFailureOutcome NoCurrent emptyBillingStore intakeFailure
    Right validated ->
      runNotificationOutcome
        retryBudget
        NoCurrent
        emptyBillingStore
        validated
        notificationIngestOutcome
        handoffStatus

runDuplicateScenario ::
  DuplicateStatus -> Maybe CompletedBillingRecord -> WorkflowOutcome
runDuplicateScenario duplicateStatus maybeRecord =
  let disposition = duplicateDisposition duplicateStatus
      existingCurrent =
        case duplicateStatus of
          DuplicateSucceeded -> ExistingCurrent "existing-entitlement-snapshot-001"
          _ -> NoCurrent
   in duplicateOutcome disposition existingCurrent emptyBillingStore maybeRecord

freshBudget :: Int -> RetryBudget
freshBudget retryLimitValue =
  RetryBudget {retryAttempt = 1, retryLimit = retryLimitValue}

preconditionInvalidFailure :: IntakeFailure
preconditionInvalidFailure =
  case validateWorkItem invalidPreconditionItem of
    Left intakeFailure -> intakeFailure
    Right _ -> error "expected precondition failure"

invalidPreconditionItem :: WorkItem
invalidPreconditionItem =
  defaultPurchaseWorkItem {workSubscription = ""}

reuseCompletedRecord :: CompletedBillingRecord
reuseCompletedRecord =
  completedRecordFor
    "billing-business-key-existing"
    "subscription-001"
    SourcePurchaseVerification
    CompletedBillingPayload
      { completedPurchaseStateName = "verified",
        completedSubscriptionStateName = "active",
        completedEntitlementBundleName = "premium-generation",
        completedQuotaProfileName = "standard-monthly",
        completedTermStart = "2026-03-01T00:00:00Z",
        completedTermEnd = "2026-04-01T00:00:00Z",
        completedGraceWindow = Just "2026-04-08T00:00:00Z"
      }

defaultVerifiedPayload :: VerificationPayload
defaultVerifiedPayload =
  VerificationPayload
    { payloadSubscriptionStateName = "active",
      payloadEntitlementBundleName = "premium-generation",
      payloadQuotaProfileName = "standard-monthly",
      payloadTermStart = "2026-04-01T00:00:00Z",
      payloadTermEnd = "2026-05-01T00:00:00Z",
      payloadGraceWindow = Just "2026-05-08T00:00:00Z"
    }

defaultNotificationPayload :: NotificationPayload
defaultNotificationPayload =
  NotificationPayload
    { notificationProviderIdentifier = "apple-notification-001",
      notificationSubscriptionStateName = "grace",
      notificationTermStart = "2026-04-01T00:00:00Z",
      notificationTermEnd = "2026-05-01T00:00:00Z",
      notificationGraceWindow = Just "2026-05-08T00:00:00Z",
      notificationOriginalTimestamp = "2026-04-15T12:00:00Z"
    }

stalePayload :: NotificationPayload
stalePayload =
  NotificationPayload
    { notificationProviderIdentifier = "apple-notification-002",
      notificationSubscriptionStateName = "active",
      notificationTermStart = "2025-03-01T00:00:00Z",
      notificationTermEnd = "2025-04-01T00:00:00Z",
      notificationGraceWindow = Nothing,
      notificationOriginalTimestamp = "2025-03-15T12:00:00Z"
    }
