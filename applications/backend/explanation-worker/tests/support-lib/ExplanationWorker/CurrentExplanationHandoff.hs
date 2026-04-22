module ExplanationWorker.CurrentExplanationHandoff
  ( CurrentAction (..),
    ExistingCurrent (..),
    applyCurrentExplanationSuccess,
    renderCurrentAction,
    retainExistingCurrent
  )
where

import ExplanationWorker.ExplanationPersistence
  ( CompletedExplanationRecord (..)
  )

data ExistingCurrent
  = NoCurrent
  | ExistingCurrent String
  deriving (Eq, Show)

data CurrentAction
  = CurrentSwitched String
  | CurrentRetained (Maybe String)
  deriving (Eq, Show)

applyCurrentExplanationSuccess ::
  CompletedExplanationRecord -> ExistingCurrent -> CurrentAction
applyCurrentExplanationSuccess completedRecord _ =
  CurrentSwitched (recordIdentifier completedRecord)

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
