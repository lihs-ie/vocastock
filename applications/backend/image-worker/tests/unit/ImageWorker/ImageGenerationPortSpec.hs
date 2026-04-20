module ImageWorker.ImageGenerationPortSpec (run) where

import ImageWorker.ImageGenerationPort
import TestSupport

run :: IO ()
run = do
  runNamed "accepts a completed image payload" testAcceptsCompletedPayload
  runNamed "rejects invalid payload variants" testRejectsPayloadVariants
  runNamed "renders payload validation errors and fixtures" testRendersErrorsAndFixtures
  runNamed "covers accessors and show instances" testAccessorsAndShow

testAcceptsCompletedPayload :: IO ()
testAcceptsCompletedPayload =
  case outcomePayload successfulOutcome of
    Nothing -> error "expected successful image payload"
    Just payload -> do
      assertEqual "payload validation" (Right payload) (validateCompletedPayload payload)
      assertEqual "asset seed" "stable-image-seed-001" (payloadAssetSeed payload)
      assertEqual "mime type" "image/png" (payloadMimeType payload)
      assertEqual "width" 1024 (payloadWidth payload)
      assertEqual "height" 1024 (payloadHeight payload)
      assertEqual "sense aligned" True (payloadSenseAligned payload)

testRejectsPayloadVariants :: IO ()
testRejectsPayloadVariants = do
  assertEqual
    "missing asset seed"
    (Left MissingAssetSeed)
    ( validateCompletedPayload
        CompletedImagePayload
          { payloadAssetSeed = "",
            payloadMimeType = "image/png",
            payloadWidth = 1024,
            payloadHeight = 1024,
            payloadSenseAligned = True
          }
    )
  assertEqual
    "invalid mime type"
    (Left InvalidMimeType)
    ( validateCompletedPayload
        CompletedImagePayload
          { payloadAssetSeed = "seed",
            payloadMimeType = "application/json",
            payloadWidth = 1024,
            payloadHeight = 1024,
            payloadSenseAligned = True
          }
    )
  assertEqual
    "invalid dimensions"
    (Left InvalidDimensions)
    ( validateCompletedPayload
        CompletedImagePayload
          { payloadAssetSeed = "seed",
            payloadMimeType = "image/png",
            payloadWidth = 0,
            payloadHeight = 1,
            payloadSenseAligned = True
          }
    )
  assertEqual
    "missing sense alignment"
    (Left MissingSenseAlignment)
    ( validateCompletedPayload
        CompletedImagePayload
          { payloadAssetSeed = "seed",
            payloadMimeType = "image/png",
            payloadWidth = 1,
            payloadHeight = 1,
            payloadSenseAligned = False
          }
    )

testRendersErrorsAndFixtures :: IO ()
testRendersErrorsAndFixtures = do
  assertEqual "asset seed label" "missing-asset-seed" (renderPayloadValidationError MissingAssetSeed)
  assertEqual "mime type label" "invalid-mime-type" (renderPayloadValidationError InvalidMimeType)
  assertEqual "dimensions label" "invalid-dimensions" (renderPayloadValidationError InvalidDimensions)
  assertEqual "sense label" "missing-sense-alignment" (renderPayloadValidationError MissingSenseAlignment)
  assertEqual "retryable fixture status" GenerationRetryableFailure (outcomeStatus retryableFailureOutcome)
  assertEqual "timed out fixture status" GenerationTimedOut (outcomeStatus timedOutOutcome)
  assertEqual "non retryable fixture status" GenerationNonRetryableFailure (outcomeStatus nonRetryableFailureOutcome)
  assertEqual "malformed fixture status" GenerationSucceeded (outcomeStatus malformedSuccessOutcome)

testAccessorsAndShow :: IO ()
testAccessorsAndShow = do
  assertEqual "request identifier" "image-generation-request-001" (outcomeRequestIdentifier successfulOutcome)
  assertEqual "retryable reason" (Just "transient-image-provider-failure") (outcomeFailureReason retryableFailureOutcome)
  assertEqual "timed out reason" (Just "image-provider-timeout") (outcomeFailureReason timedOutOutcome)
  assertEqual "non retryable reason" (Just "invalid-image-request") (outcomeFailureReason nonRetryableFailureOutcome)
  assertEqual "status equality" True (GenerationSucceeded == GenerationSucceeded)
  assertEqual "error equality" True (MissingAssetSeed == MissingAssetSeed)
  assertEqual "show status" "GenerationSucceeded" (show GenerationSucceeded)
  assertEqual "show error" "MissingAssetSeed" (show MissingAssetSeed)
  assertEqual "show outcome" True ("GenerationOutcome" `elem` words (show successfulOutcome))
