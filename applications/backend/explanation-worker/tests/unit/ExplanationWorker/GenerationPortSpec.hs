module ExplanationWorker.GenerationPortSpec (run) where

import ExplanationWorker.GenerationPort
import TestSupport

run :: IO ()
run = do
  runNamed "accepts a completed payload" testAcceptsCompletedPayload
  runNamed "rejects missing summary and sense data" testRejectsMissingSummaryAndSense
  runNamed "rejects missing frequency data" testRejectsMissingFrequency
  runNamed "rejects missing sophistication data" testRejectsMissingSophistication
  runNamed "renders payload validation errors and fixtures" testRendersErrorsAndFixtures
  runNamed "covers payload accessors and show instances" testAccessorsAndShow

testAcceptsCompletedPayload :: IO ()
testAcceptsCompletedPayload =
  case outcomePayload successfulOutcome of
    Nothing -> error "expected successful outcome payload"
    Just payload ->
      assertEqual "payload validation" (Right payload) (validateCompletedPayload payload)

testRejectsMissingSummaryAndSense :: IO ()
testRejectsMissingSummaryAndSense = do
  case outcomePayload malformedSuccessOutcome of
    Nothing -> error "expected malformed payload"
    Just payload -> do
      assertEqual
        "missing summary"
        (Left MissingSummary)
        (validateCompletedPayload payload)
      assertEqual
        "missing sense"
        (Left MissingSense)
        ( validateCompletedPayload
            payload
              { payloadSummary = "summary",
                payloadSenseCount = 0
              }
        )

testRejectsMissingFrequency :: IO ()
testRejectsMissingFrequency =
  let payload =
        CompletedExplanationPayload
          { payloadSummary = "summary",
            payloadSenseCount = 1,
            payloadHasFrequency = False,
            payloadHasSophistication = True,
            payloadHasPronunciation = True,
            payloadHasEtymology = True,
            payloadHasSimilarExpression = True
          }
   in assertEqual
        "missing frequency"
        (Left MissingFrequency)
        (validateCompletedPayload payload)

testRejectsMissingSophistication :: IO ()
testRejectsMissingSophistication =
  let payload =
        CompletedExplanationPayload
          { payloadSummary = "summary",
            payloadSenseCount = 1,
            payloadHasFrequency = True,
            payloadHasSophistication = False,
            payloadHasPronunciation = True,
            payloadHasEtymology = True,
            payloadHasSimilarExpression = True
          }
   in assertEqual
        "missing sophistication"
        (Left MissingSophistication)
        (validateCompletedPayload payload)

testRendersErrorsAndFixtures :: IO ()
testRendersErrorsAndFixtures = do
  assertEqual "render missing summary" "missing-summary" (renderPayloadValidationError MissingSummary)
  assertEqual "render missing sense" "missing-sense" (renderPayloadValidationError MissingSense)
  assertEqual "render missing frequency" "missing-frequency" (renderPayloadValidationError MissingFrequency)
  assertEqual "render missing sophistication" "missing-sophistication" (renderPayloadValidationError MissingSophistication)
  assertEqual "retryable fixture status" GenerationRetryableFailure (outcomeStatus retryableFailureOutcome)
  assertEqual "timed out fixture status" GenerationTimedOut (outcomeStatus timedOutOutcome)
  assertEqual "non retryable fixture status" GenerationNonRetryableFailure (outcomeStatus nonRetryableFailureOutcome)
  assertEqual "retryable reason" (Just "transient-provider-failure") (outcomeFailureReason retryableFailureOutcome)

testAccessorsAndShow :: IO ()
testAccessorsAndShow =
  case outcomePayload successfulOutcome of
    Nothing -> error "expected successful payload"
    Just payload -> do
      assertEqual "request identifier" "generation-request-001" (outcomeRequestIdentifier successfulOutcome)
      assertEqual "successful payload accessor" (Just payload) (outcomePayload successfulOutcome)
      assertEqual "successful reason accessor" Nothing (outcomeFailureReason successfulOutcome)
      assertEqual "timeout reason accessor" (Just "provider-timeout") (outcomeFailureReason timedOutOutcome)
      assertEqual "non retryable reason accessor" (Just "invalid-request") (outcomeFailureReason nonRetryableFailureOutcome)
      assertEqual "pronunciation accessor" True (payloadHasPronunciation payload)
      assertEqual "etymology accessor" True (payloadHasEtymology payload)
      assertEqual "similar expression accessor" True (payloadHasSimilarExpression payload)
      assertEqual "payload equality" True (payload == payload)
      assertEqual "outcome equality" True (timedOutOutcome == timedOutOutcome)
      assertEqual "status equality" True (GenerationTimedOut == GenerationTimedOut)
      assertEqual "error equality" True (MissingSummary == MissingSummary)
      assertEqual "show payload validation error" "MissingFrequency" (show MissingFrequency)
      assertTrue "show payload" ("CompletedExplanationPayload" `elem` words (show payload))
      assertEqual "show status" "GenerationSucceeded" (show GenerationSucceeded)
      assertTrue "show outcome" ("GenerationOutcome" `elem` words (show successfulOutcome))
