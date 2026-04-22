module ExplanationWorker.WorkItemContract
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
  = RegistrationAccepted
  | UnsupportedTrigger String
  deriving (Eq, Show)

data WorkItem = WorkItem
  { workTrigger :: WorkTrigger,
    workBusinessKey :: String,
    workVocabularyExpression :: String,
    workLearner :: String,
    workNormalizedVocabularyExpressionText :: String,
    workRequestCorrelation :: String,
    workStartExplanation :: Bool,
    workTargetExists :: Bool,
    workOwnershipMatches :: Bool,
    workPreconditionValid :: Bool
  }
  deriving (Eq, Show)

data ValidatedWorkItem = ValidatedWorkItem
  { validatedBusinessKey :: String,
    validatedVocabularyExpression :: String,
    validatedLearner :: String,
    validatedNormalizedVocabularyExpressionText :: String,
    validatedRequestCorrelation :: String
  }
  deriving (Eq, Show)

data IntakeFailure
  = TriggerNotSupported
  | ExplanationSuppressed
  | InvalidTarget
  | OwnershipMismatch
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
    { workTrigger = RegistrationAccepted,
      workBusinessKey = "business-key-001",
      workVocabularyExpression = "vocabulary-expression-001",
      workLearner = "learner-001",
      workNormalizedVocabularyExpressionText = "look up",
      workRequestCorrelation = "correlation-001",
      workStartExplanation = True,
      workTargetExists = True,
      workOwnershipMatches = True,
      workPreconditionValid = True
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
renderIntakeFailure failure =
  case failure of
    TriggerNotSupported -> "trigger-not-supported"
    ExplanationSuppressed -> "start-explanation-suppressed"
    InvalidTarget -> "invalid-target"
    OwnershipMismatch -> "ownership-mismatch"
    PreconditionInvalid -> "precondition-invalid"

validateWorkItem :: WorkItem -> Either IntakeFailure ValidatedWorkItem
validateWorkItem workItem
  | workTrigger workItem /= RegistrationAccepted = Left TriggerNotSupported
  | not (workStartExplanation workItem) = Left ExplanationSuppressed
  | null (workBusinessKey workItem)
      || null (workVocabularyExpression workItem)
      || null (workLearner workItem)
      || null (workNormalizedVocabularyExpressionText workItem)
      || null (workRequestCorrelation workItem) =
      Left PreconditionInvalid
  | not (workTargetExists workItem) = Left InvalidTarget
  | not (workOwnershipMatches workItem) = Left OwnershipMismatch
  | not (workPreconditionValid workItem) = Left PreconditionInvalid
  | otherwise =
      Right
        ValidatedWorkItem
          { validatedBusinessKey = workBusinessKey workItem,
            validatedVocabularyExpression = workVocabularyExpression workItem,
            validatedLearner = workLearner workItem,
            validatedNormalizedVocabularyExpressionText =
              workNormalizedVocabularyExpressionText workItem,
            validatedRequestCorrelation = workRequestCorrelation workItem
          }
