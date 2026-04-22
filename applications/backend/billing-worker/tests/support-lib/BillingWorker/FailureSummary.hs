module BillingWorker.FailureSummary
  ( BillingFailureSummary (..),
    FailureClassification (..),
    FailureCode (..),
    PublicStatus (..),
    Visibility (..),
    failureSummaryFor,
    renderFailureClassification,
    renderFailureCode,
    renderPublicStatus,
    renderVisibility
  )
where

data Visibility
  = StatusOnly
  | CompletedCurrent
  deriving (Eq, Show)

data FailureClassification
  = ClassificationRetryable
  | ClassificationTimeout
  | ClassificationTerminal
  | ClassificationDeadLetter
  deriving (Eq, Show)

data PublicStatus
  = PublicRetryScheduled
  | PublicTimedOut
  | PublicFailedFinal
  | PublicDeadLettered
  deriving (Eq, Show)

data FailureCode
  = FailureRetryableVerification
  | FailureRetryableNotificationIngest
  | FailureTimedOut
  | FailureTerminal
  | FailureMalformedPayload
  | FailureMalformedNotification
  | FailureTriggerNotSupported
  | FailurePreconditionInvalid
  | FailureMissingPurchaseArtifact
  | FailureMissingNotificationPayload
  | FailureInvalidTarget
  | FailureOwnershipMismatch
  | FailureHandoffRetry
  | FailureDuplicateInFlight
  | FailureStaleNotification
  | FailureOperatorReview
  deriving (Eq, Show)

data BillingFailureSummary = BillingFailureSummary
  { summaryClassification :: FailureClassification,
    summaryPublicStatus :: PublicStatus,
    summaryCode :: FailureCode,
    summaryMessage :: String,
    summaryRetryable :: Bool,
    summaryLastAttemptNumber :: Int
  }
  deriving (Eq, Show)

failureSummaryFor :: FailureCode -> Int -> BillingFailureSummary
failureSummaryFor failureCode attemptNumber =
  BillingFailureSummary
    { summaryClassification = classificationFor failureCode,
      summaryPublicStatus = publicStatusFor failureCode,
      summaryCode = failureCode,
      summaryMessage = messageFor failureCode,
      summaryRetryable = retryableFor failureCode,
      summaryLastAttemptNumber = attemptNumber
    }

classificationFor :: FailureCode -> FailureClassification
classificationFor failureCode =
  case failureCode of
    FailureRetryableVerification -> ClassificationRetryable
    FailureRetryableNotificationIngest -> ClassificationRetryable
    FailureHandoffRetry -> ClassificationRetryable
    FailureTimedOut -> ClassificationTimeout
    FailureDuplicateInFlight -> ClassificationRetryable
    FailureOperatorReview -> ClassificationDeadLetter
    _ -> ClassificationTerminal

publicStatusFor :: FailureCode -> PublicStatus
publicStatusFor failureCode =
  case failureCode of
    FailureRetryableVerification -> PublicRetryScheduled
    FailureRetryableNotificationIngest -> PublicRetryScheduled
    FailureHandoffRetry -> PublicRetryScheduled
    FailureDuplicateInFlight -> PublicRetryScheduled
    FailureTimedOut -> PublicTimedOut
    FailureOperatorReview -> PublicDeadLettered
    _ -> PublicFailedFinal

retryableFor :: FailureCode -> Bool
retryableFor failureCode =
  case failureCode of
    FailureRetryableVerification -> True
    FailureRetryableNotificationIngest -> True
    FailureHandoffRetry -> True
    FailureDuplicateInFlight -> True
    FailureTimedOut -> True
    _ -> False

messageFor :: FailureCode -> String
messageFor failureCode =
  case failureCode of
    FailureRetryableVerification ->
      "purchase verification temporarily unavailable"
    FailureRetryableNotificationIngest ->
      "store notification ingest temporarily unavailable"
    FailureTimedOut ->
      "billing workflow attempt timed out"
    FailureTerminal ->
      "billing workflow terminated without retry"
    FailureMalformedPayload ->
      "verification payload did not meet billing record requirements"
    FailureMalformedNotification ->
      "store notification payload could not be normalized"
    FailureTriggerNotSupported ->
      "work item trigger is not supported in this slice"
    FailurePreconditionInvalid ->
      "work item precondition invalid"
    FailureMissingPurchaseArtifact ->
      "purchase artifact reference is missing"
    FailureMissingNotificationPayload ->
      "notification payload is missing"
    FailureInvalidTarget ->
      "target subscription is unavailable"
    FailureOwnershipMismatch ->
      "actor does not own target subscription"
    FailureHandoffRetry ->
      "entitlement handoff pending retry"
    FailureDuplicateInFlight ->
      "duplicate work item is in flight"
    FailureStaleNotification ->
      "store notification is stale and was not applied"
    FailureOperatorReview ->
      "operator review is required"

renderVisibility :: Visibility -> String
renderVisibility visibility =
  case visibility of
    StatusOnly -> "status-only"
    CompletedCurrent -> "completed-current"

renderFailureClassification :: FailureClassification -> String
renderFailureClassification classification =
  case classification of
    ClassificationRetryable -> "retryable"
    ClassificationTimeout -> "timeout"
    ClassificationTerminal -> "terminal"
    ClassificationDeadLetter -> "dead-letter"

renderPublicStatus :: PublicStatus -> String
renderPublicStatus publicStatus =
  case publicStatus of
    PublicRetryScheduled -> "retry-scheduled"
    PublicTimedOut -> "timed-out"
    PublicFailedFinal -> "failed-final"
    PublicDeadLettered -> "dead-lettered"

renderFailureCode :: FailureCode -> String
renderFailureCode failureCode =
  case failureCode of
    FailureRetryableVerification -> "retryable-verification"
    FailureRetryableNotificationIngest -> "retryable-notification-ingest"
    FailureTimedOut -> "timed-out"
    FailureTerminal -> "terminal"
    FailureMalformedPayload -> "malformed-payload"
    FailureMalformedNotification -> "malformed-notification"
    FailureTriggerNotSupported -> "trigger-not-supported"
    FailurePreconditionInvalid -> "precondition-invalid"
    FailureMissingPurchaseArtifact -> "missing-purchase-artifact"
    FailureMissingNotificationPayload -> "missing-notification-payload"
    FailureInvalidTarget -> "invalid-target"
    FailureOwnershipMismatch -> "ownership-mismatch"
    FailureHandoffRetry -> "handoff-retry"
    FailureDuplicateInFlight -> "duplicate-in-flight"
    FailureStaleNotification -> "stale-notification"
    FailureOperatorReview -> "operator-review"
