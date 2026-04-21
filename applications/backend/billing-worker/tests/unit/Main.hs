module Main (main) where

import qualified BillingWorker.BillingPersistenceSpec
import qualified BillingWorker.CurrentSubscriptionHandoffSpec
import qualified BillingWorker.EntitlementRecalcPortSpec
import qualified BillingWorker.FailureSummarySpec
import qualified BillingWorker.NotificationPortSpec
import qualified BillingWorker.PurchaseVerificationPortSpec
import qualified BillingWorker.SubscriptionAuthorityPortSpec
import qualified BillingWorker.WorkItemContractSpec
import qualified BillingWorker.WorkerRuntimeSpec
import qualified BillingWorker.WorkflowStateMachineSpec

main :: IO ()
main = do
  BillingWorker.WorkItemContractSpec.run
  BillingWorker.FailureSummarySpec.run
  BillingWorker.PurchaseVerificationPortSpec.run
  BillingWorker.SubscriptionAuthorityPortSpec.run
  BillingWorker.EntitlementRecalcPortSpec.run
  BillingWorker.NotificationPortSpec.run
  BillingWorker.BillingPersistenceSpec.run
  BillingWorker.CurrentSubscriptionHandoffSpec.run
  BillingWorker.WorkflowStateMachineSpec.run
  BillingWorker.WorkerRuntimeSpec.run
