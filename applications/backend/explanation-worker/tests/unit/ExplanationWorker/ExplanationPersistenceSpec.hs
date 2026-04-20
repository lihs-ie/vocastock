module ExplanationWorker.ExplanationPersistenceSpec (run) where

import Data.List (isInfixOf)

import ExplanationWorker.ExplanationPersistence
import ExplanationWorker.GenerationPort
import TestSupport

run :: IO ()
run = do
  runNamed "builds a completed record" testBuildsCompletedRecord
  runNamed "creates a completed record once" testCreatesCompletedRecord
  runNamed "reuses an existing completed record" testReusesCompletedRecord
  runNamed "renders save actions and store lookups" testRendersSaveActionsAndLookups
  runNamed "covers accessors and show instances" testAccessorsAndShow

payload :: CompletedExplanationPayload
payload =
  CompletedExplanationPayload
    { payloadSummary = "summary",
      payloadSenseCount = 2,
      payloadHasFrequency = True,
      payloadHasSophistication = True,
      payloadHasPronunciation = True,
      payloadHasEtymology = True,
      payloadHasSimilarExpression = True
      }

testBuildsCompletedRecord :: IO ()
testBuildsCompletedRecord = do
  let record = completedRecordFor "business-key-001" "vocabulary-expression-001" payload
  assertEqual "record identifier" "business-key-001-completed" (recordIdentifier record)
  assertEqual "record summary" "summary" (recordSummary record)
  assertEqual "record sense count" 2 (recordSenseCount record)

testCreatesCompletedRecord :: IO ()
testCreatesCompletedRecord = do
  let saveResult =
        saveCompletedExplanation "business-key-001" "vocabulary-expression-001" payload emptyExplanationStore
  assertEqual "save action" SaveCreated (saveAction saveResult)
  assertEqual "record identifier" "business-key-001-completed" (recordIdentifier (saveRecord saveResult))
  assertEqual
    "store lookup"
    (Just (saveRecord saveResult))
    (existingRecordFor "business-key-001" (saveStore saveResult))

testReusesCompletedRecord :: IO ()
testReusesCompletedRecord = do
  let initial = saveCompletedExplanation "business-key-001" "vocabulary-expression-001" payload emptyExplanationStore
      reused =
        saveCompletedExplanation
          "business-key-001"
          "vocabulary-expression-001"
          payload
          (saveStore initial)
  assertEqual "reused action" SaveReused (saveAction reused)
  assertEqual "same identifier" (recordIdentifier (saveRecord initial)) (recordIdentifier (saveRecord reused))
  assertEqual "store unchanged" (saveStore initial) (saveStore reused)

testRendersSaveActionsAndLookups :: IO ()
testRendersSaveActionsAndLookups = do
  assertEqual "render created" "created" (renderSaveAction SaveCreated)
  assertEqual "render reused" "reused" (renderSaveAction SaveReused)
  assertEqual "empty lookup" Nothing (existingRecordFor "missing" emptyExplanationStore)

testAccessorsAndShow :: IO ()
testAccessorsAndShow = do
  let saveResult =
        saveCompletedExplanation "business-key-001" "vocabulary-expression-001" payload emptyExplanationStore
      record = saveRecord saveResult
      store = saveStore saveResult
  assertEqual "record vocabulary accessor" "vocabulary-expression-001" (recordVocabularyExpression record)
  assertEqual "entries length" 1 (length (explanationEntries store))
  assertEqual "save result equality" True (saveResult == saveResult)
  assertEqual "record equality" True (record == record)
  assertEqual "store equality" True (store == store)
  assertEqual "save action equality" True (SaveCreated == SaveCreated)
  assertEqual "show save created" "SaveCreated" (show SaveCreated)
  assertEqual "show save reused" "SaveReused" (show SaveReused)
  assertTrue "show record" ("vocabulary-expression-001" `isInfixOf` show record)
  assertTrue "show store" ("ExplanationStore" `elem` words (show store))
  assertTrue "show save result" ("SaveResult" `elem` words (show saveResult))
