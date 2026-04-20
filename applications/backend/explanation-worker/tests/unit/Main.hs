module Main (main) where

import qualified ExplanationWorker.CurrentExplanationHandoffSpec
import qualified ExplanationWorker.ExplanationPersistenceSpec
import qualified ExplanationWorker.FailureSummarySpec
import qualified ExplanationWorker.GenerationPortSpec
import qualified ExplanationWorker.WorkItemContractSpec
import qualified ExplanationWorker.WorkerRuntimeSpec
import qualified ExplanationWorker.WorkflowStateMachineSpec

main :: IO ()
main = do
  ExplanationWorker.WorkItemContractSpec.run
  ExplanationWorker.GenerationPortSpec.run
  ExplanationWorker.ExplanationPersistenceSpec.run
  ExplanationWorker.CurrentExplanationHandoffSpec.run
  ExplanationWorker.FailureSummarySpec.run
  ExplanationWorker.WorkflowStateMachineSpec.run
  ExplanationWorker.WorkerRuntimeSpec.run
