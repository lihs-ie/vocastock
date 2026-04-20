module ExplanationWorker.FailureSummarySpec (run) where

import ExplanationWorker.FailureSummary
import TestSupport

run :: IO ()
run = do
  runNamed "maps all failure summaries" testFailureSummaries
  runNamed "renders all visibility values" testVisibilityRendering
  runNamed "covers show and equality instances" testShowAndEquality

testFailureSummaries :: IO ()
testFailureSummaries =
  mapM_
    assertSummary
    [ (FailureRetryable, "retryable-failure", "retry scheduled", True),
      (FailureTimedOut, "timed-out", "timed out before completion", False),
      (FailureTerminal, "terminal-failure", "generation failed without retry", False),
      (FailureMalformedPayload, "malformed-payload", "completed payload was invalid", False),
      (FailureInvalidTarget, "invalid-target", "target vocabulary expression was not available", False),
      (FailureOwnershipMismatch, "ownership-mismatch", "operator review required for ownership mismatch", False),
      (FailurePreconditionInvalid, "precondition-invalid", "work item preconditions were invalid", False),
      (FailureTriggerNotSupported, "trigger-not-supported", "work item trigger is not supported in this slice", False),
      (FailureExplanationSuppressed, "start-explanation-suppressed", "explanation generation is suppressed", False),
      (FailureDuplicateInFlight, "duplicate-in-flight", "existing in-flight work was reused", False)
    ]
  where
    assertSummary (failureCode, rendered, message, retryable) =
      let summaryValue = failureSummaryFor failureCode
       in do
            assertEqual "failure code render" rendered (renderFailureCode (summaryCode summaryValue))
            assertEqual "failure message" message (summaryMessage summaryValue)
            assertEqual "retryable flag" retryable (summaryRetryable summaryValue)

testVisibilityRendering :: IO ()
testVisibilityRendering = do
  assertEqual "status-only visibility" "status-only" (renderVisibility StatusOnly)
  assertEqual "completed visibility" "completed-current" (renderVisibility CompletedCurrent)

testShowAndEquality :: IO ()
testShowAndEquality = do
  let summaryValue = failureSummaryFor FailureTerminal
  assertEqual "summary equality" True (summaryValue == summaryValue)
  assertEqual "failure code equality" True (FailureRetryable == FailureRetryable)
  assertEqual "visibility equality" True (StatusOnly == StatusOnly)
  assertEqual "show status visibility" "StatusOnly" (show StatusOnly)
  assertEqual "show completed visibility" "CompletedCurrent" (show CompletedCurrent)
  assertEqual "show failure code" "FailureTerminal" (show FailureTerminal)
  assertEqual
    "show summary"
    "ExplanationFailureSummary {summaryCode = FailureTerminal, summaryMessage = \"generation failed without retry\", summaryRetryable = False}"
    (show summaryValue)
