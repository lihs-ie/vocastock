module BillingWorker.NotificationPortSpec (run) where

import BillingWorker.NotificationPort
import TestSupport

run :: IO ()
run = do
  runNamed "accepts normalized payload" testAcceptsNormalizedPayload
  runNamed "rejects missing provider identifier" testRejectsMissingProviderIdentifier
  runNamed "rejects missing state name" testRejectsMissingStateName
  runNamed "rejects missing period" testRejectsMissingPeriod
  runNamed "rejects unknown state name" testRejectsUnknownStateName
  runNamed "builds reconciled outcome" testBuildsReconciledOutcome
  runNamed "builds retryable outcome" testBuildsRetryableOutcome
  runNamed "builds non-retryable outcome" testBuildsNonRetryableOutcome
  runNamed "builds timed-out outcome" testBuildsTimedOutOutcome
  runNamed "builds stale outcome" testBuildsStaleOutcome
  runNamed "parses and renders sources" testParsesAndRendersSources
  runNamed "renders statuses" testRendersStatuses

validPayload :: NotificationPayload
validPayload =
  NotificationPayload
    { notificationProviderIdentifier = "apple-001",
      notificationSubscriptionStateName = "grace",
      notificationTermStart = "2026-04-01T00:00:00Z",
      notificationTermEnd = "2026-05-01T00:00:00Z",
      notificationGraceWindow = Just "2026-05-08T00:00:00Z",
      notificationOriginalTimestamp = "2026-04-15T12:00:00Z"
    }

testAcceptsNormalizedPayload :: IO ()
testAcceptsNormalizedPayload =
  case validateNotificationPayload validPayload of
    Right payload -> assertEqual "returned payload" validPayload payload
    Left issue -> error ("expected Right but got Left " ++ show issue)

testRejectsMissingProviderIdentifier :: IO ()
testRejectsMissingProviderIdentifier =
  case validateNotificationPayload validPayload {notificationProviderIdentifier = ""} of
    Left issue -> assertEqual "missing provider" MissingProviderIdentifier issue
    Right _ -> error "expected Left MissingProviderIdentifier"

testRejectsMissingStateName :: IO ()
testRejectsMissingStateName =
  case validateNotificationPayload validPayload {notificationSubscriptionStateName = ""} of
    Left issue -> assertEqual "missing state" MissingStateName issue
    Right _ -> error "expected Left MissingStateName"

testRejectsMissingPeriod :: IO ()
testRejectsMissingPeriod =
  case validateNotificationPayload validPayload {notificationTermEnd = ""} of
    Left issue -> assertEqual "missing period" MissingNotificationPeriod issue
    Right _ -> error "expected Left MissingNotificationPeriod"

testRejectsUnknownStateName :: IO ()
testRejectsUnknownStateName =
  case validateNotificationPayload validPayload {notificationSubscriptionStateName = "trialing"} of
    Left issue -> assertEqual "unknown state" UnknownStateName issue
    Right _ -> error "expected Left UnknownStateName"

testBuildsReconciledOutcome :: IO ()
testBuildsReconciledOutcome = do
  let outcome = reconciledNotificationOutcome "req-001" AppStoreNotification validPayload
  assertEqual "status" NotificationReconciled (ingestStatus outcome)
  assertEqual "request identifier" "req-001" (ingestRequestIdentifier outcome)
  assertEqual "source" AppStoreNotification (ingestSource outcome)
  assertEqual "payload present" (Just validPayload) (ingestPayload outcome)

testBuildsRetryableOutcome :: IO ()
testBuildsRetryableOutcome = do
  let outcome = retryableNotificationOutcome "req-002" GooglePlayNotification "temporarily unavailable"
  assertEqual "status" NotificationRetryableFailure (ingestStatus outcome)
  assertEqual "reason" (Just "temporarily unavailable") (ingestFailureReason outcome)

testBuildsNonRetryableOutcome :: IO ()
testBuildsNonRetryableOutcome = do
  let outcome = nonRetryableNotificationOutcome "req-003" AppStoreNotification "malformed"
  assertEqual "status" NotificationNonRetryableFailure (ingestStatus outcome)

testBuildsTimedOutOutcome :: IO ()
testBuildsTimedOutOutcome = do
  let outcome = timedOutNotificationOutcome "req-004" GooglePlayNotification
  assertEqual "status" NotificationTimedOut (ingestStatus outcome)

testBuildsStaleOutcome :: IO ()
testBuildsStaleOutcome = do
  let outcome = staleNotificationOutcome "req-005" AppStoreNotification validPayload
  assertEqual "status" NotificationStale (ingestStatus outcome)
  assertEqual "payload present" (Just validPayload) (ingestPayload outcome)

testParsesAndRendersSources :: IO ()
testParsesAndRendersSources = do
  assertEqual "app-store" AppStoreNotification (parseNotificationSource "app-store")
  assertEqual "google-play" GooglePlayNotification (parseNotificationSource "google-play")
  case parseNotificationSource "unknown" of
    UnsupportedNotificationSource "unknown" -> pure ()
    other -> error ("expected UnsupportedNotificationSource but got " ++ show other)
  assertEqual "render app-store" "app-store" (renderNotificationSource AppStoreNotification)
  assertEqual "render google-play" "google-play" (renderNotificationSource GooglePlayNotification)
  assertEqual "render unsupported" "unsupported:x" (renderNotificationSource (UnsupportedNotificationSource "x"))

testRendersStatuses :: IO ()
testRendersStatuses = do
  assertEqual "reconciled" "reconciled" (renderNotificationIngestStatus NotificationReconciled)
  assertEqual "retryable" "retryable-failure" (renderNotificationIngestStatus NotificationRetryableFailure)
  assertEqual "non-retryable" "non-retryable-failure" (renderNotificationIngestStatus NotificationNonRetryableFailure)
  assertEqual "timed-out" "timed-out" (renderNotificationIngestStatus NotificationTimedOut)
  assertEqual "stale" "stale" (renderNotificationIngestStatus NotificationStale)
  let malformed = malformedNotificationOutcome "req-m" AppStoreNotification validPayload {notificationProviderIdentifier = ""}
  assertEqual "malformed status is reconciled" NotificationReconciled (ingestStatus malformed)
  assertTrue "show app-store" (not (null (show AppStoreNotification)))
  assertTrue "show google-play" (not (null (show GooglePlayNotification)))
  assertTrue "show unsupported" (not (null (show (UnsupportedNotificationSource "x"))))
  assertTrue "show payload" (not (null (show validPayload)))
  assertTrue "show outcome" (not (null (show (reconciledNotificationOutcome "r" AppStoreNotification validPayload))))
  assertTrue "show issue missing provider" (not (null (show MissingProviderIdentifier)))
  assertTrue "show issue missing state" (not (null (show MissingStateName)))
  assertTrue "show issue missing period" (not (null (show MissingNotificationPeriod)))
  assertTrue "show issue unknown state" (not (null (show UnknownStateName)))
  assertTrue "show status values" (not (null (show NotificationReconciled)))
  assertTrue "show status stale" (not (null (show NotificationStale)))
