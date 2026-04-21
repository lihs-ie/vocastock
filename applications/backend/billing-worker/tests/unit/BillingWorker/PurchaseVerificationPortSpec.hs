module BillingWorker.PurchaseVerificationPortSpec (run) where

import BillingWorker.PurchaseVerificationPort
import TestSupport

run :: IO ()
run = do
  runNamed "accepts verified payload" testAcceptsVerifiedPayload
  runNamed "rejects missing subscription state" testRejectsMissingSubscriptionState
  runNamed "rejects missing entitlement bundle" testRejectsMissingEntitlementBundle
  runNamed "rejects missing quota profile" testRejectsMissingQuotaProfile
  runNamed "rejects missing effective period" testRejectsMissingEffectivePeriod
  runNamed "rejects unknown subscription state" testRejectsUnknownSubscriptionState
  runNamed "rejects unknown entitlement bundle" testRejectsUnknownEntitlementBundle
  runNamed "rejects unknown quota profile" testRejectsUnknownQuotaProfile
  runNamed "builds successful outcome" testBuildsSuccessfulOutcome
  runNamed "builds retryable outcome" testBuildsRetryableOutcome
  runNamed "builds non-retryable outcome" testBuildsNonRetryableOutcome
  runNamed "builds timed-out outcome" testBuildsTimedOutOutcome
  runNamed "renders statuses" testRendersStatuses

validPayload :: VerificationPayload
validPayload =
  VerificationPayload
    { payloadSubscriptionStateName = "active",
      payloadEntitlementBundleName = "premium-generation",
      payloadQuotaProfileName = "standard-monthly",
      payloadTermStart = "2026-04-01T00:00:00Z",
      payloadTermEnd = "2026-05-01T00:00:00Z",
      payloadGraceWindow = Just "2026-05-08T00:00:00Z"
    }

testAcceptsVerifiedPayload :: IO ()
testAcceptsVerifiedPayload =
  case validateVerificationPayload validPayload of
    Right payload -> assertEqual "returned payload" validPayload payload
    Left issue -> error ("expected Right but got Left " ++ show issue)

testRejectsMissingSubscriptionState :: IO ()
testRejectsMissingSubscriptionState =
  case validateVerificationPayload validPayload {payloadSubscriptionStateName = ""} of
    Left issue -> assertEqual "missing state" MissingSubscriptionState issue
    Right _ -> error "expected Left MissingSubscriptionState"

testRejectsMissingEntitlementBundle :: IO ()
testRejectsMissingEntitlementBundle =
  case validateVerificationPayload validPayload {payloadEntitlementBundleName = ""} of
    Left issue -> assertEqual "missing bundle" MissingEntitlementBundle issue
    Right _ -> error "expected Left MissingEntitlementBundle"

testRejectsMissingQuotaProfile :: IO ()
testRejectsMissingQuotaProfile =
  case validateVerificationPayload validPayload {payloadQuotaProfileName = ""} of
    Left issue -> assertEqual "missing quota" MissingQuotaProfile issue
    Right _ -> error "expected Left MissingQuotaProfile"

testRejectsMissingEffectivePeriod :: IO ()
testRejectsMissingEffectivePeriod =
  case validateVerificationPayload validPayload {payloadTermStart = ""} of
    Left issue -> assertEqual "missing period" MissingEffectivePeriod issue
    Right _ -> error "expected Left MissingEffectivePeriod"

testRejectsUnknownSubscriptionState :: IO ()
testRejectsUnknownSubscriptionState =
  case validateVerificationPayload validPayload {payloadSubscriptionStateName = "trialing"} of
    Left issue -> assertEqual "unknown state" UnknownSubscriptionState issue
    Right _ -> error "expected Left UnknownSubscriptionState"

