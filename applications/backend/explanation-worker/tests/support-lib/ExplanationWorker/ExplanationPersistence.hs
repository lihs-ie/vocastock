module ExplanationWorker.ExplanationPersistence
  ( CompletedExplanationRecord (..),
    ExplanationStore (..),
    SaveAction (..),
    SaveResult (..),
    completedRecordFor,
    emptyExplanationStore,
    existingRecordFor,
    renderSaveAction,
    saveCompletedExplanation
  )
where

import ExplanationWorker.GenerationPort
  ( CompletedExplanationPayload (..)
  )

data CompletedExplanationRecord = CompletedExplanationRecord
  { recordIdentifier :: String,
    recordVocabularyExpression :: String,
    recordSummary :: String,
    recordSenseCount :: Int
  }
  deriving (Eq, Show)

newtype ExplanationStore = ExplanationStore
  { explanationEntries :: [(String, CompletedExplanationRecord)]
  }
  deriving (Eq, Show)

data SaveAction
  = SaveCreated
  | SaveReused
  deriving (Eq, Show)

data SaveResult = SaveResult
  { saveAction :: SaveAction,
    saveRecord :: CompletedExplanationRecord,
    saveStore :: ExplanationStore
  }
  deriving (Eq, Show)

emptyExplanationStore :: ExplanationStore
emptyExplanationStore = ExplanationStore []

existingRecordFor :: String -> ExplanationStore -> Maybe CompletedExplanationRecord
existingRecordFor businessKey (ExplanationStore entries) = lookup businessKey entries

completedRecordFor ::
  String -> String -> CompletedExplanationPayload -> CompletedExplanationRecord
completedRecordFor businessKey vocabularyExpression payload =
  CompletedExplanationRecord
    { recordIdentifier = businessKey ++ "-completed",
      recordVocabularyExpression = vocabularyExpression,
      recordSummary = payloadSummary payload,
      recordSenseCount = payloadSenseCount payload
    }

renderSaveAction :: SaveAction -> String
renderSaveAction action =
  case action of
    SaveCreated -> "created"
    SaveReused -> "reused"

saveCompletedExplanation ::
  String ->
  String ->
  CompletedExplanationPayload ->
  ExplanationStore ->
  SaveResult
saveCompletedExplanation businessKey vocabularyExpression payload store =
  case existingRecordFor businessKey store of
    Just existingRecord ->
      SaveResult
        { saveAction = SaveReused,
          saveRecord = existingRecord,
          saveStore = store
        }
    Nothing ->
      let newRecord = completedRecordFor businessKey vocabularyExpression payload
          newStore =
            case store of
              ExplanationStore entries ->
                ExplanationStore ((businessKey, newRecord) : entries)
       in SaveResult
            { saveAction = SaveCreated,
              saveRecord = newRecord,
              saveStore = newStore
            }
