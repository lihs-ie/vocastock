module ImageWorker.FailureSummarySpec (run) where

import ImageWorker.FailureSummary
import TestSupport

run :: IO ()
run = do
  runNamed "maps all failure summaries" testFailureSummaries
  runNamed "renders visibility, public status, and classifications" testRendersLabels
  runNamed "covers show and equality instances" testShowAndEquality

testFailureSummaries :: IO ()
testFailureSummaries =
  mapM_
    assertSummary
    [ (FailureRetryable, RetryableFailure, PublicRetryScheduled, "retryable-failure", True),
      (FailureTimedOut, TimeoutFailure, PublicTimedOut, "timed-out", False),
      (FailureTerminal, TerminalFailure, PublicFailedFinal, "terminal-failure", False),
      (FailureMalformedPayload, TerminalFailure, PublicFailedFinal, "malformed-payload", False),
      (FailureInvalidTarget, TerminalFailure, PublicFailedFinal, "invalid-target", False),
      (FailureOwnershipMismatch, TerminalFailure, PublicFailedFinal, "ownership-mismatch", False),
      (FailureExplanationNotCompleted, TerminalFailure, PublicFailedFinal, "explanation-not-completed", False),
      (FailureSenseMismatch, TerminalFailure, PublicFailedFinal, "sense-mismatch", False),
      (FailurePreconditionInvalid, TerminalFailure, PublicFailedFinal, "precondition-invalid", False),
      (FailureTriggerNotSupported, TerminalFailure, PublicFailedFinal, "trigger-not-supported", False),
      (FailureDuplicateInFlight, TerminalFailure, PublicRetryScheduled, "duplicate-in-flight", False),
      (FailureAssetStorageRetry, RetryableFailure, PublicRetryScheduled, "asset-storage-retry", True),
      (FailureHandoffRetry, RetryableFailure, PublicRetryScheduled, "handoff-retry", True),
      (FailureOperatorReview, DeadLetterFailure, PublicDeadLettered, "operator-review", False)
    ]
  where
    assertSummary (failureCode, expectedClassification, expectedPublicStatus, renderedCode, expectedRetryable) =
      let summaryValue = failureSummaryFor failureCode 2
       in do
            assertEqual "classification" expectedClassification (summaryClassification summaryValue)
            assertEqual "public status" expectedPublicStatus (summaryPublicStatus summaryValue)
            assertEqual "rendered code" renderedCode (renderFailureCode (summaryCode summaryValue))
            assertEqual "retryable" expectedRetryable (summaryRetryable summaryValue)
            assertEqual "last attempt" 2 (summaryLastAttempt summaryValue)

testRendersLabels :: IO ()
testRendersLabels = do
  assertEqual "status-only" "status-only" (renderVisibility StatusOnly)
  assertEqual "completed-current" "completed-current" (renderVisibility CompletedCurrent)
  assertEqual "completed-non-current" "completed-non-current" (renderVisibility CompletedNonCurrent)
  assertEqual "retry public status" "retry-scheduled" (renderPublicStatus PublicRetryScheduled)
  assertEqual "dead letter public status" "dead-lettered" (renderPublicStatus PublicDeadLettered)
  assertEqual "retryable classification" "retryable" (renderFailureClassification RetryableFailure)
  assertEqual "dead letter classification" "dead-letter" (renderFailureClassification DeadLetterFailure)

testShowAndEquality :: IO ()
testShowAndEquality = do
  let summaryValue = failureSummaryFor FailureTerminal 1
  assertEqual "summary equality" True (summaryValue == summaryValue)
  assertEqual "visibility equality" True (StatusOnly == StatusOnly)
  assertEqual "public status equality" True (PublicTimedOut == PublicTimedOut)
  assertEqual "classification equality" True (TerminalFailure == TerminalFailure)
  assertEqual "show visibility" "CompletedNonCurrent" (show CompletedNonCurrent)
  assertEqual "show public status" "PublicDeadLettered" (show PublicDeadLettered)
  assertEqual "show classification" "DeadLetterFailure" (show DeadLetterFailure)
  assertEqual "show code" "FailureTerminal" (show FailureTerminal)
  assertEqual "show summary" True ("ImageFailureSummary" `elem` words (show summaryValue))
