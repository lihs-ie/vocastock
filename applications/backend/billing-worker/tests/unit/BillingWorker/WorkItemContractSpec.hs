module BillingWorker.WorkItemContractSpec (run) where

import BillingWorker.WorkItemContract
import TestSupport

run :: IO ()
run = do
  runNamed "accepts default purchase work item" testAcceptsDefaultPurchaseWorkItem
  runNamed "accepts default notification work item" testAcceptsDefaultNotificationWorkItem
  runNamed "rejects unsupported trigger" testRejectsUnsupportedTrigger
  runNamed "rejects precondition-invalid items" testRejectsPreconditionInvalid
  runNamed "rejects missing purchase artifact" testRejectsMissingPurchaseArtifact
  runNamed "rejects missing notification payload" testRejectsMissingNotificationPayload
  runNamed "maps duplicate statuses to dispositions" testMapsDuplicateDispositions
  runNamed "renders labels" testRendersLabels

testAcceptsDefaultPurchaseWorkItem :: IO ()
testAcceptsDefaultPurchaseWorkItem =
  case validateWorkItem defaultPurchaseWorkItem of
    Right validated -> do
      assertEqual "identifier" "billing-work-item-001" (validatedIdentifier validated)
      assertEqual "trigger" PurchaseArtifactSubmitted (validatedTrigger validated)
      assertEqual "business key" "billing-business-key-001" (validatedBusinessKey validated)
      assertEqual "subscription" "subscription-001" (validatedSubscription validated)
      assertEqual "actor" "actor-001" (validatedActor validated)
      assertEqual "purchase artifact" (Just "purchase-artifact-001") (validatedPurchaseArtifact validated)
      assertEqual "notification payload" Nothing (validatedNotificationPayload validated)
      assertEqual "request correlation" "correlation-001" (validatedRequestCorrelation validated)
      assertEqual "accepted order" 1 (validatedAcceptedOrder validated)
      assertEqual "equality" True (validated == validated)
    Left intakeFailure -> error ("expected Right but got Left " ++ show intakeFailure)

testAcceptsDefaultNotificationWorkItem :: IO ()
testAcceptsDefaultNotificationWorkItem =
  case validateWorkItem defaultNotificationWorkItem of
    Right validated -> do
      assertEqual "trigger" NotificationReceived (validatedTrigger validated)
      assertEqual "notification payload present" True (validatedNotificationPayload validated /= Nothing)
    Left intakeFailure -> error ("expected Right but got Left " ++ show intakeFailure)

testRejectsUnsupportedTrigger :: IO ()
testRejectsUnsupportedTrigger =
  case validateWorkItem (defaultPurchaseWorkItem {workTrigger = UnsupportedTrigger "restore"}) of
    Left failure -> assertEqual "trigger not supported" TriggerNotSupported failure
    Right _ -> error "expected Left TriggerNotSupported"

testRejectsPreconditionInvalid :: IO ()
testRejectsPreconditionInvalid =
  case validateWorkItem (defaultPurchaseWorkItem {workSubscription = ""}) of
    Left failure -> assertEqual "precondition invalid" PreconditionInvalid failure
    Right _ -> error "expected Left PreconditionInvalid"

testRejectsMissingPurchaseArtifact :: IO ()
testRejectsMissingPurchaseArtifact =
  case validateWorkItem (defaultPurchaseWorkItem {workPurchaseArtifact = Nothing}) of
    Left failure -> assertEqual "missing purchase artifact" MissingPurchaseArtifact failure
    Right _ -> error "expected Left MissingPurchaseArtifact"

testRejectsMissingNotificationPayload :: IO ()
testRejectsMissingNotificationPayload =
  case validateWorkItem (defaultNotificationWorkItem {workNotificationPayload = Nothing}) of
    Left failure -> assertEqual "missing notification payload" MissingNotificationPayload failure
    Right _ -> error "expected Left MissingNotificationPayload"

testMapsDuplicateDispositions :: IO ()
testMapsDuplicateDispositions = do
  assertEqual "absent" ProcessFresh (duplicateDisposition DuplicateAbsent)
  assertEqual "queued" IgnoreDuplicateInFlight (duplicateDisposition DuplicateQueued)
  assertEqual "running" IgnoreDuplicateInFlight (duplicateDisposition DuplicateRunning)
  assertEqual "retry-scheduled" IgnoreDuplicateInFlight (duplicateDisposition DuplicateRetryScheduled)
  assertEqual "succeeded" ReuseCompletedDuplicate (duplicateDisposition DuplicateSucceeded)

