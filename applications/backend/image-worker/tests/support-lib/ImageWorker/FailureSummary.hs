module ImageWorker.FailureSummary
  ( FailureClassification (..),
    FailureCode (..),
    ImageFailureSummary (..),
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
  | CompletedNonCurrent
  deriving (Eq, Show)

data FailureClassification
  = RetryableFailure
  | TimeoutFailure
  | TerminalFailure
  | DeadLetterFailure
  deriving (Eq, Show)

data PublicStatus
  = PublicRetryScheduled
  | PublicTimedOut
  | PublicFailedFinal
  | PublicDeadLettered
  deriving (Eq, Show)

data FailureCode
  = FailureRetryable
  | FailureTimedOut
  | FailureTerminal
  | FailureMalformedPayload
  | FailureInvalidTarget
  | FailureOwnershipMismatch
  | FailureExplanationNotCompleted
  | FailureSenseMismatch
  | FailurePreconditionInvalid
  | FailureTriggerNotSupported
  | FailureDuplicateInFlight
  | FailureAssetStorageRetry
  | FailureHandoffRetry
  | FailureOperatorReview
  deriving (Eq, Show)

data ImageFailureSummary = ImageFailureSummary
  { summaryClassification :: FailureClassification,
    summaryCode :: FailureCode,
    summaryPublicStatus :: PublicStatus,
    summaryMessage :: String,
    summaryRetryable :: Bool,
    summaryLastAttempt :: Int
  }
  deriving (Eq, Show)

renderVisibility :: Visibility -> String
renderVisibility visibility =
  case visibility of
    StatusOnly -> "status-only"
    CompletedCurrent -> "completed-current"
    CompletedNonCurrent -> "completed-non-current"

renderFailureClassification :: FailureClassification -> String
renderFailureClassification failureClassification =
  case failureClassification of
    RetryableFailure -> "retryable"
    TimeoutFailure -> "timeout"
    TerminalFailure -> "terminal"
    DeadLetterFailure -> "dead-letter"

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
    FailureRetryable -> "retryable-failure"
    FailureTimedOut -> "timed-out"
    FailureTerminal -> "terminal-failure"
    FailureMalformedPayload -> "malformed-payload"
    FailureInvalidTarget -> "invalid-target"
    FailureOwnershipMismatch -> "ownership-mismatch"
    FailureExplanationNotCompleted -> "explanation-not-completed"
    FailureSenseMismatch -> "sense-mismatch"
    FailurePreconditionInvalid -> "precondition-invalid"
    FailureTriggerNotSupported -> "trigger-not-supported"
    FailureDuplicateInFlight -> "duplicate-in-flight"
    FailureAssetStorageRetry -> "asset-storage-retry"
    FailureHandoffRetry -> "handoff-retry"
    FailureOperatorReview -> "operator-review"

failureSummaryFor :: FailureCode -> Int -> ImageFailureSummary
failureSummaryFor failureCode lastAttempt =
  case failureCode of
    FailureRetryable ->
      ImageFailureSummary RetryableFailure failureCode PublicRetryScheduled "image generation retry scheduled" True lastAttempt
    FailureTimedOut ->
      ImageFailureSummary TimeoutFailure failureCode PublicTimedOut "image generation timed out before completion" False lastAttempt
    FailureTerminal ->
      ImageFailureSummary TerminalFailure failureCode PublicFailedFinal "image generation failed without retry" False lastAttempt
    FailureMalformedPayload ->
      ImageFailureSummary TerminalFailure failureCode PublicFailedFinal "generated image payload was invalid" False lastAttempt
    FailureInvalidTarget ->
      ImageFailureSummary TerminalFailure failureCode PublicFailedFinal "target explanation was not available" False lastAttempt
    FailureOwnershipMismatch ->
      ImageFailureSummary TerminalFailure failureCode PublicFailedFinal "target explanation did not belong to the learner" False lastAttempt
    FailureExplanationNotCompleted ->
      ImageFailureSummary TerminalFailure failureCode PublicFailedFinal "target explanation was not completed" False lastAttempt
    FailureSenseMismatch ->
      ImageFailureSummary TerminalFailure failureCode PublicFailedFinal "target sense did not belong to the explanation" False lastAttempt
    FailurePreconditionInvalid ->
      ImageFailureSummary TerminalFailure failureCode PublicFailedFinal "work item preconditions were invalid" False lastAttempt
    FailureTriggerNotSupported ->
      ImageFailureSummary TerminalFailure failureCode PublicFailedFinal "work item trigger is not supported in this slice" False lastAttempt
    FailureDuplicateInFlight ->
      ImageFailureSummary TerminalFailure failureCode PublicRetryScheduled "existing in-flight image work was reused" False lastAttempt
    FailureAssetStorageRetry ->
      ImageFailureSummary RetryableFailure failureCode PublicRetryScheduled "asset storage retry scheduled" True lastAttempt
    FailureHandoffRetry ->
      ImageFailureSummary RetryableFailure failureCode PublicRetryScheduled "current image handoff retry scheduled" True lastAttempt
    FailureOperatorReview ->
      ImageFailureSummary DeadLetterFailure failureCode PublicDeadLettered "operator review is required" False lastAttempt
