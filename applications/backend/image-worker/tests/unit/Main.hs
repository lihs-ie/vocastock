module Main (main) where

import qualified ImageWorker.AssetStoragePortSpec
import qualified ImageWorker.CurrentImageHandoffSpec
import qualified ImageWorker.FailureSummarySpec
import qualified ImageWorker.ImageGenerationPortSpec
import qualified ImageWorker.ImagePersistenceSpec
import qualified ImageWorker.PreviousImageInvariantSpec
import qualified ImageWorker.PullLoopPromptSpec
import qualified ImageWorker.SenseAttachmentInvariantSpec
import qualified ImageWorker.StabilityAdapterSpec
import qualified ImageWorker.TargetResolutionSpec
import qualified ImageWorker.WorkItemContractSpec
import qualified ImageWorker.WorkerRuntimeSpec
import qualified ImageWorker.WorkflowStateMachineSpec

main :: IO ()
main = do
  ImageWorker.WorkItemContractSpec.run
  ImageWorker.TargetResolutionSpec.run
  ImageWorker.ImageGenerationPortSpec.run
  ImageWorker.AssetStoragePortSpec.run
  ImageWorker.ImagePersistenceSpec.run
  ImageWorker.PreviousImageInvariantSpec.run
  ImageWorker.SenseAttachmentInvariantSpec.run
  ImageWorker.PullLoopPromptSpec.run
  ImageWorker.CurrentImageHandoffSpec.run
  ImageWorker.FailureSummarySpec.run
  ImageWorker.WorkflowStateMachineSpec.run
  ImageWorker.WorkerRuntimeSpec.run
  ImageWorker.StabilityAdapterSpec.run