testRejectsUnknownEntitlementBundle :: IO ()
testRejectsUnknownEntitlementBundle =
  case validateVerificationPayload validPayload {payloadEntitlementBundleName = "platinum"} of
    Left issue -> assertEqual "unknown bundle" UnknownEntitlementBundle issue
    Right _ -> error "expected Left UnknownEntitlementBundle"

testRejectsUnknownQuotaProfile :: IO ()
testRejectsUnknownQuotaProfile =
  case validateVerificationPayload validPayload {payloadQuotaProfileName = "enterprise"} of
    Left issue -> assertEqual "unknown quota" UnknownQuotaProfile issue
    Right _ -> error "expected Left UnknownQuotaProfile"

testBuildsSuccessfulOutcome :: IO ()
testBuildsSuccessfulOutcome = do
  let outcome = successfulVerificationOutcome "request-001" validPayload
  assertEqual "status" VerificationVerified (outcomeStatus outcome)
  assertEqual "request identifier" "request-001" (outcomeRequestIdentifier outcome)
  assertEqual "payload present" (Just validPayload) (outcomePayload outcome)
  assertEqual "no failure reason" Nothing (outcomeFailureReason outcome)

testBuildsRetryableOutcome :: IO ()
testBuildsRetryableOutcome = do
  let outcome = retryableVerificationOutcome "request-002" "temporarily unavailable"
  assertEqual "status" VerificationRetryableFailure (outcomeStatus outcome)
  assertEqual "payload absent" Nothing (outcomePayload outcome)
  assertEqual "redacted reason" (Just "temporarily unavailable") (outcomeFailureReason outcome)

testBuildsNonRetryableOutcome :: IO ()
testBuildsNonRetryableOutcome = do
  let outcome = nonRetryableVerificationOutcome "request-003" "signature invalid"
  assertEqual "status" VerificationNonRetryableFailure (outcomeStatus outcome)
  assertEqual "redacted reason" (Just "signature invalid") (outcomeFailureReason outcome)

testBuildsTimedOutOutcome :: IO ()
testBuildsTimedOutOutcome = do
  let outcome = timedOutVerificationOutcome "request-004"
  assertEqual "status" VerificationTimedOut (outcomeStatus outcome)
  assertEqual "payload absent" Nothing (outcomePayload outcome)

testRendersStatuses :: IO ()
testRendersStatuses = do
  assertEqual "verified" "verified" (renderVerificationStatus VerificationVerified)
  assertEqual "retryable" "retryable-failure" (renderVerificationStatus VerificationRetryableFailure)
  assertEqual "non-retryable" "non-retryable-failure" (renderVerificationStatus VerificationNonRetryableFailure)
  assertEqual "timed-out" "timed-out" (renderVerificationStatus VerificationTimedOut)
  let malformed = malformedVerifiedOutcome "req-m" validPayload {payloadSubscriptionStateName = ""}
  assertEqual "malformed status" VerificationVerified (outcomeStatus malformed)
  assertTrue "show verified" (not (null (show VerificationVerified)))
  assertTrue "show retryable" (not (null (show VerificationRetryableFailure)))
  assertTrue "show non-retryable" (not (null (show VerificationNonRetryableFailure)))
  assertTrue "show timed-out" (not (null (show VerificationTimedOut)))
  assertTrue "show payload" (not (null (show validPayload)))
  assertTrue "show outcome" (not (null (show (successfulVerificationOutcome "req-x" validPayload))))
  assertTrue "show issue missing state" (not (null (show MissingSubscriptionState)))
  assertTrue "show issue unknown state" (not (null (show UnknownSubscriptionState)))
  assertTrue "show issue unknown bundle" (not (null (show UnknownEntitlementBundle)))
  assertTrue "show issue unknown quota" (not (null (show UnknownQuotaProfile)))
  assertTrue "show issue missing bundle" (not (null (show MissingEntitlementBundle)))
  assertTrue "show issue missing quota" (not (null (show MissingQuotaProfile)))
  assertTrue "show issue missing period" (not (null (show MissingEffectivePeriod)))
