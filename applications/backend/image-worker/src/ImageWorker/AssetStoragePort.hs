module ImageWorker.AssetStoragePort
  ( AssetStorageOutcome (..),
    AssetStorageStatus (..),
    AssetValidationError (..),
    StoredAssetReference (..),
    nonRetryableAssetStorageFailure,
    renderAssetValidationError,
    retryableAssetStorageFailure,
    stableStoredAsset,
    validateStoredAssetReference
  )
where

data StoredAssetReference = StoredAssetReference
  { assetReference :: String,
    assetChecksum :: String
  }
  deriving (Eq, Show)

data AssetStorageStatus
  = AssetStored
  | AssetStorageRetryableFailure
  | AssetStorageNonRetryableFailure
  deriving (Eq, Show)

data AssetStorageOutcome = AssetStorageOutcome
  { storageRequestIdentifier :: String,
    storageStatus :: AssetStorageStatus,
    storageReference :: Maybe StoredAssetReference,
    storageFailureReason :: Maybe String
  }
  deriving (Eq, Show)

data AssetValidationError
  = MissingAssetReference
  | MissingAssetChecksum
  deriving (Eq, Show)

stableStoredAsset :: AssetStorageOutcome
stableStoredAsset =
  AssetStorageOutcome
    { storageRequestIdentifier = "image-storage-request-001",
      storageStatus = AssetStored,
      storageReference =
        Just
          StoredAssetReference
            { assetReference = "gs://vocastock/images/image-business-key-001.png",
              assetChecksum = "checksum-001"
            },
      storageFailureReason = Nothing
    }

retryableAssetStorageFailure :: AssetStorageOutcome
retryableAssetStorageFailure =
  AssetStorageOutcome
    { storageRequestIdentifier = "image-storage-request-001",
      storageStatus = AssetStorageRetryableFailure,
      storageReference = Nothing,
      storageFailureReason = Just "transient-storage-failure"
    }

nonRetryableAssetStorageFailure :: AssetStorageOutcome
nonRetryableAssetStorageFailure =
  AssetStorageOutcome
    { storageRequestIdentifier = "image-storage-request-001",
      storageStatus = AssetStorageNonRetryableFailure,
      storageReference = Nothing,
      storageFailureReason = Just "asset-write-forbidden"
    }

renderAssetValidationError :: AssetValidationError -> String
renderAssetValidationError assetValidationError =
  case assetValidationError of
    MissingAssetReference -> "missing-asset-reference"
    MissingAssetChecksum -> "missing-asset-checksum"

validateStoredAssetReference ::
  StoredAssetReference -> Either AssetValidationError StoredAssetReference
validateStoredAssetReference storedAssetReference
  | null (assetReference storedAssetReference) = Left MissingAssetReference
  | null (assetChecksum storedAssetReference) = Left MissingAssetChecksum
  | otherwise = Right storedAssetReference
