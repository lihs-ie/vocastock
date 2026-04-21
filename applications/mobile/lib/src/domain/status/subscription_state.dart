/// Backend-authoritative subscription state (spec 010 / 013).
///
/// Distinct from [PurchaseState]. Per constitution §VI, `pending-sync` must not
/// be used as a premium unlock reason.
enum SubscriptionState {
  active,
  grace,
  pendingSync,
  expired,
  revoked,
}
