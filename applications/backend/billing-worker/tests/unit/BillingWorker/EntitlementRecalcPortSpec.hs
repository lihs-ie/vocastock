module BillingWorker.EntitlementRecalcPortSpec (run) where

import BillingWorker.EntitlementRecalcPort
import BillingWorker.SubscriptionAuthorityPort (SubscriptionStateName (..))
import TestSupport

run :: IO ()
run = do
  runNamed "active preserves paid bundle and paid quota" testActivePreservesPaid
  runNamed "grace preserves paid bundle and paid quota" testGracePreservesPaid
  runNamed "pending-sync falls back to free" testPendingSyncFreeFallback
  runNamed "expired falls back to free" testExpiredFreeFallback
  runNamed "revoked falls back to free" testRevokedFreeFallback
  runNamed "parses and renders bundle names" testBundleNameRoundTrip
  runNamed "parses and renders quota profile names" testQuotaProfileRoundTrip

testActivePreservesPaid :: IO ()
testActivePreservesPaid = do
  let derivation = deriveEntitlement SubscriptionActive ProMonthlyQuota
  assertEqual "state" SubscriptionActive (derivationState derivation)
  assertEqual "bundle" PremiumGenerationEntitlement (derivationBundle derivation)
  assertEqual "quota" ProMonthlyQuota (derivationQuotaProfile derivation)

testGracePreservesPaid :: IO ()
testGracePreservesPaid = do
  let derivation = deriveEntitlement SubscriptionGrace StandardMonthlyQuota
  assertEqual "bundle" PremiumGenerationEntitlement (derivationBundle derivation)
  assertEqual "quota" StandardMonthlyQuota (derivationQuotaProfile derivation)

testPendingSyncFreeFallback :: IO ()
testPendingSyncFreeFallback = do
  let derivation = deriveEntitlement SubscriptionPendingSync StandardMonthlyQuota
  assertEqual "bundle" FreeBasicEntitlement (derivationBundle derivation)
  assertEqual "quota" FreeMonthlyQuota (derivationQuotaProfile derivation)

testExpiredFreeFallback :: IO ()
testExpiredFreeFallback = do
  let derivation = deriveEntitlement SubscriptionExpired StandardMonthlyQuota
  assertEqual "bundle" FreeBasicEntitlement (derivationBundle derivation)
  assertEqual "quota" FreeMonthlyQuota (derivationQuotaProfile derivation)

testRevokedFreeFallback :: IO ()
testRevokedFreeFallback = do
  let derivation = deriveEntitlement SubscriptionRevoked ProMonthlyQuota
  assertEqual "bundle" FreeBasicEntitlement (derivationBundle derivation)
  assertEqual "quota" FreeMonthlyQuota (derivationQuotaProfile derivation)

testBundleNameRoundTrip :: IO ()
testBundleNameRoundTrip = do
  assertEqual "free-basic parse" (Just FreeBasicEntitlement) (parseEntitlementBundleName "free-basic")
  assertEqual "premium parse" (Just PremiumGenerationEntitlement) (parseEntitlementBundleName "premium-generation")
  assertEqual "unknown parse" Nothing (parseEntitlementBundleName "platinum")
  assertEqual "free-basic render" "free-basic" (renderEntitlementBundleName FreeBasicEntitlement)
  assertEqual "premium render" "premium-generation" (renderEntitlementBundleName PremiumGenerationEntitlement)

testQuotaProfileRoundTrip :: IO ()
testQuotaProfileRoundTrip = do
  assertEqual "free-monthly parse" (Just FreeMonthlyQuota) (parseQuotaProfileName "free-monthly")
  assertEqual "standard-monthly parse" (Just StandardMonthlyQuota) (parseQuotaProfileName "standard-monthly")
  assertEqual "pro-monthly parse" (Just ProMonthlyQuota) (parseQuotaProfileName "pro-monthly")
  assertEqual "unknown parse" Nothing (parseQuotaProfileName "enterprise")
  assertEqual "free-monthly render" "free-monthly" (renderQuotaProfileName FreeMonthlyQuota)
  assertEqual "standard-monthly render" "standard-monthly" (renderQuotaProfileName StandardMonthlyQuota)
  assertEqual "pro-monthly render" "pro-monthly" (renderQuotaProfileName ProMonthlyQuota)
  assertTrue "show bundles" (not (null (show FreeBasicEntitlement)))
  assertTrue "show premium" (not (null (show PremiumGenerationEntitlement)))
  assertTrue "show free-monthly" (not (null (show FreeMonthlyQuota)))
  assertTrue "show standard-monthly" (not (null (show StandardMonthlyQuota)))
  assertTrue "show pro-monthly" (not (null (show ProMonthlyQuota)))
  let derivation = deriveEntitlement SubscriptionActive ProMonthlyQuota
  assertTrue "show derivation" (not (null (show derivation)))
