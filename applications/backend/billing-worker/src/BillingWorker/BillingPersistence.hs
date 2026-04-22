module BillingWorker.BillingPersistence
  ( BillingStore (..),
    CompletedBillingRecord (..),
    CompletedRecordVisibility (..),
    CompletedBillingPayload (..),
    RecordSource (..),
    SaveAction (..),
    SaveResult (..),
    completedRecordFor,
    emptyBillingStore,
    existingRecordFor,
    markRecordCurrentApplied,
    renderCompletedRecordVisibility,
    renderRecordSource,
    renderSaveAction,
    saveCompletedBilling
  )
where

data RecordSource
  = SourcePurchaseVerification
  | SourceNotificationReconciliation
  deriving (Eq, Show)

data CompletedRecordVisibility
  = HiddenUntilHandoff
  | CurrentApplied
  deriving (Eq, Show)

data CompletedBillingPayload = CompletedBillingPayload
  { completedPurchaseStateName :: String,
    completedSubscriptionStateName :: String,
    completedEntitlementBundleName :: String,
    completedQuotaProfileName :: String,
    completedTermStart :: String,
    completedTermEnd :: String,
    completedGraceWindow :: Maybe String
  }
  deriving (Eq, Show)

data CompletedBillingRecord = CompletedBillingRecord
  { recordIdentifier :: String,
    recordSubscription :: String,
    recordSource :: RecordSource,
    recordVisibility :: CompletedRecordVisibility,
    recordPayload :: CompletedBillingPayload
  }
  deriving (Eq, Show)

data SaveAction
  = SaveCreated
  | SaveReused
  deriving (Eq, Show)

newtype BillingStore = BillingStore
  { billingEntries :: [(String, CompletedBillingRecord)]
  }
  deriving (Eq, Show)

data SaveResult = SaveResult
  { saveAction :: SaveAction,
    saveRecord :: CompletedBillingRecord,
    saveStore :: BillingStore
  }
  deriving (Eq, Show)

emptyBillingStore :: BillingStore
emptyBillingStore = BillingStore {billingEntries = []}

completedRecordFor ::
  String -> String -> RecordSource -> CompletedBillingPayload -> CompletedBillingRecord
completedRecordFor businessKey subscriptionIdentifier source completedPayload =
  CompletedBillingRecord
    { recordIdentifier = businessKey ++ "-completed",
      recordSubscription = subscriptionIdentifier,
      recordSource = source,
      recordVisibility = HiddenUntilHandoff,
      recordPayload = completedPayload
    }

existingRecordFor :: String -> BillingStore -> Maybe CompletedBillingRecord
existingRecordFor businessKey store =
  lookup (businessKey ++ "-completed") (billingEntries store)

saveCompletedBilling ::
  String ->
  String ->
  RecordSource ->
  CompletedBillingPayload ->
  BillingStore ->
  SaveResult
saveCompletedBilling businessKey subscriptionIdentifier source completedPayload store =
  case existingRecordFor businessKey store of
    Just existing ->
      SaveResult
        { saveAction = SaveReused,
          saveRecord = existing,
          saveStore = store
        }
    Nothing ->
      let newRecord = completedRecordFor businessKey subscriptionIdentifier source completedPayload
          updatedStore =
            store
              { billingEntries =
                  (recordIdentifier newRecord, newRecord) : billingEntries store
              }
       in SaveResult
            { saveAction = SaveCreated,
              saveRecord = newRecord,
              saveStore = updatedStore
            }

markRecordCurrentApplied ::
  String -> BillingStore -> (CompletedBillingRecord, BillingStore)
markRecordCurrentApplied businessKey store =
  case existingRecordFor businessKey store of
    Just existing ->
      let appliedRecord = existing {recordVisibility = CurrentApplied}
          updatedStore =
            store
              { billingEntries =
                  ( recordIdentifier appliedRecord,
                    appliedRecord
                  )
                    : filter
                      (\(entryKey, _) -> entryKey /= recordIdentifier appliedRecord)
                      (billingEntries store)
              }
       in (appliedRecord, updatedStore)
    Nothing -> (placeholderRecord businessKey, store)

placeholderRecord :: String -> CompletedBillingRecord
placeholderRecord businessKey =
  CompletedBillingRecord
    { recordIdentifier = businessKey ++ "-missing",
      recordSubscription = "",
      recordSource = SourcePurchaseVerification,
      recordVisibility = HiddenUntilHandoff,
      recordPayload =
        CompletedBillingPayload
          { completedPurchaseStateName = "",
            completedSubscriptionStateName = "",
            completedEntitlementBundleName = "",
            completedQuotaProfileName = "",
            completedTermStart = "",
            completedTermEnd = "",
            completedGraceWindow = Nothing
          }
    }

renderRecordSource :: RecordSource -> String
renderRecordSource source =
  case source of
    SourcePurchaseVerification -> "purchase-verification"
    SourceNotificationReconciliation -> "notification-reconciliation"

renderCompletedRecordVisibility :: CompletedRecordVisibility -> String
renderCompletedRecordVisibility completedVisibility =
  case completedVisibility of
    HiddenUntilHandoff -> "hidden-until-handoff"
    CurrentApplied -> "current-applied"

renderSaveAction :: SaveAction -> String
renderSaveAction saveActionValue =
  case saveActionValue of
    SaveCreated -> "created"
    SaveReused -> "reused"
