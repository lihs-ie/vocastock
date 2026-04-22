module ImageWorker.ImagePersistence
  ( CompletedImageVisibility (..),
    CompletedVisualImageRecord (..),
    ImageStore (..),
    SaveAction (..),
    SaveResult (..),
    completedRecordFor,
    emptyImageStore,
    existingRecordFor,
    markRecordCurrentApplied,
    markRecordRetainedNonCurrent,
    renderCompletedImageVisibility,
    renderSaveAction,
    saveCompletedImage
  )
where

import ImageWorker.AssetStoragePort
  ( StoredAssetReference (..)
  )

data CompletedImageVisibility
  = HiddenUntilHandoff
  | CurrentApplied
  | RetainedNonCurrent
  deriving (Eq, Show)

data CompletedVisualImageRecord = CompletedVisualImageRecord
  { recordIdentifier :: String,
    recordExplanation :: String,
    recordSense :: Maybe String,
    recordAssetReference :: String,
    recordVisibility :: CompletedImageVisibility,
    recordAcceptedOrder :: Int
  }
  deriving (Eq, Show)

newtype ImageStore = ImageStore
  { imageEntries :: [(String, CompletedVisualImageRecord)]
  }
  deriving (Eq, Show)

data SaveAction
  = SaveCreated
  | SaveReused
  | SaveRetainedNonCurrent
  deriving (Eq, Show)

data SaveResult = SaveResult
  { saveAction :: SaveAction,
    saveRecord :: CompletedVisualImageRecord,
    saveStore :: ImageStore
  }
  deriving (Eq, Show)

emptyImageStore :: ImageStore
emptyImageStore = ImageStore []

existingRecordFor :: String -> ImageStore -> Maybe CompletedVisualImageRecord
existingRecordFor businessKey (ImageStore entries) = lookup businessKey entries

completedRecordFor ::
  String ->
  String ->
  Maybe String ->
  StoredAssetReference ->
  Int ->
  CompletedVisualImageRecord
completedRecordFor businessKey explanationIdentifier maybeSense storedAssetReference acceptedOrder =
  CompletedVisualImageRecord
    { recordIdentifier = businessKey ++ "-image",
      recordExplanation = explanationIdentifier,
      recordSense = maybeSense,
      recordAssetReference = assetReference storedAssetReference,
      recordVisibility = HiddenUntilHandoff,
      recordAcceptedOrder = acceptedOrder
    }

renderCompletedImageVisibility :: CompletedImageVisibility -> String
renderCompletedImageVisibility completedImageVisibility =
  case completedImageVisibility of
    HiddenUntilHandoff -> "hidden-until-handoff"
    CurrentApplied -> "current-applied"
    RetainedNonCurrent -> "retained-non-current"

renderSaveAction :: SaveAction -> String
renderSaveAction saveActionValue =
  case saveActionValue of
    SaveCreated -> "created"
    SaveReused -> "reused"
    SaveRetainedNonCurrent -> "retained-non-current"

saveCompletedImage ::
  String ->
  String ->
  Maybe String ->
  StoredAssetReference ->
  Int ->
  ImageStore ->
  SaveResult
saveCompletedImage businessKey explanationIdentifier maybeSense storedAssetReference acceptedOrder imageStore =
  case existingRecordFor businessKey imageStore of
    Just existingRecord ->
      SaveResult
        { saveAction = SaveReused,
          saveRecord = existingRecord,
          saveStore = imageStore
        }
    Nothing ->
      let newRecord =
            completedRecordFor
              businessKey
              explanationIdentifier
              maybeSense
              storedAssetReference
              acceptedOrder
          newStore =
            case imageStore of
              ImageStore entries ->
                ImageStore ((businessKey, newRecord) : entries)
       in SaveResult
            { saveAction = SaveCreated,
              saveRecord = newRecord,
              saveStore = newStore
            }

markRecordCurrentApplied :: String -> ImageStore -> (CompletedVisualImageRecord, ImageStore)
markRecordCurrentApplied businessKey imageStore =
  updateRecordVisibility businessKey CurrentApplied imageStore

markRecordRetainedNonCurrent :: String -> ImageStore -> SaveResult
markRecordRetainedNonCurrent businessKey imageStore =
  let (record, updatedStore) = updateRecordVisibility businessKey RetainedNonCurrent imageStore
   in SaveResult
        { saveAction = SaveRetainedNonCurrent,
          saveRecord = record,
          saveStore = updatedStore
        }

updateRecordVisibility ::
  String ->
  CompletedImageVisibility ->
  ImageStore ->
  (CompletedVisualImageRecord, ImageStore)
updateRecordVisibility businessKey completedImageVisibility imageStore =
  case imageStore of
    ImageStore entries ->
      let (updatedEntries, maybeRecord) = rewrite entries
       in case maybeRecord of
            Just updatedRecord -> (updatedRecord, ImageStore updatedEntries)
            Nothing -> error ("missing completed image record for " ++ businessKey)
  where
    rewrite [] = ([], Nothing)
    rewrite ((entryBusinessKey, record) : rest)
      | entryBusinessKey == businessKey =
          let updatedRecord = record {recordVisibility = completedImageVisibility}
           in ((entryBusinessKey, updatedRecord) : rest, Just updatedRecord)
      | otherwise =
          let (updatedRest, maybeRecord) = rewrite rest
           in ((entryBusinessKey, record) : updatedRest, maybeRecord)
