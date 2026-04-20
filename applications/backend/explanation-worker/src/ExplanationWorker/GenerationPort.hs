module ExplanationWorker.GenerationPort
  ( CompletedExplanationPayload (..),
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

data CompletedExplanationPayload = CompletedExplanationPayload
  { payloadSummary :: String,
    payloadSenseCount :: Int,
    payloadHasFrequency :: Bool,
    payloadHasSophistication :: Bool,
    payloadHasPronunciation :: Bool,
    payloadHasEtymology :: Bool,
    payloadHasSimilarExpression :: Bool
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
    outcomePayload :: Maybe CompletedExplanationPayload,
    outcomeFailureReason :: Maybe String
  }
  deriving (Eq, Show)

data PayloadValidationError
  = MissingSummary
  | MissingSense
  | MissingFrequency
  | MissingSophistication
  deriving (Eq, Show)

successfulOutcome :: GenerationOutcome
successfulOutcome =
  GenerationOutcome
    { outcomeRequestIdentifier = "generation-request-001",
      outcomeStatus = GenerationSucceeded,
      outcomePayload =
        Just
          CompletedExplanationPayload
            { payloadSummary = "completed-explanation",
              payloadSenseCount = 1,
              payloadHasFrequency = True,
              payloadHasSophistication = True,
              payloadHasPronunciation = True,
              payloadHasEtymology = True,
              payloadHasSimilarExpression = True
            },
      outcomeFailureReason = Nothing
    }

retryableFailureOutcome :: GenerationOutcome
retryableFailureOutcome =
  GenerationOutcome
    { outcomeRequestIdentifier = "generation-request-001",
      outcomeStatus = GenerationRetryableFailure,
      outcomePayload = Nothing,
      outcomeFailureReason = Just "transient-provider-failure"
    }

timedOutOutcome :: GenerationOutcome
timedOutOutcome =
  GenerationOutcome
    { outcomeRequestIdentifier = "generation-request-001",
      outcomeStatus = GenerationTimedOut,
      outcomePayload = Nothing,
      outcomeFailureReason = Just "provider-timeout"
    }

nonRetryableFailureOutcome :: GenerationOutcome
nonRetryableFailureOutcome =
  GenerationOutcome
    { outcomeRequestIdentifier = "generation-request-001",
      outcomeStatus = GenerationNonRetryableFailure,
      outcomePayload = Nothing,
      outcomeFailureReason = Just "invalid-request"
    }

malformedSuccessOutcome :: GenerationOutcome
malformedSuccessOutcome =
  GenerationOutcome
    { outcomeRequestIdentifier = "generation-request-001",
      outcomeStatus = GenerationSucceeded,
      outcomePayload =
        Just
          CompletedExplanationPayload
            { payloadSummary = "",
              payloadSenseCount = 0,
              payloadHasFrequency = False,
              payloadHasSophistication = False,
              payloadHasPronunciation = False,
              payloadHasEtymology = False,
              payloadHasSimilarExpression = False
            },
      outcomeFailureReason = Nothing
    }

renderPayloadValidationError :: PayloadValidationError -> String
renderPayloadValidationError validationError =
  case validationError of
    MissingSummary -> "missing-summary"
    MissingSense -> "missing-sense"
    MissingFrequency -> "missing-frequency"
    MissingSophistication -> "missing-sophistication"

validateCompletedPayload ::
  CompletedExplanationPayload -> Either PayloadValidationError CompletedExplanationPayload
validateCompletedPayload payload
  | null (payloadSummary payload) = Left MissingSummary
  | payloadSenseCount payload < 1 = Left MissingSense
  | not (payloadHasFrequency payload) = Left MissingFrequency
  | not (payloadHasSophistication payload) = Left MissingSophistication
  | otherwise = Right payload
