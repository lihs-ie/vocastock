module ExplanationWorker.FailureSummary
  ( ExplanationFailureSummary (..),
    FailureCode (..),
    Visibility (..),
    failureSummaryFor,
    renderFailureCode,
    renderVisibility
  )
where

data Visibility
  = StatusOnly
  | CompletedCurrent
  deriving (Eq, Show)

data FailureCode
  = FailureRetryable
  | FailureTimedOut
  | FailureTerminal
  | FailureMalformedPayload
  | FailureInvalidTarget
  | FailureOwnershipMismatch
  | FailurePreconditionInvalid
  | FailureTriggerNotSupported
  | FailureExplanationSuppressed
  | FailureDuplicateInFlight
  deriving (Eq, Show)

data ExplanationFailureSummary = ExplanationFailureSummary
  { summaryCode :: FailureCode,
    summaryMessage :: String,
    summaryRetryable :: Bool
  }
  deriving (Eq, Show)

renderVisibility :: Visibility -> String
renderVisibility visibility =
  case visibility of
    StatusOnly -> "status-only"
    CompletedCurrent -> "completed-current"

renderFailureCode :: FailureCode -> String
renderFailureCode failureCode =
  case failureCode of
    FailureRetryable -> "retryable-failure"
    FailureTimedOut -> "timed-out"
    FailureTerminal -> "terminal-failure"
    FailureMalformedPayload -> "malformed-payload"
    FailureInvalidTarget -> "invalid-target"
    FailureOwnershipMismatch -> "ownership-mismatch"
    FailurePreconditionInvalid -> "precondition-invalid"
    FailureTriggerNotSupported -> "trigger-not-supported"
    FailureExplanationSuppressed -> "start-explanation-suppressed"
    FailureDuplicateInFlight -> "duplicate-in-flight"

failureSummaryFor :: FailureCode -> ExplanationFailureSummary
failureSummaryFor failureCode =
  case failureCode of
    FailureRetryable ->
      ExplanationFailureSummary failureCode "retry scheduled" True
    FailureTimedOut ->
      ExplanationFailureSummary failureCode "timed out before completion" False
    FailureTerminal ->
      ExplanationFailureSummary failureCode "generation failed without retry" False
    FailureMalformedPayload ->
      ExplanationFailureSummary failureCode "completed payload was invalid" False
    FailureInvalidTarget ->
      ExplanationFailureSummary failureCode "target vocabulary expression was not available" False
    FailureOwnershipMismatch ->
      ExplanationFailureSummary failureCode "operator review required for ownership mismatch" False
    FailurePreconditionInvalid ->
      ExplanationFailureSummary failureCode "work item preconditions were invalid" False
    FailureTriggerNotSupported ->
      ExplanationFailureSummary failureCode "work item trigger is not supported in this slice" False
    FailureExplanationSuppressed ->
      ExplanationFailureSummary failureCode "explanation generation is suppressed" False
    FailureDuplicateInFlight ->
      ExplanationFailureSummary failureCode "existing in-flight work was reused" False
