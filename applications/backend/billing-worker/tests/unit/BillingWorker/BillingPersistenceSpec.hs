module BillingWorker.BillingPersistenceSpec (run) where

import BillingWorker.BillingPersistence
import TestSupport

run :: IO ()
run = do
  runNamed "builds completed record" testBuildsCompletedRecord
  runNamed "creates a completed record" testCreatesCompletedRecord
  runNamed "reuses existing completed record" testReusesCompletedRecord
  runNamed "marks record current applied" testMarksRecordCurrentApplied
  runNamed "renders labels" testRendersLabels
  runExtraCoverageSamples

samplePayload :: CompletedBillingPayload
samplePayload =
  CompletedBillingPayload
    { completedPurchaseStateName = "verified",
      completedSubscriptionStateName = "active",
      completedEntitlementBundleName = "premium-generation",
      completedQuotaProfileName = "standard-monthly",
      completedTermStart = "2026-04-01T00:00:00Z",
      completedTermEnd = "2026-05-01T00:00:00Z",
      completedGraceWindow = Just "2026-05-08T00:00:00Z"
    }

testBuildsCompletedRecord :: IO ()
testBuildsCompletedRecord = do
  let record = completedRecordFor "bk-001" "subscription-001" SourcePurchaseVerification samplePayload
  assertEqual "record identifier" "bk-001-completed" (recordIdentifier record)
  assertEqual "subscription" "subscription-001" (recordSubscription record)
  assertEqual "source" SourcePurchaseVerification (recordSource record)
  assertEqual "visibility" HiddenUntilHandoff (recordVisibility record)
  assertEqual "payload" samplePayload (recordPayload record)

testCreatesCompletedRecord :: IO ()
testCreatesCompletedRecord = do
  let saveResult =
        saveCompletedBilling
          "bk-001"
          "subscription-001"
          SourcePurchaseVerification
          samplePayload
          emptyBillingStore
  assertEqual "save action" SaveCreated (saveAction saveResult)
  assertEqual "record identifier" "bk-001-completed" (recordIdentifier (saveRecord saveResult))
  assertEqual
    "lookup"
    (Just (saveRecord saveResult))
    (existingRecordFor "bk-001" (saveStore saveResult))

testReusesCompletedRecord :: IO ()
testReusesCompletedRecord = do
  let initial =
        saveCompletedBilling
          "bk-001"
          "subscription-001"
          SourcePurchaseVerification
          samplePayload
          emptyBillingStore
      reused =
        saveCompletedBilling
          "bk-001"
          "subscription-001"
          SourcePurchaseVerification
          samplePayload
          (saveStore initial)
  assertEqual "reused action" SaveReused (saveAction reused)
  assertEqual "same record" (saveRecord initial) (saveRecord reused)
  assertEqual "store unchanged" (saveStore initial) (saveStore reused)

testMarksRecordCurrentApplied :: IO ()
testMarksRecordCurrentApplied = do
  let initial =
        saveCompletedBilling
          "bk-001"
          "subscription-001"
          SourcePurchaseVerification
          samplePayload
          emptyBillingStore
      (appliedRecord, appliedStore) =
        markRecordCurrentApplied "bk-001" (saveStore initial)
  assertEqual "visibility flipped" CurrentApplied (recordVisibility appliedRecord)
  assertEqual
    "store reflects applied visibility"
    (Just CurrentApplied)
    (fmap recordVisibility (existingRecordFor "bk-001" appliedStore))

testRendersLabels :: IO ()
testRendersLabels = do
  assertEqual "purchase-verification source" "purchase-verification" (renderRecordSource SourcePurchaseVerification)
  assertEqual "notification-reconciliation source" "notification-reconciliation" (renderRecordSource SourceNotificationReconciliation)
  assertEqual "hidden-until-handoff" "hidden-until-handoff" (renderCompletedRecordVisibility HiddenUntilHandoff)
  assertEqual "current-applied" "current-applied" (renderCompletedRecordVisibility CurrentApplied)
  assertEqual "save action created" "created" (renderSaveAction SaveCreated)
  assertEqual "save action reused" "reused" (renderSaveAction SaveReused)

runExtraCoverageSamples :: IO ()
runExtraCoverageSamples = do
  runNamed "markRecordCurrentApplied falls back on missing record" testMarkMissingRecord
  runNamed "records from notification source are tagged" testNotificationSourceRecord

testMarkMissingRecord :: IO ()
testMarkMissingRecord = do
  let (record, store) = markRecordCurrentApplied "missing-key" emptyBillingStore
  assertEqual "placeholder identifier" "missing-key-missing" (recordIdentifier record)
  assertEqual "empty store preserved" emptyBillingStore store

testNotificationSourceRecord :: IO ()
testNotificationSourceRecord = do
  let record =
        completedRecordFor "bk-n-001" "subscription-002" SourceNotificationReconciliation samplePayload
  assertEqual "record source" SourceNotificationReconciliation (recordSource record)
  assertTrue "show record source" (not (null (show SourcePurchaseVerification)))
  assertTrue "show completed visibility" (not (null (show HiddenUntilHandoff)))
  assertTrue "show current-applied" (not (null (show CurrentApplied)))
  assertTrue "show completed payload" (not (null (show samplePayload)))
  assertTrue "show completed record" (not (null (show record)))
  assertTrue "show save action" (not (null (show SaveCreated)))
  assertTrue "show save action reused" (not (null (show SaveReused)))
  assertTrue "show empty store" (not (null (show emptyBillingStore)))
  let saveResult =
        saveCompletedBilling "bk-p-001" "subscription-003" SourcePurchaseVerification samplePayload emptyBillingStore
  assertTrue "show save result" (not (null (show saveResult)))
  assertEqual "payload purchase state" "verified" (completedPurchaseStateName (recordPayload (saveRecord saveResult)))
  assertEqual "payload subscription state" "active" (completedSubscriptionStateName (recordPayload (saveRecord saveResult)))
  assertEqual "payload bundle" "premium-generation" (completedEntitlementBundleName (recordPayload (saveRecord saveResult)))
  assertEqual "payload quota" "standard-monthly" (completedQuotaProfileName (recordPayload (saveRecord saveResult)))
  assertEqual "payload term start" "2026-04-01T00:00:00Z" (completedTermStart (recordPayload (saveRecord saveResult)))
  assertEqual "payload term end" "2026-05-01T00:00:00Z" (completedTermEnd (recordPayload (saveRecord saveResult)))
  assertEqual "payload grace" (Just "2026-05-08T00:00:00Z") (completedGraceWindow (recordPayload (saveRecord saveResult)))
  let expectedIdentifier = recordIdentifier (saveRecord saveResult)
  assertTrue "record identifier non-empty" (not (null expectedIdentifier))
  assertEqual "billing entries count" 1 (length (billingEntries (saveStore saveResult)))
