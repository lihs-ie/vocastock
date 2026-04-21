module BillingWorker.CurrentSubscriptionHandoffSpec (run) where

import BillingWorker.BillingPersistence
  ( CompletedBillingPayload (..),
    RecordSource (..),
    completedRecordFor
  )
import BillingWorker.CurrentSubscriptionHandoff
import TestSupport

run :: IO ()
run = do
  runNamed "applied handoff switches current" testAppliedSwitches
  runNamed "retryable handoff retains existing" testRetryableRetains
  runNamed "superseded handoff marks superseded" testSupersededMarks
  runNamed "retain no current keeps Nothing" testRetainNoCurrent
  runNamed "currentWasRetained helper" testCurrentRetainedHelper
  runNamed "renders handoff status" testRendersHandoffStatus
  runNamed "renders current action" testRendersCurrentAction

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

sampleRecord =
  completedRecordFor "bk-001" "subscription-001" SourcePurchaseVerification samplePayload

testAppliedSwitches :: IO ()
testAppliedSwitches = do
  let action = applyCurrentSubscriptionSuccess sampleRecord (ExistingCurrent "previous-001") HandoffApplied
  assertEqual "switched" (CurrentSwitched "bk-001-completed") action

testRetryableRetains :: IO ()
testRetryableRetains = do
  let action = applyCurrentSubscriptionSuccess sampleRecord (ExistingCurrent "previous-001") HandoffRetryableFailure
  assertEqual "retains existing" (CurrentRetained (Just "previous-001")) action

testSupersededMarks :: IO ()
testSupersededMarks = do
  let action = applyCurrentSubscriptionSuccess sampleRecord (ExistingCurrent "previous-001") HandoffSuperseded
  assertEqual "superseded" (CurrentSuperseded "bk-001-completed") action

testRetainNoCurrent :: IO ()
testRetainNoCurrent = do
  let action = retainExistingCurrent NoCurrent
  assertEqual "retains Nothing" (CurrentRetained Nothing) action
  let noCurrentApplied = applyCurrentSubscriptionSuccess sampleRecord NoCurrent HandoffApplied
  assertEqual "no current applied" (CurrentSwitched "bk-001-completed") noCurrentApplied
  let noCurrentRetryable = applyCurrentSubscriptionSuccess sampleRecord NoCurrent HandoffRetryableFailure
  assertEqual "no current retryable" (CurrentRetained Nothing) noCurrentRetryable
  let noCurrentSuperseded = applyCurrentSubscriptionSuccess sampleRecord NoCurrent HandoffSuperseded
  assertEqual "no current superseded" (CurrentSuperseded "bk-001-completed") noCurrentSuperseded

testCurrentRetainedHelper :: IO ()
testCurrentRetainedHelper = do
  assertTrue "retained is true" (currentWasRetained (CurrentRetained Nothing))
  assertEqual "switched is false" False (currentWasRetained (CurrentSwitched "x"))
  assertEqual "superseded is false" False (currentWasRetained (CurrentSuperseded "x"))
  assertEqual "existing no current eq" NoCurrent NoCurrent
  assertEqual "existing some eq" (ExistingCurrent "a") (ExistingCurrent "a")
  assertEqual "handoff applied eq" HandoffApplied HandoffApplied
  assertEqual "current switched eq" (CurrentSwitched "a") (CurrentSwitched "a")

testRendersHandoffStatus :: IO ()
testRendersHandoffStatus = do
  assertEqual "applied" "applied" (renderHandoffStatus HandoffApplied)
  assertEqual "retryable" "retryable-failure" (renderHandoffStatus HandoffRetryableFailure)
  assertEqual "superseded" "superseded" (renderHandoffStatus HandoffSuperseded)

testRendersCurrentAction :: IO ()
testRendersCurrentAction = do
  assertEqual "switched" "switched:bk-001" (renderCurrentAction (CurrentSwitched "bk-001"))
  assertEqual "retained none" "retained:none" (renderCurrentAction (CurrentRetained Nothing))
  assertEqual "retained some" "retained:prev" (renderCurrentAction (CurrentRetained (Just "prev")))
  assertEqual "superseded" "superseded:bk-001" (renderCurrentAction (CurrentSuperseded "bk-001"))
  assertTrue "show existing current none" (not (null (show NoCurrent)))
  assertTrue "show existing current some" (not (null (show (ExistingCurrent "abc"))))
  assertTrue "show handoff applied" (not (null (show HandoffApplied)))
  assertTrue "show handoff retryable" (not (null (show HandoffRetryableFailure)))
  assertTrue "show handoff superseded" (not (null (show HandoffSuperseded)))
  assertTrue "show current switched" (not (null (show (CurrentSwitched "x"))))
  assertTrue "show current retained" (not (null (show (CurrentRetained Nothing))))
  assertTrue "show current superseded" (not (null (show (CurrentSuperseded "y"))))
