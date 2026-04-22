module BillingWorker.SubscriptionAuthorityPortSpec (run) where

import BillingWorker.SubscriptionAuthorityPort
import TestSupport

run :: IO ()
run = do
  runNamed "builds authority update outcome" testBuildsAuthorityUpdateOutcome
  runNamed "parses subscription state names" testParsesSubscriptionStateNames
  runNamed "renders subscription state names" testRendersSubscriptionStateNames
  runNamed "renders authority update statuses" testRendersAuthorityStatuses

testBuildsAuthorityUpdateOutcome :: IO ()
testBuildsAuthorityUpdateOutcome = do
  let outcome = authorityUpdateFor "subscription-001" SubscriptionActive AuthorityApplied "idempotency-001"
  assertEqual "subscription" "subscription-001" (authoritySubscription outcome)
  assertEqual "target state" SubscriptionActive (authorityTargetState outcome)
  assertEqual "status" AuthorityApplied (authorityStatus outcome)
  assertEqual "idempotency key" "idempotency-001" (authorityIdempotencyKey outcome)

testParsesSubscriptionStateNames :: IO ()
testParsesSubscriptionStateNames = do
  assertEqual "active" (Just SubscriptionActive) (parseSubscriptionStateName "active")
  assertEqual "grace" (Just SubscriptionGrace) (parseSubscriptionStateName "grace")
  assertEqual "expired" (Just SubscriptionExpired) (parseSubscriptionStateName "expired")
  assertEqual "pending-sync" (Just SubscriptionPendingSync) (parseSubscriptionStateName "pending-sync")
  assertEqual "revoked" (Just SubscriptionRevoked) (parseSubscriptionStateName "revoked")
  assertEqual "unknown" Nothing (parseSubscriptionStateName "trialing")

testRendersSubscriptionStateNames :: IO ()
testRendersSubscriptionStateNames = do
  assertEqual "active" "active" (renderSubscriptionStateName SubscriptionActive)
  assertEqual "grace" "grace" (renderSubscriptionStateName SubscriptionGrace)
  assertEqual "expired" "expired" (renderSubscriptionStateName SubscriptionExpired)
  assertEqual "pending-sync" "pending-sync" (renderSubscriptionStateName SubscriptionPendingSync)
  assertEqual "revoked" "revoked" (renderSubscriptionStateName SubscriptionRevoked)

testRendersAuthorityStatuses :: IO ()
testRendersAuthorityStatuses = do
  assertEqual "applied" "applied" (renderAuthorityUpdateStatus AuthorityApplied)
  assertEqual "reuse" "reuse-committed" (renderAuthorityUpdateStatus AuthorityReuseCommitted)
  assertEqual "retryable" "retryable-failure" (renderAuthorityUpdateStatus AuthorityRetryableFailure)
  assertEqual "non-retryable" "non-retryable-failure" (renderAuthorityUpdateStatus AuthorityNonRetryableFailure)
  let outcome = authorityUpdateFor "s-001" SubscriptionGrace AuthorityReuseCommitted "idem-001"
  assertTrue "show outcome" (not (null (show outcome)))
  assertTrue "show active" (not (null (show SubscriptionActive)))
  assertTrue "show grace" (not (null (show SubscriptionGrace)))
  assertTrue "show expired" (not (null (show SubscriptionExpired)))
  assertTrue "show pending-sync" (not (null (show SubscriptionPendingSync)))
  assertTrue "show revoked" (not (null (show SubscriptionRevoked)))
  assertTrue "show authority status" (not (null (show AuthorityApplied)))
