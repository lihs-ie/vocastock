/// Purchase lifecycle (spec 010 / 014 / 023).
///
/// Distinct from [SubscriptionState]; a `verifying` purchase must never be
/// displayed as a confirmed entitlement.
enum PurchaseState {
  initiated,
  submitted,
  verifying,
  verified,
  rejected,
}
