module ImageWorker.WorkItemContract
  ( DuplicateDisposition (..),
    DuplicateStatus (..),
    IntakeFailure (..),
    ValidatedWorkItem (..),
    WorkItem (..),
    WorkTrigger (..),
    defaultWorkItem,
    duplicateDisposition,
    renderDuplicateDisposition,
    renderIntakeFailure,
    validateWorkItem
  )
where

data WorkTrigger
  = RequestImageGenerationAccepted
  | UnsupportedTrigger String
  deriving (Eq, Show)

data WorkItem = WorkItem
  { workIdentifier :: String,
    workTrigger :: WorkTrigger,
    workBusinessKey :: String,
    workExplanation :: String,
    workLearner :: String,
    workSense :: Maybe String,
    workReason :: String,
    workRequestCorrelation :: String,
    workAcceptedOrder :: Int
  }
  deriving (Eq, Show)

data ValidatedWorkItem = ValidatedWorkItem
  { validatedIdentifier :: String,
    validatedBusinessKey :: String,
    validatedExplanation :: String,
    validatedLearner :: String,
    validatedSense :: Maybe String,
    validatedReason :: String,
    validatedRequestCorrelation :: String,
    validatedAcceptedOrder :: Int
  }
  deriving (Eq, Show)

data IntakeFailure
  = TriggerNotSupported
  | PreconditionInvalid
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

defaultWorkItem :: WorkItem
defaultWorkItem =
  WorkItem
    { workIdentifier = "image-work-item-001",
      workTrigger = RequestImageGenerationAccepted,
      workBusinessKey = "image-business-key-001",
      workExplanation = "explanation-001",
      workLearner = "learner-001",
      workSense = Just "sense-001",
      workReason = "request-image-generation-accepted",
      workRequestCorrelation = "correlation-001",
      workAcceptedOrder = 3
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

validateWorkItem :: WorkItem -> Either IntakeFailure ValidatedWorkItem
validateWorkItem workItem
  | workTrigger workItem /= RequestImageGenerationAccepted = Left TriggerNotSupported
  | null (workIdentifier workItem)
      || null (workBusinessKey workItem)
      || null (workExplanation workItem)
      || null (workLearner workItem)
      || null (workReason workItem)
      || null (workRequestCorrelation workItem)
      || workAcceptedOrder workItem < 1 =
      Left PreconditionInvalid
  | otherwise =
      Right
        ValidatedWorkItem
          { validatedIdentifier = workIdentifier workItem,
            validatedBusinessKey = workBusinessKey workItem,
            validatedExplanation = workExplanation workItem,
            validatedLearner = workLearner workItem,
            validatedSense = workSense workItem,
            validatedReason = workReason workItem,
            validatedRequestCorrelation = workRequestCorrelation workItem,
            validatedAcceptedOrder = workAcceptedOrder workItem
          }
