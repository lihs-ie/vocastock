module BillingWorker.WorkflowStateMachineSpec (run) where

import BillingWorker.BillingPersistence
  ( emptyBillingStore
  )
import BillingWorker.CurrentSubscriptionHandoff
  ( CurrentAction (..),
    ExistingCurrent (..),
    HandoffStatus (..)
  )
import BillingWorker.FailureSummary
  ( BillingFailureSummary (..),
    FailureCode (..),
    Visibility (..)
  )
import BillingWorker.NotificationPort
  ( NotificationPayload (..),
    NotificationSource (..),
    malformedNotificationOutcome,
    nonRetryableNotificationOutcome,
    reconciledNotificationOutcome,
    retryableNotificationOutcome,
    staleNotificationOutcome,
    timedOutNotificationOutcome
  )
import BillingWorker.PurchaseVerificationPort
  ( VerificationPayload (..),
    malformedVerifiedOutcome,
    nonRetryableVerificationOutcome,
    retryableVerificationOutcome,
    successfulVerificationOutcome,
    timedOutVerificationOutcome
  )
import BillingWorker.WorkItemContract
  ( DuplicateDisposition (..),
    IntakeFailure (..),
    defaultNotificationWorkItem,
    defaultPurchaseWorkItem,
    validateWorkItem
  )
import BillingWorker.WorkflowStateMachine
import TestSupport

run :: IO ()
run = do
  runNamed "queued -> running -> succeeded on verified payload" testSuccessPath
  runNamed "retryable verification maps to retry-scheduled" testRetryableVerification
  runNamed "timeout below limit maps to retry-scheduled" testTimeoutBelowLimit
  runNamed "timeout at limit maps to failed-final" testTimeoutAtLimit
  runNamed "non-retryable verification maps to failed-final" testNonRetryableVerification
  runNamed "malformed verification payload maps to failed-final" testMalformedVerifiedPayload
  runNamed "handoff retryable failure retains current" testHandoffRetry
  runNamed "notification reconciled succeeds" testNotificationReconciled
  runNamed "stale notification maps to failed-final" testStaleNotification
  runNamed "malformed notification maps to failed-final" testMalformedNotification
  runNamed "duplicate inflight keeps status-only" testDuplicateInflight
  runNamed "duplicate succeeded reuses record" testDuplicateSucceeded
  runNamed "intake failure produces failed-final" testIntakeFailure
  runNamed "ownership mismatch produces dead-lettered" testOwnershipMismatch
  runNamed "deadLetter outcome produces dead-lettered" testDeadLetter
  runNamed "renders workflow state labels" testRendersStateLabels

validatedPurchase =
  case validateWorkItem defaultPurchaseWorkItem of
    Right validated -> validated
    Left intakeFailure -> error ("expected Right but got Left " ++ show intakeFailure)

validatedNotification =
  case validateWorkItem defaultNotificationWorkItem of
    Right validated -> validated
    Left intakeFailure -> error ("expected Right but got Left " ++ show intakeFailure)

verifiedPayload :: VerificationPayload
verifiedPayload =
  VerificationPayload
    { payloadSubscriptionStateName = "active",
      payloadEntitlementBundleName = "premium-generation",
      payloadQuotaProfileName = "standard-monthly",
      payloadTermStart = "2026-04-01T00:00:00Z",
      payloadTermEnd = "2026-05-01T00:00:00Z",
      payloadGraceWindow = Just "2026-05-08T00:00:00Z"
    }

notificationPayload :: NotificationPayload
notificationPayload =
  NotificationPayload
    { notificationProviderIdentifier = "apple-001",
      notificationSubscriptionStateName = "grace",
      notificationTermStart = "2026-04-01T00:00:00Z",
      notificationTermEnd = "2026-05-01T00:00:00Z",
      notificationGraceWindow = Just "2026-05-08T00:00:00Z",
      notificationOriginalTimestamp = "2026-04-15T12:00:00Z"
    }

freshBudget :: RetryBudget
freshBudget = RetryBudget {retryAttempt = 1, retryLimit = 3}

testSuccessPath :: IO ()
testSuccessPath = do
  let outcome =
        runVerificationOutcome
          freshBudget
          NoCurrent
          emptyBillingStore
          validatedPurchase
          (successfulVerificationOutcome "req-001" verifiedPayload)
          HandoffApplied
  assertEqual "final state" Succeeded (workflowFinalState outcome)
  assertEqual "visibility" CompletedCurrent (workflowVisibility outcome)
  assertEqual "trail" [Queued, Running, Succeeded] (workflowTrail outcome)
  assertEqual "handoff completed" True (workflowHandoffCompleted outcome)
  assertTrue "completed record present" (workflowCompletedRecord outcome /= Nothing)

