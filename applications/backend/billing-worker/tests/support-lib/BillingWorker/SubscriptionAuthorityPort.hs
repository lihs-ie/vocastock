module BillingWorker.SubscriptionAuthorityPort
  ( AuthorityUpdateOutcome (..),
    AuthorityUpdateStatus (..),
    SubscriptionStateName (..),
    authorityUpdateFor,
    parseSubscriptionStateName,
    renderAuthorityUpdateStatus,
    renderSubscriptionStateName
  )
where

data SubscriptionStateName
  = SubscriptionActive
  | SubscriptionGrace
  | SubscriptionExpired
  | SubscriptionPendingSync
  | SubscriptionRevoked
  deriving (Eq, Show)

data AuthorityUpdateStatus
  = AuthorityApplied
  | AuthorityReuseCommitted
  | AuthorityRetryableFailure
  | AuthorityNonRetryableFailure
  deriving (Eq, Show)

data AuthorityUpdateOutcome = AuthorityUpdateOutcome
  { authoritySubscription :: String,
    authorityTargetState :: SubscriptionStateName,
    authorityStatus :: AuthorityUpdateStatus,
    authorityIdempotencyKey :: String
  }
  deriving (Eq, Show)

authorityUpdateFor ::
  String ->
  SubscriptionStateName ->
  AuthorityUpdateStatus ->
  String ->
  AuthorityUpdateOutcome
authorityUpdateFor subscriptionIdentifier targetState authorityStatusValue idempotencyKey =
  AuthorityUpdateOutcome
    { authoritySubscription = subscriptionIdentifier,
      authorityTargetState = targetState,
      authorityStatus = authorityStatusValue,
      authorityIdempotencyKey = idempotencyKey
    }

parseSubscriptionStateName :: String -> Maybe SubscriptionStateName
parseSubscriptionStateName stateName =
  case stateName of
    "active" -> Just SubscriptionActive
    "grace" -> Just SubscriptionGrace
    "expired" -> Just SubscriptionExpired
    "pending-sync" -> Just SubscriptionPendingSync
    "revoked" -> Just SubscriptionRevoked
    _ -> Nothing

renderSubscriptionStateName :: SubscriptionStateName -> String
renderSubscriptionStateName subscriptionStateName =
  case subscriptionStateName of
    SubscriptionActive -> "active"
    SubscriptionGrace -> "grace"
    SubscriptionExpired -> "expired"
    SubscriptionPendingSync -> "pending-sync"
    SubscriptionRevoked -> "revoked"

renderAuthorityUpdateStatus :: AuthorityUpdateStatus -> String
renderAuthorityUpdateStatus authorityUpdateStatus =
  case authorityUpdateStatus of
    AuthorityApplied -> "applied"
    AuthorityReuseCommitted -> "reuse-committed"
    AuthorityRetryableFailure -> "retryable-failure"
    AuthorityNonRetryableFailure -> "non-retryable-failure"
