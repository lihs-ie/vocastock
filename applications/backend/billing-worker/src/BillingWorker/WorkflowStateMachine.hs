module BillingWorker.WorkflowStateMachine
  ( RetryBudget (..),
    WorkflowOutcome (..),
    WorkflowState (..),
    deadLetterOutcome,
    duplicateOutcome,
    intakeFailureOutcome,
    ownershipMismatchOutcome,
    renderWorkflowState,
    runNotificationOutcome,
    runVerificationOutcome
  )
where

import BillingWorker.BillingPersistence
  ( BillingStore,
    CompletedBillingPayload (..),
    CompletedBillingRecord,
    CompletedRecordVisibility (..),
    RecordSource (..),
    SaveAction,
    SaveResult (..),
    markRecordCurrentApplied,
    recordVisibility,
    saveCompletedBilling
  )
import BillingWorker.CurrentSubscriptionHandoff
  ( CurrentAction,
    ExistingCurrent,
    HandoffStatus (..),
    applyCurrentSubscriptionSuccess,
    retainExistingCurrent
  )
import BillingWorker.EntitlementRecalcPort
  ( EntitlementDerivation (..),
    QuotaProfileName (..),
    deriveEntitlement,
    renderEntitlementBundleName,
    renderQuotaProfileName
  )
import BillingWorker.FailureSummary
  ( BillingFailureSummary,
    FailureCode (..),
    Visibility (..),
    failureSummaryFor
  )
import BillingWorker.NotificationPort
  ( NotificationIngestOutcome (..),
    NotificationIngestStatus (..),
    NotificationPayload (..),
    validateNotificationPayload
  )
import BillingWorker.PurchaseVerificationPort
  ( VerificationOutcome (..),
    VerificationPayload (..),
    VerificationStatus (..),
    validateVerificationPayload
  )
import BillingWorker.SubscriptionAuthorityPort
  ( SubscriptionStateName (..),
    parseSubscriptionStateName,
    renderSubscriptionStateName
  )
