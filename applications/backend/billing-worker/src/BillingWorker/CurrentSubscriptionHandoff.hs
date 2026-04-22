module BillingWorker.CurrentSubscriptionHandoff
  ( CurrentAction (..),
    ExistingCurrent (..),
    HandoffStatus (..),
    applyCurrentSubscriptionSuccess,
    currentWasRetained,
    renderCurrentAction,
    renderHandoffStatus,
    retainExistingCurrent
  )
where

import BillingWorker.BillingPersistence
  ( CompletedBillingRecord (..)
  )

data ExistingCurrent
  = NoCurrent
  | ExistingCurrent String
  deriving (Eq, Show)

data HandoffStatus
  = HandoffApplied
  | HandoffRetryableFailure
  | HandoffSuperseded
  deriving (Eq, Show)

data CurrentAction
  = CurrentSwitched String
  | CurrentRetained (Maybe String)
  | CurrentSuperseded String
  deriving (Eq, Show)

applyCurrentSubscriptionSuccess ::
  CompletedBillingRecord -> ExistingCurrent -> HandoffStatus -> CurrentAction
applyCurrentSubscriptionSuccess completedRecord existingCurrent handoffStatus =
  case handoffStatus of
    HandoffApplied -> CurrentSwitched (recordIdentifier completedRecord)
    HandoffRetryableFailure -> retainExistingCurrent existingCurrent
    HandoffSuperseded -> CurrentSuperseded (recordIdentifier completedRecord)

retainExistingCurrent :: ExistingCurrent -> CurrentAction
retainExistingCurrent existingCurrent =
  case existingCurrent of
    NoCurrent -> CurrentRetained Nothing
    ExistingCurrent identifierValue -> CurrentRetained (Just identifierValue)

currentWasRetained :: CurrentAction -> Bool
currentWasRetained currentAction =
  case currentAction of
    CurrentRetained _ -> True
    _ -> False

renderCurrentAction :: CurrentAction -> String
renderCurrentAction currentAction =
  case currentAction of
    CurrentSwitched identifierValue -> "switched:" ++ identifierValue
    CurrentRetained Nothing -> "retained:none"
    CurrentRetained (Just identifierValue) -> "retained:" ++ identifierValue
    CurrentSuperseded identifierValue -> "superseded:" ++ identifierValue

renderHandoffStatus :: HandoffStatus -> String
renderHandoffStatus handoffStatus =
  case handoffStatus of
    HandoffApplied -> "applied"
    HandoffRetryableFailure -> "retryable-failure"
    HandoffSuperseded -> "superseded"
