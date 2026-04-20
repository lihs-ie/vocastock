module ImageWorker.AssetStoragePortSpec (run) where

import ImageWorker.AssetStoragePort
import TestSupport

run :: IO ()
run = do
  runNamed "accepts a stable asset reference" testAcceptsStoredAsset
  runNamed "rejects invalid asset references" testRejectsInvalidAssets
  runNamed "renders asset validation errors and fixtures" testRendersErrorsAndFixtures
  runNamed "covers accessors and show instances" testAccessorsAndShow

testAcceptsStoredAsset :: IO ()
testAcceptsStoredAsset =
  case storageReference stableStoredAsset of
    Nothing -> error "expected stable asset reference"
    Just storedAssetReference -> do
      assertEqual "asset validation" (Right storedAssetReference) (validateStoredAssetReference storedAssetReference)
      assertEqual "asset reference" "gs://vocastock/images/image-business-key-001.png" (assetReference storedAssetReference)
      assertEqual "asset checksum" "checksum-001" (assetChecksum storedAssetReference)

testRejectsInvalidAssets :: IO ()
testRejectsInvalidAssets = do
  assertEqual
    "missing reference"
    (Left MissingAssetReference)
    (validateStoredAssetReference StoredAssetReference {assetReference = "", assetChecksum = "checksum"})
  assertEqual
    "missing checksum"
    (Left MissingAssetChecksum)
    (validateStoredAssetReference StoredAssetReference {assetReference = "gs://image.png", assetChecksum = ""})

testRendersErrorsAndFixtures :: IO ()
testRendersErrorsAndFixtures = do
  assertEqual "reference label" "missing-asset-reference" (renderAssetValidationError MissingAssetReference)
  assertEqual "checksum label" "missing-asset-checksum" (renderAssetValidationError MissingAssetChecksum)
  assertEqual "stored fixture status" AssetStored (storageStatus stableStoredAsset)
  assertEqual "retry fixture status" AssetStorageRetryableFailure (storageStatus retryableAssetStorageFailure)
  assertEqual "terminal fixture status" AssetStorageNonRetryableFailure (storageStatus nonRetryableAssetStorageFailure)

testAccessorsAndShow :: IO ()
testAccessorsAndShow = do
  assertEqual "request identifier" "image-storage-request-001" (storageRequestIdentifier stableStoredAsset)
  assertEqual "retryable reason" (Just "transient-storage-failure") (storageFailureReason retryableAssetStorageFailure)
  assertEqual "terminal reason" (Just "asset-write-forbidden") (storageFailureReason nonRetryableAssetStorageFailure)
  assertEqual "status equality" True (AssetStored == AssetStored)
  assertEqual "error equality" True (MissingAssetReference == MissingAssetReference)
  assertEqual "show status" "AssetStored" (show AssetStored)
  assertEqual "show error" "MissingAssetReference" (show MissingAssetReference)
  assertEqual "show outcome" True ("AssetStorageOutcome" `elem` words (show stableStoredAsset))