import BillingWorker.WorkItemContract
  ( DuplicateDisposition (..),
    IntakeFailure (..),
    ValidatedWorkItem (..),
    WorkTrigger (..)
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
    workflowFailureSummary :: Maybe BillingFailureSummary,
    workflowCurrentAction :: CurrentAction,
    workflowDuplicateDisposition :: DuplicateDisposition,
    workflowCompletedRecord :: Maybe CompletedBillingRecord,
    workflowSaveAction :: Maybe SaveAction,
    workflowStore :: BillingStore,
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
  BillingStore ->
  Maybe CompletedBillingRecord ->
  WorkflowOutcome
duplicateOutcome disposition existingCurrent store maybeRecord =
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
        store
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
        store
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
        store
        False

intakeFailureOutcome ::
  ExistingCurrent -> BillingStore -> IntakeFailure -> WorkflowOutcome
intakeFailureOutcome existingCurrent store intakeFailure =
  let failureCode =
        case intakeFailure of
          TriggerNotSupported -> FailureTriggerNotSupported
          PreconditionInvalid -> FailurePreconditionInvalid
          MissingPurchaseArtifact -> FailureMissingPurchaseArtifact
          MissingNotificationPayload -> FailureMissingNotificationPayload
   in buildOutcome
        [Queued, FailedFinal]
        FailedFinal
        StatusOnly
        (Just (failureSummaryFor failureCode 0))
        (retainExistingCurrent existingCurrent)
        ProcessFresh
        Nothing
        Nothing
        store
        False

ownershipMismatchOutcome ::
  ExistingCurrent -> BillingStore -> WorkflowOutcome
ownershipMismatchOutcome existingCurrent store =
  buildOutcome
    [Queued, Running, DeadLettered]
    DeadLettered
    StatusOnly
    (Just (failureSummaryFor FailureOwnershipMismatch 1))
    (retainExistingCurrent existingCurrent)
    ProcessFresh
    Nothing
    Nothing
    store
    False

deadLetterOutcome ::
  ExistingCurrent -> BillingStore -> WorkflowOutcome
deadLetterOutcome existingCurrent store =
  buildOutcome
    [Queued, Running, DeadLettered]
    DeadLettered
    StatusOnly
    (Just (failureSummaryFor FailureOperatorReview 1))
    (retainExistingCurrent existingCurrent)
    ProcessFresh
    Nothing
    Nothing
    store
    False

runVerificationOutcome ::
  RetryBudget ->
  ExistingCurrent ->
  BillingStore ->
  ValidatedWorkItem ->
  VerificationOutcome ->
  HandoffStatus ->
  WorkflowOutcome
runVerificationOutcome retryBudget existingCurrent store validatedWorkItem verificationOutcome handoffStatus =
  case outcomeStatus verificationOutcome of
    VerificationVerified ->
      case outcomePayload verificationOutcome >>= either (const Nothing) Just . validateVerificationPayload of
        Nothing ->
          terminalFailureOutcome existingCurrent store FailureMalformedPayload
        Just verifiedPayload ->
          case parseSubscriptionStateName (payloadSubscriptionStateName verifiedPayload) of
            Nothing ->
              terminalFailureOutcome existingCurrent store FailureMalformedPayload
            Just _ ->
              runCommittedVerification
                existingCurrent
                store
                validatedWorkItem
                verifiedPayload
                handoffStatus
    VerificationRetryableFailure ->
      retryableFailureOutcome retryBudget existingCurrent store FailureRetryableVerification
    VerificationTimedOut ->
      timedOutFailureOutcome retryBudget existingCurrent store
    VerificationNonRetryableFailure ->
      terminalFailureOutcome existingCurrent store FailureTerminal

runCommittedVerification ::
  ExistingCurrent ->
  BillingStore ->
  ValidatedWorkItem ->
  VerificationPayload ->
  HandoffStatus ->
  WorkflowOutcome
runCommittedVerification existingCurrent store validatedWorkItem verifiedPayload handoffStatus =
  let completedPayload =
        buildCompletedPayload
          "verified"
          (payloadSubscriptionStateName verifiedPayload)
          (payloadEntitlementBundleName verifiedPayload)
          (payloadQuotaProfileName verifiedPayload)
          (payloadTermStart verifiedPayload)
          (payloadTermEnd verifiedPayload)
          (payloadGraceWindow verifiedPayload)
      initialSave =
        saveCompletedBilling
          (validatedBusinessKey validatedWorkItem)
          (validatedSubscription validatedWorkItem)
          SourcePurchaseVerification
          completedPayload
          store
   in finalizeHandoff existingCurrent validatedWorkItem initialSave handoffStatus

runNotificationOutcome ::
  RetryBudget ->
  ExistingCurrent ->
  BillingStore ->
  ValidatedWorkItem ->
  NotificationIngestOutcome ->
  HandoffStatus ->
  WorkflowOutcome
runNotificationOutcome retryBudget existingCurrent store validatedWorkItem notificationIngestOutcome handoffStatus =
  case ingestStatus notificationIngestOutcome of
    NotificationReconciled ->
      case ingestPayload notificationIngestOutcome >>= either (const Nothing) Just . validateNotificationPayload of
        Nothing ->
          terminalFailureOutcome existingCurrent store FailureMalformedNotification
        Just reconciledPayload ->
          case parseSubscriptionStateName (notificationSubscriptionStateName reconciledPayload) of
            Nothing ->
              terminalFailureOutcome existingCurrent store FailureMalformedNotification
            Just subscriptionStateValue ->
              runCommittedNotification
                existingCurrent
                store
                validatedWorkItem
                subscriptionStateValue
                reconciledPayload
                handoffStatus
    NotificationRetryableFailure ->
      retryableFailureOutcome retryBudget existingCurrent store FailureRetryableNotificationIngest
    NotificationTimedOut ->
      timedOutFailureOutcome retryBudget existingCurrent store
    NotificationNonRetryableFailure ->
      terminalFailureOutcome existingCurrent store FailureMalformedNotification
    NotificationStale ->
      terminalFailureOutcome existingCurrent store FailureStaleNotification

runCommittedNotification ::
  ExistingCurrent ->
  BillingStore ->
  ValidatedWorkItem ->
  SubscriptionStateName ->
  NotificationPayload ->
  HandoffStatus ->
  WorkflowOutcome
runCommittedNotification existingCurrent store validatedWorkItem subscriptionStateValue reconciledPayload handoffStatus =
  let entitlementDerivation =
        deriveEntitlement
          subscriptionStateValue
          (carriedPaidQuota (validatedTrigger validatedWorkItem))
      completedPayload =
        buildCompletedPayload
          (carriedPurchaseState (validatedTrigger validatedWorkItem))
          (renderSubscriptionStateName subscriptionStateValue)
          (renderEntitlementBundleName (derivationBundle entitlementDerivation))
          (renderQuotaProfileName (derivationQuotaProfile entitlementDerivation))
          (notificationTermStart reconciledPayload)
          (notificationTermEnd reconciledPayload)
          (notificationGraceWindow reconciledPayload)
      initialSave =
        saveCompletedBilling
          (validatedBusinessKey validatedWorkItem)
          (validatedSubscription validatedWorkItem)
          SourceNotificationReconciliation
          completedPayload
          store
   in finalizeHandoff existingCurrent validatedWorkItem initialSave handoffStatus

finalizeHandoff ::
  ExistingCurrent ->
  ValidatedWorkItem ->
  SaveResult ->
  HandoffStatus ->
  WorkflowOutcome
finalizeHandoff existingCurrent validatedWorkItem initialSave handoffStatus =
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
            ( applyCurrentSubscriptionSuccess
                currentRecord
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
        [Queued, Running, RetryScheduled 1]
        (RetryScheduled 1)
        StatusOnly
        (Just (failureSummaryFor FailureHandoffRetry 1))
        (retainExistingCurrent existingCurrent)
        ProcessFresh
        (Just (saveRecord initialSave))
        (Just (saveAction initialSave))
        (saveStore initialSave)
        False
    HandoffSuperseded ->
      buildOutcome
        [Queued, Running, Succeeded]
        Succeeded
        StatusOnly
        Nothing
        ( applyCurrentSubscriptionSuccess
            (saveRecord initialSave)
            existingCurrent
            HandoffSuperseded
        )
        ProcessFresh
        (Just (saveRecord initialSave))
        (Just (saveAction initialSave))
        (saveStore initialSave)
        False

retryableFailureOutcome ::
  RetryBudget ->
  ExistingCurrent ->
  BillingStore ->
  FailureCode ->
  WorkflowOutcome
retryableFailureOutcome retryBudget existingCurrent store failureCode =
  buildOutcome
    [Queued, Running, RetryScheduled (retryAttempt retryBudget)]
    (RetryScheduled (retryAttempt retryBudget))
    StatusOnly
    (Just (failureSummaryFor failureCode (retryAttempt retryBudget)))
    (retainExistingCurrent existingCurrent)
    ProcessFresh
    Nothing
    Nothing
    store
    False

timedOutFailureOutcome ::
  RetryBudget -> ExistingCurrent -> BillingStore -> WorkflowOutcome
timedOutFailureOutcome retryBudget existingCurrent store
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
        store
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
        store
        False

terminalFailureOutcome ::
  ExistingCurrent -> BillingStore -> FailureCode -> WorkflowOutcome
terminalFailureOutcome existingCurrent store failureCode =
  buildOutcome
    [Queued, Running, FailedFinal]
    FailedFinal
    StatusOnly
    (Just (failureSummaryFor failureCode 1))
    (retainExistingCurrent existingCurrent)
    ProcessFresh
    Nothing
    Nothing
    store
    False

visibilityForRecord :: CompletedBillingRecord -> Visibility
visibilityForRecord completedBillingRecord =
  case recordVisibility completedBillingRecord of
    HiddenUntilHandoff -> StatusOnly
    CurrentApplied -> CompletedCurrent

buildCompletedPayload ::
  String ->
  String ->
  String ->
  String ->
  String ->
  String ->
  Maybe String ->
  CompletedBillingPayload
buildCompletedPayload purchaseStateValue subscriptionStateValue bundleName quotaProfileName termStart termEnd graceWindow =
  CompletedBillingPayload
    { completedPurchaseStateName = purchaseStateValue,
      completedSubscriptionStateName = subscriptionStateValue,
      completedEntitlementBundleName = bundleName,
      completedQuotaProfileName = quotaProfileName,
      completedTermStart = termStart,
      completedTermEnd = termEnd,
      completedGraceWindow = graceWindow
    }

carriedPaidQuota :: WorkTrigger -> QuotaProfileName
carriedPaidQuota workTriggerValue =
  case workTriggerValue of
    PurchaseArtifactSubmitted -> StandardMonthlyQuota
    NotificationReceived -> StandardMonthlyQuota
    UnsupportedTrigger _ -> FreeMonthlyQuota

carriedPurchaseState :: WorkTrigger -> String
carriedPurchaseState workTriggerValue =
  case workTriggerValue of
    PurchaseArtifactSubmitted -> "verified"
    NotificationReceived -> "verified"
    UnsupportedTrigger _ -> "verifying"

buildOutcome ::
  [WorkflowState] ->
  WorkflowState ->
  Visibility ->
  Maybe BillingFailureSummary ->
  CurrentAction ->
  DuplicateDisposition ->
  Maybe CompletedBillingRecord ->
  Maybe SaveAction ->
  BillingStore ->
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
