module ImageWorker.ImageGenerationPort
  ( CompletedImagePayload (..),
    GenerationOutcome (..),
    GenerationStatus (..),
    PayloadValidationError (..),
    malformedSuccessOutcome,
    nonRetryableFailureOutcome,
    renderPayloadValidationError,
    retryableFailureOutcome,
    successfulOutcome,
    timedOutOutcome,
    validateCompletedPayload
  )
where

import Data.List (isPrefixOf)

data CompletedImagePayload = CompletedImagePayload
  { payloadAssetSeed :: String,
    payloadMimeType :: String,
    payloadWidth :: Int,
    payloadHeight :: Int,
    payloadSenseAligned :: Bool
  }
  deriving (Eq, Show)

data GenerationStatus
  = GenerationSucceeded
  | GenerationRetryableFailure
  | GenerationNonRetryableFailure
  | GenerationTimedOut
  deriving (Eq, Show)

data GenerationOutcome = GenerationOutcome
  { outcomeRequestIdentifier :: String,
    outcomeStatus :: GenerationStatus,
    outcomePayload :: Maybe CompletedImagePayload,
    outcomeFailureReason :: Maybe String
  }
  deriving (Eq, Show)

data PayloadValidationError
  = MissingAssetSeed
  | InvalidMimeType
  | InvalidDimensions
  | MissingSenseAlignment
  deriving (Eq, Show)

successfulOutcome :: GenerationOutcome
successfulOutcome =
  GenerationOutcome
    { outcomeRequestIdentifier = "image-generation-request-001",
      outcomeStatus = GenerationSucceeded,
      outcomePayload =
        Just
          CompletedImagePayload
            { payloadAssetSeed = "stable-image-seed-001",
              payloadMimeType = "image/png",
              payloadWidth = 1024,
              payloadHeight = 1024,
              payloadSenseAligned = True
            },
      outcomeFailureReason = Nothing
    }

retryableFailureOutcome :: GenerationOutcome
retryableFailureOutcome =
  GenerationOutcome
    { outcomeRequestIdentifier = "image-generation-request-001",
      outcomeStatus = GenerationRetryableFailure,
      outcomePayload = Nothing,
      outcomeFailureReason = Just "transient-image-provider-failure"
    }

timedOutOutcome :: GenerationOutcome
timedOutOutcome =
  GenerationOutcome
    { outcomeRequestIdentifier = "image-generation-request-001",
      outcomeStatus = GenerationTimedOut,
      outcomePayload = Nothing,
      outcomeFailureReason = Just "image-provider-timeout"
    }

nonRetryableFailureOutcome :: GenerationOutcome
nonRetryableFailureOutcome =
  GenerationOutcome
    { outcomeRequestIdentifier = "image-generation-request-001",
      outcomeStatus = GenerationNonRetryableFailure,
      outcomePayload = Nothing,
      outcomeFailureReason = Just "invalid-image-request"
    }

malformedSuccessOutcome :: GenerationOutcome
malformedSuccessOutcome =
  GenerationOutcome
    { outcomeRequestIdentifier = "image-generation-request-001",
      outcomeStatus = GenerationSucceeded,
      outcomePayload =
        Just
          CompletedImagePayload
            { payloadAssetSeed = "",
              payloadMimeType = "text/plain",
              payloadWidth = 0,
              payloadHeight = 0,
              payloadSenseAligned = False
            },
      outcomeFailureReason = Nothing
    }

renderPayloadValidationError :: PayloadValidationError -> String
renderPayloadValidationError payloadValidationError =
  case payloadValidationError of
    MissingAssetSeed -> "missing-asset-seed"
    InvalidMimeType -> "invalid-mime-type"
    InvalidDimensions -> "invalid-dimensions"
    MissingSenseAlignment -> "missing-sense-alignment"

validateCompletedPayload ::
  CompletedImagePayload -> Either PayloadValidationError CompletedImagePayload
validateCompletedPayload payload
  | null (payloadAssetSeed payload) = Left MissingAssetSeed
  | not ("image/" `isPrefixOf` payloadMimeType payload) = Left InvalidMimeType
  | payloadWidth payload < 1 || payloadHeight payload < 1 = Left InvalidDimensions
  | not (payloadSenseAligned payload) = Left MissingSenseAlignment
  | otherwise = Right payload
