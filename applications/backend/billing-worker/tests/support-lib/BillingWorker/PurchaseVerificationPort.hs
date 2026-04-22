module BillingWorker.PurchaseVerificationPort
  ( VerificationOutcome (..),
    VerificationPayload (..),
    VerificationStatus (..),
    VerificationPayloadIssue (..),
    malformedVerifiedOutcome,
    nonRetryableVerificationOutcome,
    renderVerificationStatus,
    retryableVerificationOutcome,
    successfulVerificationOutcome,
    timedOutVerificationOutcome,
    validateVerificationPayload
  )
where

data VerificationStatus
  = VerificationVerified
  | VerificationRetryableFailure
  | VerificationNonRetryableFailure
  | VerificationTimedOut
  deriving (Eq, Show)

data VerificationPayload = VerificationPayload
  { payloadSubscriptionStateName :: String,
    payloadEntitlementBundleName :: String,
    payloadQuotaProfileName :: String,
    payloadTermStart :: String,
    payloadTermEnd :: String,
    payloadGraceWindow :: Maybe String
  }
  deriving (Eq, Show)

data VerificationOutcome = VerificationOutcome
  { outcomeStatus :: VerificationStatus,
    outcomeRequestIdentifier :: String,
    outcomePayload :: Maybe VerificationPayload,
    outcomeFailureReason :: Maybe String
  }
  deriving (Eq, Show)

data VerificationPayloadIssue
  = MissingSubscriptionState
  | MissingEntitlementBundle
  | MissingQuotaProfile
  | MissingEffectivePeriod
  | UnknownSubscriptionState
  | UnknownEntitlementBundle
  | UnknownQuotaProfile
  deriving (Eq, Show)

successfulVerificationOutcome :: String -> VerificationPayload -> VerificationOutcome
successfulVerificationOutcome requestIdentifier verifiedPayload =
  VerificationOutcome
    { outcomeStatus = VerificationVerified,
      outcomeRequestIdentifier = requestIdentifier,
      outcomePayload = Just verifiedPayload,
      outcomeFailureReason = Nothing
    }

malformedVerifiedOutcome :: String -> VerificationPayload -> VerificationOutcome
malformedVerifiedOutcome requestIdentifier malformedPayload =
  VerificationOutcome
    { outcomeStatus = VerificationVerified,
      outcomeRequestIdentifier = requestIdentifier,
      outcomePayload = Just malformedPayload,
      outcomeFailureReason = Nothing
    }

retryableVerificationOutcome :: String -> String -> VerificationOutcome
retryableVerificationOutcome requestIdentifier redactedReason =
  VerificationOutcome
    { outcomeStatus = VerificationRetryableFailure,
      outcomeRequestIdentifier = requestIdentifier,
      outcomePayload = Nothing,
      outcomeFailureReason = Just redactedReason
    }

nonRetryableVerificationOutcome :: String -> String -> VerificationOutcome
nonRetryableVerificationOutcome requestIdentifier redactedReason =
  VerificationOutcome
    { outcomeStatus = VerificationNonRetryableFailure,
      outcomeRequestIdentifier = requestIdentifier,
      outcomePayload = Nothing,
      outcomeFailureReason = Just redactedReason
    }

timedOutVerificationOutcome :: String -> VerificationOutcome
timedOutVerificationOutcome requestIdentifier =
  VerificationOutcome
    { outcomeStatus = VerificationTimedOut,
      outcomeRequestIdentifier = requestIdentifier,
      outcomePayload = Nothing,
      outcomeFailureReason = Nothing
    }

renderVerificationStatus :: VerificationStatus -> String
renderVerificationStatus verificationStatus =
  case verificationStatus of
    VerificationVerified -> "verified"
    VerificationRetryableFailure -> "retryable-failure"
    VerificationNonRetryableFailure -> "non-retryable-failure"
    VerificationTimedOut -> "timed-out"

validateVerificationPayload ::
  VerificationPayload -> Either VerificationPayloadIssue VerificationPayload
validateVerificationPayload verificationPayload
  | null (payloadSubscriptionStateName verificationPayload) = Left MissingSubscriptionState
  | null (payloadEntitlementBundleName verificationPayload) = Left MissingEntitlementBundle
  | null (payloadQuotaProfileName verificationPayload) = Left MissingQuotaProfile
  | null (payloadTermStart verificationPayload)
      || null (payloadTermEnd verificationPayload) =
      Left MissingEffectivePeriod
  | not (isKnownSubscriptionState (payloadSubscriptionStateName verificationPayload)) =
      Left UnknownSubscriptionState
  | not (isKnownEntitlementBundle (payloadEntitlementBundleName verificationPayload)) =
      Left UnknownEntitlementBundle
  | not (isKnownQuotaProfile (payloadQuotaProfileName verificationPayload)) =
      Left UnknownQuotaProfile
  | otherwise = Right verificationPayload

isKnownSubscriptionState :: String -> Bool
isKnownSubscriptionState stateName =
  stateName `elem` ["active", "grace", "expired", "pending-sync", "revoked"]

isKnownEntitlementBundle :: String -> Bool
isKnownEntitlementBundle bundleName =
  bundleName `elem` ["free-basic", "premium-generation"]

isKnownQuotaProfile :: String -> Bool
isKnownQuotaProfile profileName =
  profileName `elem` ["free-monthly", "standard-monthly", "pro-monthly"]
