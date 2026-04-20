module ExplanationWorker.CurrentExplanationHandoffSpec (run) where

import ExplanationWorker.CurrentExplanationHandoff
import ExplanationWorker.ExplanationPersistence
import ExplanationWorker.GenerationPort
import TestSupport

run :: IO ()
run = do
  runNamed "switches current on success" testSwitchesCurrentOnSuccess
  runNamed "retains current when none exists" testRetainsCurrentWhenAbsent
  runNamed "retains existing current on failure" testRetainsExistingCurrent
  runNamed "renders current actions" testRendersCurrentActions
  runNamed "covers show and equality instances" testShowAndEquality

completedRecord :: CompletedExplanationRecord
completedRecord =
  completedRecordFor
    "business-key-001"
    "vocabulary-expression-001"
    CompletedExplanationPayload
      { payloadSummary = "summary",
        payloadSenseCount = 1,
        payloadHasFrequency = True,
        payloadHasSophistication = True,
        payloadHasPronunciation = True,
        payloadHasEtymology = True,
        payloadHasSimilarExpression = True
      }

testSwitchesCurrentOnSuccess :: IO ()
testSwitchesCurrentOnSuccess =
  assertEqual
    "current action"
    (CurrentSwitched "business-key-001-completed")
    (applyCurrentExplanationSuccess completedRecord (ExistingCurrent "old-current"))

testRetainsCurrentWhenAbsent :: IO ()
testRetainsCurrentWhenAbsent =
  assertEqual
    "retained no current"
    (CurrentRetained Nothing)
    (retainExistingCurrent NoCurrent)

testRetainsExistingCurrent :: IO ()
testRetainsExistingCurrent =
  assertEqual
    "retained current"
    (CurrentRetained (Just "existing-current-001"))
    (retainExistingCurrent (ExistingCurrent "existing-current-001"))

testRendersCurrentActions :: IO ()
testRendersCurrentActions = do
  assertEqual "switch render" "switched" (renderCurrentAction (CurrentSwitched "new-current"))
  assertEqual "retained none render" "retained-none" (renderCurrentAction (CurrentRetained Nothing))
  assertEqual
    "retained existing render"
    "retained-existing"
    (renderCurrentAction (CurrentRetained (Just "existing-current-001")))

testShowAndEquality :: IO ()
testShowAndEquality = do
  assertEqual "no current equality" True (NoCurrent == NoCurrent)
  assertEqual "existing current equality" True (ExistingCurrent "current-001" == ExistingCurrent "current-001")
  assertEqual "current action equality" True (CurrentRetained Nothing == CurrentRetained Nothing)
  assertEqual "show no current" "NoCurrent" (show NoCurrent)
  assertEqual "show existing current" "ExistingCurrent \"current-001\"" (show (ExistingCurrent "current-001"))
  assertEqual "show switched" "CurrentSwitched \"current-001\"" (show (CurrentSwitched "current-001"))
  assertEqual "show retained" "CurrentRetained (Just \"current-001\")" (show (CurrentRetained (Just "current-001")))