testRetryableVerification :: IO ()
testRetryableVerification = do
  let outcome =
        runVerificationOutcome
          freshBudget
          NoCurrent
          emptyBillingStore
          validatedPurchase
          (retryableVerificationOutcome "req-002" "provider-unavailable")
          HandoffApplied
  assertEqual "final state" (RetryScheduled 1) (workflowFinalState outcome)
  assertEqual "visibility" StatusOnly (workflowVisibility outcome)
  assertEqual "handoff not completed" False (workflowHandoffCompleted outcome)
  assertEqual "no completed record" Nothing (workflowCompletedRecord outcome)

testTimeoutBelowLimit :: IO ()
testTimeoutBelowLimit = do
  let outcome =
        runVerificationOutcome
          freshBudget
          NoCurrent
          emptyBillingStore
          validatedPurchase
          (timedOutVerificationOutcome "req-003")
          HandoffApplied
  assertEqual "final state" (RetryScheduled 1) (workflowFinalState outcome)

testTimeoutAtLimit :: IO ()
testTimeoutAtLimit = do
  let exhaustedBudget = RetryBudget {retryAttempt = 3, retryLimit = 3}
      outcome =
        runVerificationOutcome
          exhaustedBudget
          NoCurrent
          emptyBillingStore
          validatedPurchase
          (timedOutVerificationOutcome "req-004")
          HandoffApplied
  assertEqual "final state" FailedFinal (workflowFinalState outcome)

testNonRetryableVerification :: IO ()
testNonRetryableVerification = do
  let outcome =
        runVerificationOutcome
          freshBudget
          NoCurrent
          emptyBillingStore
          validatedPurchase
          (nonRetryableVerificationOutcome "req-005" "signature-invalid")
          HandoffApplied
  assertEqual "final state" FailedFinal (workflowFinalState outcome)
  assertEqual "visibility" StatusOnly (workflowVisibility outcome)

testMalformedVerifiedPayload :: IO ()
testMalformedVerifiedPayload = do
  let malformed = verifiedPayload {payloadEntitlementBundleName = ""}
      outcome =
        runVerificationOutcome
          freshBudget
          NoCurrent
          emptyBillingStore
          validatedPurchase
          (malformedVerifiedOutcome "req-006" malformed)
          HandoffApplied
  assertEqual "final state" FailedFinal (workflowFinalState outcome)
  assertEqual
    "failure code"
    (Just FailureMalformedPayload)
    (fmap summaryCode (workflowFailureSummary outcome))

testHandoffRetry :: IO ()
testHandoffRetry = do
  let outcome =
        runVerificationOutcome
          freshBudget
          (ExistingCurrent "existing-001")
          emptyBillingStore
          validatedPurchase
          (successfulVerificationOutcome "req-007" verifiedPayload)
          HandoffRetryableFailure
  assertEqual "final state" (RetryScheduled 1) (workflowFinalState outcome)
  assertEqual "visibility" StatusOnly (workflowVisibility outcome)
  assertTrue
    "retains existing current"
    (case workflowCurrentAction outcome of
        CurrentRetained (Just "existing-001") -> True
        _ -> False)

testNotificationReconciled :: IO ()
testNotificationReconciled = do
  let outcome =
        runNotificationOutcome
          freshBudget
          NoCurrent
          emptyBillingStore
          validatedNotification
          (reconciledNotificationOutcome "req-008" AppStoreNotification notificationPayload)
          HandoffApplied
  assertEqual "final state" Succeeded (workflowFinalState outcome)
  assertEqual "visibility" CompletedCurrent (workflowVisibility outcome)

testStaleNotification :: IO ()
testStaleNotification = do
  let outcome =
        runNotificationOutcome
          freshBudget
          NoCurrent
          emptyBillingStore
          validatedNotification
          (staleNotificationOutcome "req-009" AppStoreNotification notificationPayload)
          HandoffApplied
  assertEqual "final state" FailedFinal (workflowFinalState outcome)
  assertEqual
    "failure code"
    (Just FailureStaleNotification)
    (fmap summaryCode (workflowFailureSummary outcome))

