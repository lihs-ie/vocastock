module BillingWorker.FailureSummarySpec (run) where

import Data.List (isInfixOf)

import BillingWorker.FailureSummary
import TestSupport

run :: IO ()
run = do
  runNamed "classifies retryable verification failure" testClassifiesRetryable
  runNamed "classifies timeout" testClassifiesTimeout
  runNamed "classifies terminal" testClassifiesTerminal
  runNamed "classifies dead letter" testClassifiesDeadLetter
  runNamed "redacts provider detail in message" testRedactsProviderDetail
  runNamed "exercises message mapping for all codes" testCoversAllMessages
  runNamed "renders failure codes and statuses" testRendersLabels

testClassifiesRetryable :: IO ()
testClassifiesRetryable = do
  let summary = failureSummaryFor FailureRetryableVerification 2
  assertEqual "classification" ClassificationRetryable (summaryClassification summary)
  assertEqual "public status" PublicRetryScheduled (summaryPublicStatus summary)
  assertEqual "retryable flag" True (summaryRetryable summary)
  assertEqual "attempt number" 2 (summaryLastAttemptNumber summary)

testClassifiesTimeout :: IO ()
testClassifiesTimeout = do
  let summary = failureSummaryFor FailureTimedOut 1
  assertEqual "classification" ClassificationTimeout (summaryClassification summary)
  assertEqual "public status" PublicTimedOut (summaryPublicStatus summary)
  assertEqual "retryable flag" True (summaryRetryable summary)

testClassifiesTerminal :: IO ()
testClassifiesTerminal = do
  let summary = failureSummaryFor FailureMalformedPayload 1
  assertEqual "classification" ClassificationTerminal (summaryClassification summary)
  assertEqual "public status" PublicFailedFinal (summaryPublicStatus summary)
  assertEqual "retryable flag" False (summaryRetryable summary)

testClassifiesDeadLetter :: IO ()
testClassifiesDeadLetter = do
  let summary = failureSummaryFor FailureOperatorReview 3
  assertEqual "classification" ClassificationDeadLetter (summaryClassification summary)
  assertEqual "public status" PublicDeadLettered (summaryPublicStatus summary)

testRedactsProviderDetail :: IO ()
testRedactsProviderDetail = do
  let summary = failureSummaryFor FailureMalformedPayload 1
  assertTrue
    "message excludes credential/stack tokens"
    ( not
        ( "credential" `isInfixOf` summaryMessage summary
            || "stack" `isInfixOf` summaryMessage summary
            || "receipt:" `isInfixOf` summaryMessage summary
        )
    )

testCoversAllMessages :: IO ()
testCoversAllMessages = do
  let codes =
        [ FailureRetryableVerification,
          FailureRetryableNotificationIngest,
          FailureTimedOut,
          FailureTerminal,
          FailureMalformedPayload,
          FailureMalformedNotification,
          FailureTriggerNotSupported,
          FailurePreconditionInvalid,
          FailureMissingPurchaseArtifact,
          FailureMissingNotificationPayload,
          FailureInvalidTarget,
          FailureOwnershipMismatch,
          FailureHandoffRetry,
          FailureDuplicateInFlight,
          FailureStaleNotification,
          FailureOperatorReview
        ]
  mapM_ (\failureCode ->
    let summary = failureSummaryFor failureCode 1
     in do
          assertTrue
            ("message non-empty for " ++ renderFailureCode failureCode)
            (not (null (summaryMessage summary)))
          assertTrue ("show summary for " ++ renderFailureCode failureCode) (not (null (show summary))))
    codes
  assertTrue "show visibility" (not (null (show StatusOnly)))
  assertTrue "show completed visibility" (not (null (show CompletedCurrent)))
  assertTrue "show classification retryable" (not (null (show ClassificationRetryable)))
  assertTrue "show classification timeout" (not (null (show ClassificationTimeout)))
  assertTrue "show classification terminal" (not (null (show ClassificationTerminal)))
  assertTrue "show classification dead letter" (not (null (show ClassificationDeadLetter)))
  assertTrue "show public retry-scheduled" (not (null (show PublicRetryScheduled)))
  assertTrue "show public timed-out" (not (null (show PublicTimedOut)))
  assertTrue "show public failed-final" (not (null (show PublicFailedFinal)))
  assertTrue "show public dead-lettered" (not (null (show PublicDeadLettered)))

testRendersLabels :: IO ()
testRendersLabels = do
  assertEqual "visibility status-only" "status-only" (renderVisibility StatusOnly)
  assertEqual "visibility completed-current" "completed-current" (renderVisibility CompletedCurrent)
  assertEqual "classification retryable" "retryable" (renderFailureClassification ClassificationRetryable)
  assertEqual "classification timeout" "timeout" (renderFailureClassification ClassificationTimeout)
  assertEqual "classification terminal" "terminal" (renderFailureClassification ClassificationTerminal)
  assertEqual "classification dead letter" "dead-letter" (renderFailureClassification ClassificationDeadLetter)
  assertEqual "public retry-scheduled" "retry-scheduled" (renderPublicStatus PublicRetryScheduled)
  assertEqual "public timed-out" "timed-out" (renderPublicStatus PublicTimedOut)
  assertEqual "public failed-final" "failed-final" (renderPublicStatus PublicFailedFinal)
  assertEqual "public dead-lettered" "dead-lettered" (renderPublicStatus PublicDeadLettered)
  assertEqual "code retryable-verification" "retryable-verification" (renderFailureCode FailureRetryableVerification)
  assertEqual "code retryable-notification-ingest" "retryable-notification-ingest" (renderFailureCode FailureRetryableNotificationIngest)
  assertEqual "code timed-out" "timed-out" (renderFailureCode FailureTimedOut)
  assertEqual "code terminal" "terminal" (renderFailureCode FailureTerminal)
  assertEqual "code malformed-payload" "malformed-payload" (renderFailureCode FailureMalformedPayload)
  assertEqual "code malformed-notification" "malformed-notification" (renderFailureCode FailureMalformedNotification)
  assertEqual "code trigger-not-supported" "trigger-not-supported" (renderFailureCode FailureTriggerNotSupported)
  assertEqual "code precondition-invalid" "precondition-invalid" (renderFailureCode FailurePreconditionInvalid)
  assertEqual "code missing-purchase-artifact" "missing-purchase-artifact" (renderFailureCode FailureMissingPurchaseArtifact)
  assertEqual "code missing-notification-payload" "missing-notification-payload" (renderFailureCode FailureMissingNotificationPayload)
  assertEqual "code invalid-target" "invalid-target" (renderFailureCode FailureInvalidTarget)
  assertEqual "code ownership-mismatch" "ownership-mismatch" (renderFailureCode FailureOwnershipMismatch)
  assertEqual "code handoff-retry" "handoff-retry" (renderFailureCode FailureHandoffRetry)
  assertEqual "code duplicate-in-flight" "duplicate-in-flight" (renderFailureCode FailureDuplicateInFlight)
  assertEqual "code stale-notification" "stale-notification" (renderFailureCode FailureStaleNotification)
  assertEqual "code operator-review" "operator-review" (renderFailureCode FailureOperatorReview)
