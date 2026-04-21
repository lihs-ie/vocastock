module BillingWorker.NotificationPort
  ( NotificationIngestOutcome (..),
    NotificationIngestStatus (..),
    NotificationPayload (..),
    NotificationPayloadIssue (..),
    NotificationSource (..),
    malformedNotificationOutcome,
    nonRetryableNotificationOutcome,
    parseNotificationSource,
    reconciledNotificationOutcome,
    renderNotificationIngestStatus,
    renderNotificationSource,
    retryableNotificationOutcome,
    staleNotificationOutcome,
    timedOutNotificationOutcome,
    validateNotificationPayload
  )
where

data NotificationSource
  = AppStoreNotification
  | GooglePlayNotification
  | UnsupportedNotificationSource String
  deriving (Eq, Show)

data NotificationIngestStatus
  = NotificationReconciled
  | NotificationRetryableFailure
  | NotificationNonRetryableFailure
  | NotificationTimedOut
  | NotificationStale
  deriving (Eq, Show)

data NotificationPayload = NotificationPayload
  { notificationProviderIdentifier :: String,
    notificationSubscriptionStateName :: String,
    notificationTermStart :: String,
    notificationTermEnd :: String,
    notificationGraceWindow :: Maybe String,
    notificationOriginalTimestamp :: String
  }
  deriving (Eq, Show)

data NotificationIngestOutcome = NotificationIngestOutcome
  { ingestStatus :: NotificationIngestStatus,
    ingestRequestIdentifier :: String,
    ingestSource :: NotificationSource,
    ingestPayload :: Maybe NotificationPayload,
    ingestFailureReason :: Maybe String
  }
  deriving (Eq, Show)

data NotificationPayloadIssue
  = MissingProviderIdentifier
  | MissingStateName
  | MissingNotificationPeriod
  | UnknownStateName
  deriving (Eq, Show)

reconciledNotificationOutcome ::
  String ->
  NotificationSource ->
  NotificationPayload ->
  NotificationIngestOutcome
reconciledNotificationOutcome requestIdentifier source reconciledPayload =
  NotificationIngestOutcome
    { ingestStatus = NotificationReconciled,
      ingestRequestIdentifier = requestIdentifier,
      ingestSource = source,
      ingestPayload = Just reconciledPayload,
      ingestFailureReason = Nothing
    }

malformedNotificationOutcome ::
  String ->
  NotificationSource ->
  NotificationPayload ->
  NotificationIngestOutcome
malformedNotificationOutcome requestIdentifier source malformedPayload =
  NotificationIngestOutcome
    { ingestStatus = NotificationReconciled,
      ingestRequestIdentifier = requestIdentifier,
      ingestSource = source,
      ingestPayload = Just malformedPayload,
      ingestFailureReason = Nothing
    }

retryableNotificationOutcome ::
  String -> NotificationSource -> String -> NotificationIngestOutcome
retryableNotificationOutcome requestIdentifier source redactedReason =
  NotificationIngestOutcome
    { ingestStatus = NotificationRetryableFailure,
      ingestRequestIdentifier = requestIdentifier,
      ingestSource = source,
      ingestPayload = Nothing,
      ingestFailureReason = Just redactedReason
    }

nonRetryableNotificationOutcome ::
  String -> NotificationSource -> String -> NotificationIngestOutcome
nonRetryableNotificationOutcome requestIdentifier source redactedReason =
  NotificationIngestOutcome
    { ingestStatus = NotificationNonRetryableFailure,
      ingestRequestIdentifier = requestIdentifier,
      ingestSource = source,
      ingestPayload = Nothing,
      ingestFailureReason = Just redactedReason
    }

timedOutNotificationOutcome ::
  String -> NotificationSource -> NotificationIngestOutcome
timedOutNotificationOutcome requestIdentifier source =
  NotificationIngestOutcome
    { ingestStatus = NotificationTimedOut,
      ingestRequestIdentifier = requestIdentifier,
      ingestSource = source,
      ingestPayload = Nothing,
      ingestFailureReason = Nothing
    }

staleNotificationOutcome ::
  String ->
  NotificationSource ->
  NotificationPayload ->
  NotificationIngestOutcome
staleNotificationOutcome requestIdentifier source stalePayload =
  NotificationIngestOutcome
    { ingestStatus = NotificationStale,
      ingestRequestIdentifier = requestIdentifier,
      ingestSource = source,
      ingestPayload = Just stalePayload,
      ingestFailureReason = Just "stale-notification"
    }

parseNotificationSource :: String -> NotificationSource
parseNotificationSource sourceLabel =
  case sourceLabel of
    "app-store" -> AppStoreNotification
    "google-play" -> GooglePlayNotification
    other -> UnsupportedNotificationSource other

renderNotificationSource :: NotificationSource -> String
renderNotificationSource source =
  case source of
    AppStoreNotification -> "app-store"
    GooglePlayNotification -> "google-play"
    UnsupportedNotificationSource label -> "unsupported:" ++ label

renderNotificationIngestStatus :: NotificationIngestStatus -> String
renderNotificationIngestStatus notificationIngestStatus =
  case notificationIngestStatus of
    NotificationReconciled -> "reconciled"
    NotificationRetryableFailure -> "retryable-failure"
    NotificationNonRetryableFailure -> "non-retryable-failure"
    NotificationTimedOut -> "timed-out"
    NotificationStale -> "stale"

validateNotificationPayload ::
  NotificationPayload -> Either NotificationPayloadIssue NotificationPayload
validateNotificationPayload notificationPayload
  | null (notificationProviderIdentifier notificationPayload) =
      Left MissingProviderIdentifier
  | null (notificationSubscriptionStateName notificationPayload) =
      Left MissingStateName
  | null (notificationTermStart notificationPayload)
      || null (notificationTermEnd notificationPayload) =
      Left MissingNotificationPeriod
  | not (isKnownSubscriptionState (notificationSubscriptionStateName notificationPayload)) =
      Left UnknownStateName
  | otherwise = Right notificationPayload

isKnownSubscriptionState :: String -> Bool
isKnownSubscriptionState stateName =
  stateName `elem` ["active", "grace", "expired", "pending-sync", "revoked"]
