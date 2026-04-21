module BillingWorker.EntitlementRecalcPort
  ( EntitlementBundleName (..),
    EntitlementDerivation (..),
    QuotaProfileName (..),
    deriveEntitlement,
    parseEntitlementBundleName,
    parseQuotaProfileName,
    renderEntitlementBundleName,
    renderQuotaProfileName
  )
where

import BillingWorker.SubscriptionAuthorityPort
  ( SubscriptionStateName (..)
  )

data EntitlementBundleName
  = FreeBasicEntitlement
  | PremiumGenerationEntitlement
  deriving (Eq, Show)

data QuotaProfileName
  = FreeMonthlyQuota
  | StandardMonthlyQuota
  | ProMonthlyQuota
  deriving (Eq, Show)

data EntitlementDerivation = EntitlementDerivation
  { derivationState :: SubscriptionStateName,
    derivationBundle :: EntitlementBundleName,
    derivationQuotaProfile :: QuotaProfileName
  }
  deriving (Eq, Show)

deriveEntitlement ::
  SubscriptionStateName -> QuotaProfileName -> EntitlementDerivation
deriveEntitlement subscriptionStateValue paidQuotaProfile =
  EntitlementDerivation
    { derivationState = subscriptionStateValue,
      derivationBundle = bundleFor subscriptionStateValue,
      derivationQuotaProfile = quotaFor subscriptionStateValue paidQuotaProfile
    }

bundleFor :: SubscriptionStateName -> EntitlementBundleName
bundleFor subscriptionStateValue =
  case subscriptionStateValue of
    SubscriptionActive -> PremiumGenerationEntitlement
    SubscriptionGrace -> PremiumGenerationEntitlement
    SubscriptionPendingSync -> FreeBasicEntitlement
    SubscriptionExpired -> FreeBasicEntitlement
    SubscriptionRevoked -> FreeBasicEntitlement

quotaFor :: SubscriptionStateName -> QuotaProfileName -> QuotaProfileName
quotaFor subscriptionStateValue paidQuotaProfile =
  case subscriptionStateValue of
    SubscriptionActive -> paidQuotaProfile
    SubscriptionGrace -> paidQuotaProfile
    SubscriptionPendingSync -> FreeMonthlyQuota
    SubscriptionExpired -> FreeMonthlyQuota
    SubscriptionRevoked -> FreeMonthlyQuota

parseEntitlementBundleName :: String -> Maybe EntitlementBundleName
parseEntitlementBundleName bundleName =
  case bundleName of
    "free-basic" -> Just FreeBasicEntitlement
    "premium-generation" -> Just PremiumGenerationEntitlement
    _ -> Nothing

parseQuotaProfileName :: String -> Maybe QuotaProfileName
parseQuotaProfileName profileName =
  case profileName of
    "free-monthly" -> Just FreeMonthlyQuota
    "standard-monthly" -> Just StandardMonthlyQuota
    "pro-monthly" -> Just ProMonthlyQuota
    _ -> Nothing

renderEntitlementBundleName :: EntitlementBundleName -> String
renderEntitlementBundleName bundleName =
  case bundleName of
    FreeBasicEntitlement -> "free-basic"
    PremiumGenerationEntitlement -> "premium-generation"

renderQuotaProfileName :: QuotaProfileName -> String
renderQuotaProfileName profileName =
  case profileName of
    FreeMonthlyQuota -> "free-monthly"
    StandardMonthlyQuota -> "standard-monthly"
    ProMonthlyQuota -> "pro-monthly"
