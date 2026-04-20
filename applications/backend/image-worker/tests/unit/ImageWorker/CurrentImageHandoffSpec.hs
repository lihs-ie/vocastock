module ImageWorker.CurrentImageHandoffSpec (run) where

import ImageWorker.AssetStoragePort
import ImageWorker.CurrentImageHandoff
import ImageWorker.ImagePersistence
import ImageWorker.TargetResolution
import TestSupport

run :: IO ()
run = do
  runNamed "switches current on successful handoff" testSwitchesCurrentOnSuccess
  runNamed "retains current on handoff retry" testRetainsCurrentOnRetry
  runNamed "supersedes stale success" testSupersedesStaleSuccess
  runNamed "renders current actions and handoff status" testRendersLabels
  runNamed "covers show and equality instances" testShowAndEquality

completedRecord :: CompletedVisualImageRecord
completedRecord =
  completedRecordFor
    "image-business-key-001"
    "explanation-001"
    (Just "sense-001")
    StoredAssetReference
      { assetReference = "gs://vocastock/images/image-business-key-001.png",
        assetChecksum = "checksum-001"
      }
    3

testSwitchesCurrentOnSuccess :: IO ()
testSwitchesCurrentOnSuccess =
  assertEqual
    "switched action"
    (CurrentSwitched "image-business-key-001-image")
    (applyCurrentImageOutcome completedRecord OwnsCurrentAdoption (ExistingCurrent "old-current") HandoffApplied)

testRetainsCurrentOnRetry :: IO ()
testRetainsCurrentOnRetry =
  assertEqual
    "retained action"
    (CurrentRetained (Just "existing-current-image-001"))
    (applyCurrentImageOutcome completedRecord OwnsCurrentAdoption (ExistingCurrent "existing-current-image-001") HandoffRetryableFailure)

testSupersedesStaleSuccess :: IO ()
testSupersedesStaleSuccess =
  assertEqual
    "superseded action"
    (CurrentSuperseded "image-business-key-001-image")
    (applyCurrentImageOutcome completedRecord SupersededByNewerAccepted (ExistingCurrent "existing-current-image-001") HandoffApplied)

testRendersLabels :: IO ()
testRendersLabels = do
  assertEqual "switched label" "switched" (renderCurrentAction (CurrentSwitched "image-business-key-001-image"))
  assertEqual "retained none label" "retained-none" (renderCurrentAction (CurrentRetained Nothing))
  assertEqual "retained existing label" "retained-existing" (renderCurrentAction (CurrentRetained (Just "current-image-001")))
  assertEqual "superseded label" "superseded-by-newer-request" (renderCurrentAction (CurrentSuperseded "image-business-key-001-image"))
  assertEqual "handoff applied label" "applied" (renderHandoffStatus HandoffApplied)
  assertEqual "handoff retry label" "retryable-failure" (renderHandoffStatus HandoffRetryableFailure)

testShowAndEquality :: IO ()
testShowAndEquality = do
  assertEqual "no current equality" True (NoCurrent == NoCurrent)
  assertEqual "existing current equality" True (ExistingCurrent "current-image-001" == ExistingCurrent "current-image-001")
  assertEqual "handoff status equality" True (HandoffApplied == HandoffApplied)
  assertEqual "current action equality" True (CurrentRetained Nothing == CurrentRetained Nothing)
  assertEqual "show no current" "NoCurrent" (show NoCurrent)
  assertEqual "show current action" "CurrentSuperseded \"image-business-key-001-image\"" (show (CurrentSuperseded "image-business-key-001-image"))