testRendersLabels :: IO ()
testRendersLabels = do
  assertEqual "render trigger purchase" "purchase-artifact-submitted" (renderWorkTrigger PurchaseArtifactSubmitted)
  assertEqual "render trigger notification" "notification-received" (renderWorkTrigger NotificationReceived)
  assertEqual "render trigger unsupported" "unsupported:restore" (renderWorkTrigger (UnsupportedTrigger "restore"))
  assertEqual "render intake trigger" "trigger-not-supported" (renderIntakeFailure TriggerNotSupported)
  assertEqual "render intake precondition" "precondition-invalid" (renderIntakeFailure PreconditionInvalid)
  assertEqual "render intake missing purchase" "missing-purchase-artifact" (renderIntakeFailure MissingPurchaseArtifact)
  assertEqual "render intake missing notification" "missing-notification-payload" (renderIntakeFailure MissingNotificationPayload)
  assertEqual "render fresh" "fresh" (renderDuplicateDisposition ProcessFresh)
  assertEqual "render inflight-noop" "inflight-noop" (renderDuplicateDisposition IgnoreDuplicateInFlight)
  assertEqual "render reuse-completed" "reuse-completed" (renderDuplicateDisposition ReuseCompletedDuplicate)
  assertEqual
    "empty purchase artifact is missing"
    (Left MissingPurchaseArtifact)
    (fmap (const ()) (validateWorkItem (defaultPurchaseWorkItem {workPurchaseArtifact = Just ""})))
  assertEqual
    "empty notification payload is missing"
    (Left MissingNotificationPayload)
    (fmap (const ()) (validateWorkItem (defaultNotificationWorkItem {workNotificationPayload = Just ""})))
  assertEqual
    "missing identifier is precondition invalid"
    (Left PreconditionInvalid)
    (fmap (const ()) (validateWorkItem (defaultPurchaseWorkItem {workIdentifier = ""})))
  assertEqual
    "missing business key is precondition invalid"
    (Left PreconditionInvalid)
    (fmap (const ()) (validateWorkItem (defaultPurchaseWorkItem {workBusinessKey = ""})))
  assertEqual
    "missing actor is precondition invalid"
    (Left PreconditionInvalid)
    (fmap (const ()) (validateWorkItem (defaultPurchaseWorkItem {workActor = ""})))
  assertEqual
    "missing correlation is precondition invalid"
    (Left PreconditionInvalid)
    (fmap (const ()) (validateWorkItem (defaultPurchaseWorkItem {workRequestCorrelation = ""})))
  assertEqual
    "non-positive accepted order is precondition invalid"
    (Left PreconditionInvalid)
    (fmap (const ()) (validateWorkItem (defaultPurchaseWorkItem {workAcceptedOrder = 0})))
  assertTrue "show trigger purchase" (not (null (show PurchaseArtifactSubmitted)))
  assertTrue "show trigger notification" (not (null (show NotificationReceived)))
  assertTrue "show trigger unsupported" (not (null (show (UnsupportedTrigger "x"))))
  assertTrue "show work item" (not (null (show defaultPurchaseWorkItem)))
  assertTrue "show validated" (not (null (show (validateWorkItem defaultPurchaseWorkItem))))
  assertTrue "show intake failure" (not (null (show TriggerNotSupported)))
  assertTrue "show intake precondition" (not (null (show PreconditionInvalid)))
  assertTrue "show intake missing purchase" (not (null (show MissingPurchaseArtifact)))
  assertTrue "show intake missing notification" (not (null (show MissingNotificationPayload)))
  assertTrue "show duplicate absent" (not (null (show DuplicateAbsent)))
  assertTrue "show duplicate queued" (not (null (show DuplicateQueued)))
  assertTrue "show duplicate running" (not (null (show DuplicateRunning)))
  assertTrue "show duplicate retry-scheduled" (not (null (show DuplicateRetryScheduled)))
  assertTrue "show duplicate succeeded" (not (null (show DuplicateSucceeded)))
  assertTrue "show process fresh" (not (null (show ProcessFresh)))
  assertTrue "show ignore duplicate" (not (null (show IgnoreDuplicateInFlight)))
  assertTrue "show reuse completed" (not (null (show ReuseCompletedDuplicate)))
