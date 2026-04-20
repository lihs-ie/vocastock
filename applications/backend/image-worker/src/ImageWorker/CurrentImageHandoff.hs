module ImageWorker.CurrentImageHandoff
  ( CurrentAction (..),
    ExistingCurrent (..),
    HandoffStatus (..),
    applyCurrentImageOutcome,
    renderCurrentAction,
    renderHandoffStatus,
    retainExistingCurrent
  )
where

import ImageWorker.ImagePersistence
  ( CompletedVisualImageRecord (..)
  )
import ImageWorker.TargetResolution
  ( CurrentPriority (..)
  )

data ExistingCurrent
  = NoCurrent
  | ExistingCurrent String
  deriving (Eq, Show)

data HandoffStatus
  = HandoffApplied
  | HandoffRetryableFailure
  deriving (Eq, Show)

data CurrentAction
  = CurrentSwitched String
  | CurrentRetained (Maybe String)
  | CurrentSuperseded String
  deriving (Eq, Show)

applyCurrentImageOutcome ::
  CompletedVisualImageRecord ->
  CurrentPriority ->
  ExistingCurrent ->
  HandoffStatus ->
  CurrentAction
applyCurrentImageOutcome completedRecord currentPriority existingCurrent handoffStatus =
  case (currentPriority, handoffStatus) of
    (SupersededByNewerAccepted, _) ->
      CurrentSuperseded (recordIdentifier completedRecord)
    (OwnsCurrentAdoption, HandoffApplied) ->
      CurrentSwitched (recordIdentifier completedRecord)
    (OwnsCurrentAdoption, HandoffRetryableFailure) ->
      retainExistingCurrent existingCurrent

retainExistingCurrent :: ExistingCurrent -> CurrentAction
retainExistingCurrent existingCurrent =
  case existingCurrent of
    NoCurrent -> CurrentRetained Nothing
    ExistingCurrent identifierValue -> CurrentRetained (Just identifierValue)

renderCurrentAction :: CurrentAction -> String
renderCurrentAction currentAction =
  case currentAction of
    CurrentSwitched _ -> "switched"
    CurrentRetained Nothing -> "retained-none"
    CurrentRetained (Just _) -> "retained-existing"
    CurrentSuperseded _ -> "superseded-by-newer-request"

renderHandoffStatus :: HandoffStatus -> String
renderHandoffStatus handoffStatus =
  case handoffStatus of
    HandoffApplied -> "applied"
    HandoffRetryableFailure -> "retryable-failure"
