module BillingWorker.WorkItemContract
  ( DuplicateDisposition (..),
    DuplicateStatus (..),
    IntakeFailure (..),
    ValidatedWorkItem (..),
    WorkItem (..),
    WorkTrigger (..),
    defaultPurchaseWorkItem,
    defaultNotificationWorkItem,
    duplicateDisposition,
    renderDuplicateDisposition,
    renderIntakeFailure,
    renderWorkTrigger,
    validateWorkItem
  )
where

data WorkTrigger
  = PurchaseArtifactSubmitted
  | NotificationReceived
  | UnsupportedTrigger String
  deriving (Eq, Show)

data WorkItem = WorkItem
  { workIdentifier :: String,
    workTrigger :: WorkTrigger,
    workBusinessKey :: String,
    workSubscription :: String,
    workActor :: String,
    workPurchaseArtifact :: Maybe String,
    workNotificationPayload :: Maybe String,
    workRequestCorrelation :: String,
    workAcceptedOrder :: Int
  }
  deriving (Eq, Show)

data ValidatedWorkItem = ValidatedWorkItem
  { validatedIdentifier :: String,
    validatedTrigger :: WorkTrigger,
    validatedBusinessKey :: String,
    validatedSubscription :: String,
    validatedActor :: String,
    validatedPurchaseArtifact :: Maybe String,
    validatedNotificationPayload :: Maybe String,
    validatedRequestCorrelation :: String,
    validatedAcceptedOrder :: Int
  }
  deriving (Eq, Show)

data IntakeFailure
  = TriggerNotSupported
  | PreconditionInvalid
  | MissingPurchaseArtifact
  | MissingNotificationPayload
  deriving (Eq, Show)

data DuplicateStatus
  = DuplicateAbsent
  | DuplicateQueued
  | DuplicateRunning
  | DuplicateRetryScheduled
  | DuplicateSucceeded
  deriving (Eq, Show)

data DuplicateDisposition
  = ProcessFresh
  | IgnoreDuplicateInFlight
  | ReuseCompletedDuplicate
  deriving (Eq, Show)

defaultPurchaseWorkItem :: WorkItem
defaultPurchaseWorkItem =
  WorkItem
    { workIdentifier = "billing-work-item-001",
      workTrigger = PurchaseArtifactSubmitted,
      workBusinessKey = "billing-business-key-001",
      workSubscription = "subscription-001",
      workActor = "actor-001",
      workPurchaseArtifact = Just "purchase-artifact-001",
      workNotificationPayload = Nothing,
      workRequestCorrelation = "correlation-001",
      workAcceptedOrder = 1
    }

defaultNotificationWorkItem :: WorkItem
defaultNotificationWorkItem =
  WorkItem
    { workIdentifier = "billing-work-item-002",
      workTrigger = NotificationReceived,
      workBusinessKey = "billing-business-key-002",
      workSubscription = "subscription-001",
      workActor = "actor-001",
      workPurchaseArtifact = Nothing,
      workNotificationPayload = Just "notification-payload-001",
      workRequestCorrelation = "correlation-002",
      workAcceptedOrder = 1
    }

duplicateDisposition :: DuplicateStatus -> DuplicateDisposition
duplicateDisposition status =
  case status of
    DuplicateAbsent -> ProcessFresh
    DuplicateQueued -> IgnoreDuplicateInFlight
    DuplicateRunning -> IgnoreDuplicateInFlight
    DuplicateRetryScheduled -> IgnoreDuplicateInFlight
    DuplicateSucceeded -> ReuseCompletedDuplicate

renderDuplicateDisposition :: DuplicateDisposition -> String
renderDuplicateDisposition disposition =
  case disposition of
    ProcessFresh -> "fresh"
    IgnoreDuplicateInFlight -> "inflight-noop"
    ReuseCompletedDuplicate -> "reuse-completed"

renderIntakeFailure :: IntakeFailure -> String
renderIntakeFailure intakeFailure =
  case intakeFailure of
    TriggerNotSupported -> "trigger-not-supported"
    PreconditionInvalid -> "precondition-invalid"
    MissingPurchaseArtifact -> "missing-purchase-artifact"
    MissingNotificationPayload -> "missing-notification-payload"

renderWorkTrigger :: WorkTrigger -> String
renderWorkTrigger workTriggerValue =
  case workTriggerValue of
    PurchaseArtifactSubmitted -> "purchase-artifact-submitted"
    NotificationReceived -> "notification-received"
    UnsupportedTrigger label -> "unsupported:" ++ label

validateWorkItem :: WorkItem -> Either IntakeFailure ValidatedWorkItem
validateWorkItem workItem
  | not (isSupportedTrigger (workTrigger workItem)) = Left TriggerNotSupported
  | null (workIdentifier workItem)
      || null (workBusinessKey workItem)
      || null (workSubscription workItem)
      || null (workActor workItem)
      || null (workRequestCorrelation workItem)
      || workAcceptedOrder workItem < 1 =
      Left PreconditionInvalid
  | workTrigger workItem == PurchaseArtifactSubmitted
      && not (hasNonEmpty (workPurchaseArtifact workItem)) =
      Left MissingPurchaseArtifact
  | workTrigger workItem == NotificationReceived
      && not (hasNonEmpty (workNotificationPayload workItem)) =
      Left MissingNotificationPayload
  | otherwise =
      Right
        ValidatedWorkItem
          { validatedIdentifier = workIdentifier workItem,
            validatedTrigger = workTrigger workItem,
            validatedBusinessKey = workBusinessKey workItem,
            validatedSubscription = workSubscription workItem,
            validatedActor = workActor workItem,
            validatedPurchaseArtifact = workPurchaseArtifact workItem,
            validatedNotificationPayload = workNotificationPayload workItem,
            validatedRequestCorrelation = workRequestCorrelation workItem,
            validatedAcceptedOrder = workAcceptedOrder workItem
          }

isSupportedTrigger :: WorkTrigger -> Bool
isSupportedTrigger workTriggerValue =
  case workTriggerValue of
    PurchaseArtifactSubmitted -> True
    NotificationReceived -> True
    UnsupportedTrigger _ -> False

hasNonEmpty :: Maybe String -> Bool
hasNonEmpty maybeValue =
  case maybeValue of
    Just value -> not (null value)
    Nothing -> False