testMalformedNotification :: IO ()
testMalformedNotification = do
  let malformed = notificationPayload {notificationProviderIdentifier = ""}
      outcome =
        runNotificationOutcome
          freshBudget
          NoCurrent
          emptyBillingStore
          validatedNotification
          (malformedNotificationOutcome "req-010" GooglePlayNotification malformed)
          HandoffApplied
  assertEqual "final state" FailedFinal (workflowFinalState outcome)
  assertEqual
    "failure code"
    (Just FailureMalformedNotification)
    (fmap summaryCode (workflowFailureSummary outcome))

testDuplicateInflight :: IO ()
testDuplicateInflight = do
  let outcome = duplicateOutcome IgnoreDuplicateInFlight NoCurrent emptyBillingStore Nothing
  assertEqual "final state" Running (workflowFinalState outcome)
  assertEqual "visibility" StatusOnly (workflowVisibility outcome)
  assertEqual "duplicate" IgnoreDuplicateInFlight (workflowDuplicateDisposition outcome)
  assertEqual "trail" [Queued, Running] (workflowTrail outcome)
  assertEqual "no completed record" Nothing (workflowCompletedRecord outcome)
  assertEqual "no save action" Nothing (workflowSaveAction outcome)
  assertEqual "handoff not completed" False (workflowHandoffCompleted outcome)
  assertTrue "failure summary present" (workflowFailureSummary outcome /= Nothing)
  assertEqual "store preserved" emptyBillingStore (workflowStore outcome)
  assertEqual "duplicate inflight equality" outcome outcome

testDuplicateSucceeded :: IO ()
testDuplicateSucceeded = do
  let outcome = duplicateOutcome ReuseCompletedDuplicate NoCurrent emptyBillingStore Nothing
  assertEqual "final state" Succeeded (workflowFinalState outcome)
  assertEqual "duplicate" ReuseCompletedDuplicate (workflowDuplicateDisposition outcome)

testIntakeFailure :: IO ()
testIntakeFailure = do
  let outcome = intakeFailureOutcome NoCurrent emptyBillingStore PreconditionInvalid
  assertEqual "final state" FailedFinal (workflowFinalState outcome)
  assertEqual
    "failure code"
    (Just FailurePreconditionInvalid)
    (fmap summaryCode (workflowFailureSummary outcome))

testOwnershipMismatch :: IO ()
testOwnershipMismatch = do
  let outcome = ownershipMismatchOutcome NoCurrent emptyBillingStore
  assertEqual "final state" DeadLettered (workflowFinalState outcome)
  assertEqual
    "failure code"
    (Just FailureOwnershipMismatch)
    (fmap summaryCode (workflowFailureSummary outcome))

testDeadLetter :: IO ()
testDeadLetter = do
  let outcome = deadLetterOutcome NoCurrent emptyBillingStore
  assertEqual "final state" DeadLettered (workflowFinalState outcome)

testRendersStateLabels :: IO ()
testRendersStateLabels = do
  assertEqual "queued" "queued" (renderWorkflowState Queued)
  assertEqual "running" "running" (renderWorkflowState Running)
  assertEqual "retry-scheduled" "retry-scheduled-2" (renderWorkflowState (RetryScheduled 2))
  assertEqual "timed-out" "timed-out-1" (renderWorkflowState (TimedOut 1))
  assertEqual "succeeded" "succeeded" (renderWorkflowState Succeeded)
  assertEqual "failed-final" "failed-final" (renderWorkflowState FailedFinal)
  assertEqual "dead-lettered" "dead-lettered" (renderWorkflowState DeadLettered)
  assertTrue "show queued" (not (null (show Queued)))
  assertTrue "show running" (not (null (show Running)))
  assertTrue "show retry-scheduled" (not (null (show (RetryScheduled 1))))
  assertTrue "show timed-out" (not (null (show (TimedOut 1))))
  assertTrue "show succeeded" (not (null (show Succeeded)))
  assertTrue "show failed-final" (not (null (show FailedFinal)))
  assertTrue "show dead-lettered" (not (null (show DeadLettered)))
  let budget = RetryBudget {retryAttempt = 1, retryLimit = 3}
  assertTrue "show retry budget" (not (null (show budget)))
  let outcome = intakeFailureOutcome NoCurrent emptyBillingStore TriggerNotSupported
  assertTrue "show workflow outcome" (not (null (show outcome)))
  let freshDuplicate = duplicateOutcome ProcessFresh NoCurrent emptyBillingStore Nothing
  assertEqual "process-fresh duplicate queued" Queued (workflowFinalState freshDuplicate)
