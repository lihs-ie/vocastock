module ImageWorker.ImagePersistenceSpec (run) where

import ImageWorker.AssetStoragePort
import ImageWorker.ImagePersistence
import TestSupport

run :: IO ()
run = do
  runNamed "builds a completed visual image record" testBuildsCompletedRecord
  runNamed "creates and reuses a completed image record" testSavesCompletedRecord
  runNamed "marks current applied and retained non-current" testMarksRecordVisibility
  runNamed "renders save actions and visibility" testRendersLabels
  runNamed "covers accessors and show instances" testAccessorsAndShow

storedAssetReference :: StoredAssetReference
storedAssetReference =
  StoredAssetReference
    { assetReference = "gs://vocastock/images/image-business-key-001.png",
      assetChecksum = "checksum-001"
    }

testBuildsCompletedRecord :: IO ()
testBuildsCompletedRecord = do
  let record = completedRecordFor "image-business-key-001" "explanation-001" (Just "sense-001") storedAssetReference 3
  assertEqual "record identifier" "image-business-key-001-image" (recordIdentifier record)
  assertEqual "record explanation" "explanation-001" (recordExplanation record)
  assertEqual "record sense" (Just "sense-001") (recordSense record)
  assertEqual "record asset reference" "gs://vocastock/images/image-business-key-001.png" (recordAssetReference record)
  assertEqual "record visibility" HiddenUntilHandoff (recordVisibility record)
  assertEqual "record accepted order" 3 (recordAcceptedOrder record)

testSavesCompletedRecord :: IO ()
testSavesCompletedRecord = do
  let created =
        saveCompletedImage
          "image-business-key-001"
          "explanation-001"
          (Just "sense-001")
          storedAssetReference
          3
          emptyImageStore
      reused =
        saveCompletedImage
          "image-business-key-001"
          "explanation-001"
          (Just "sense-001")
          storedAssetReference
          3
          (saveStore created)
  assertEqual "save created" SaveCreated (saveAction created)
  assertEqual "save reused" SaveReused (saveAction reused)
  assertEqual "existing lookup" (Just (saveRecord created)) (existingRecordFor "image-business-key-001" (saveStore created))

testMarksRecordVisibility :: IO ()
testMarksRecordVisibility = do
  let created =
        saveCompletedImage
          "image-business-key-001"
          "explanation-001"
          (Just "sense-001")
          storedAssetReference
          3
          emptyImageStore
      (currentRecord, currentStore) =
        markRecordCurrentApplied "image-business-key-001" (saveStore created)
      retained =
        markRecordRetainedNonCurrent "image-business-key-001" currentStore
  assertEqual "current applied visibility" CurrentApplied (recordVisibility currentRecord)
  assertEqual "retained action" SaveRetainedNonCurrent (saveAction retained)
  assertEqual "retained visibility" RetainedNonCurrent (recordVisibility (saveRecord retained))

testRendersLabels :: IO ()
testRendersLabels = do
  assertEqual "created label" "created" (renderSaveAction SaveCreated)
  assertEqual "reused label" "reused" (renderSaveAction SaveReused)
  assertEqual "retained label" "retained-non-current" (renderSaveAction SaveRetainedNonCurrent)
  assertEqual "hidden visibility" "hidden-until-handoff" (renderCompletedImageVisibility HiddenUntilHandoff)
  assertEqual "current visibility" "current-applied" (renderCompletedImageVisibility CurrentApplied)
  assertEqual "retained visibility" "retained-non-current" (renderCompletedImageVisibility RetainedNonCurrent)

testAccessorsAndShow :: IO ()
testAccessorsAndShow = do
  let created =
        saveCompletedImage
          "image-business-key-001"
          "explanation-001"
          Nothing
          storedAssetReference
          3
          emptyImageStore
  assertEqual "entries length" 1 (length (imageEntries (saveStore created)))
  assertEqual "record equality" True (saveRecord created == saveRecord created)
  assertEqual "store equality" True (saveStore created == saveStore created)
  assertEqual "show save action" "SaveCreated" (show SaveCreated)
  assertEqual "show visibility" "CurrentApplied" (show CurrentApplied)
  assertEqual "show record" True ("CompletedVisualImageRecord" `elem` words (show (saveRecord created)))
