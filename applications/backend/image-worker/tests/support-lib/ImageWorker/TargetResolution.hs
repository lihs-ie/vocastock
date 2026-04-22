module ImageWorker.TargetResolution
  ( CurrentPriority (..),
    ResolvedTarget (..),
    ResolutionFailure (..),
    TargetContext (..),
    defaultTargetContext,
    renderCurrentPriority,
    renderResolutionFailure,
    resolveTarget
  )
where

import ImageWorker.WorkItemContract
  ( ValidatedWorkItem (..)
  )

data ResolutionFailure
  = InvalidTarget
  | OwnershipMismatch
  | ExplanationNotCompleted
  | SenseMismatch
  deriving (Eq, Show)

data CurrentPriority
  = OwnsCurrentAdoption
  | SupersededByNewerAccepted
  deriving (Eq, Show)

data TargetContext = TargetContext
  { targetExists :: Bool,
    targetOwnedByLearner :: Bool,
    targetExplanationCompleted :: Bool,
    targetSenseMatches :: Bool,
    targetLatestAcceptedOrder :: Int
  }
  deriving (Eq, Show)

data ResolvedTarget = ResolvedTarget
  { resolvedExplanation :: String,
    resolvedLearner :: String,
    resolvedSense :: Maybe String,
    resolvedAcceptedOrder :: Int,
    resolvedCurrentPriority :: CurrentPriority
  }
  deriving (Eq, Show)

defaultTargetContext :: TargetContext
defaultTargetContext =
  TargetContext
    { targetExists = True,
      targetOwnedByLearner = True,
      targetExplanationCompleted = True,
      targetSenseMatches = True,
      targetLatestAcceptedOrder = 3
    }

renderResolutionFailure :: ResolutionFailure -> String
renderResolutionFailure resolutionFailure =
  case resolutionFailure of
    InvalidTarget -> "invalid-target"
    OwnershipMismatch -> "ownership-mismatch"
    ExplanationNotCompleted -> "explanation-not-completed"
    SenseMismatch -> "sense-mismatch"

renderCurrentPriority :: CurrentPriority -> String
renderCurrentPriority currentPriority =
  case currentPriority of
    OwnsCurrentAdoption -> "owns-current-adoption"
    SupersededByNewerAccepted -> "superseded-by-newer-accepted"

resolveTarget ::
  ValidatedWorkItem -> TargetContext -> Either ResolutionFailure ResolvedTarget
resolveTarget validatedWorkItem targetContext
  | not (targetExists targetContext) = Left InvalidTarget
  | not (targetOwnedByLearner targetContext) = Left OwnershipMismatch
  | not (targetExplanationCompleted targetContext) = Left ExplanationNotCompleted
  | maybe False (const (not (targetSenseMatches targetContext))) (validatedSense validatedWorkItem) =
      Left SenseMismatch
  | otherwise =
      Right
        ResolvedTarget
          { resolvedExplanation = validatedExplanation validatedWorkItem,
            resolvedLearner = validatedLearner validatedWorkItem,
            resolvedSense = validatedSense validatedWorkItem,
            resolvedAcceptedOrder = validatedAcceptedOrder validatedWorkItem,
            resolvedCurrentPriority =
              if validatedAcceptedOrder validatedWorkItem < targetLatestAcceptedOrder targetContext
                then SupersededByNewerAccepted
                else OwnsCurrentAdoption
          }
