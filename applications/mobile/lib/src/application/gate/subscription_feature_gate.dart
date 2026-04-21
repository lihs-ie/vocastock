import '../../domain/status/subscription_state.dart';
import '../../domain/subscription/entitlement.dart';
import '../../domain/subscription/plan.dart';

/// Implements spec 014 feature-gate-matrix-contract.
///
/// The matrix resolves a `[feature × subscription-state × plan-tier]` triple
/// into a [FeatureGateDecision]. Quota remainder is evaluated separately by
/// the caller using [UsageAllowance]; constitution §VI forbids mixing
/// allowance-driven allow/deny with the entitlement matrix.
class SubscriptionFeatureGate {
  const SubscriptionFeatureGate();

  FeatureGateDecision evaluate({
    required FeatureKey feature,
    required SubscriptionState state,
    required PlanTier plan,
  }) {
    // recovery-focused features remain available even under `revoked`.
    if (feature == FeatureKey.subscriptionStatusAccess ||
        feature == FeatureKey.restoreAccess) {
      return const FeatureGateAllow();
    }

    // `revoked` is the hard stop; every non-recovery feature is denied.
    if (state == SubscriptionState.revoked) {
      return const FeatureGateDeny(FeatureGateDenyReason.revokedAccess);
    }

    // generation features follow the paid-unlock / limited fallback rule.
    if (feature == FeatureKey.explanationGeneration ||
        feature == FeatureKey.imageGeneration) {
      return switch (state) {
        SubscriptionState.active =>
          plan == PlanTier.premium
              ? const FeatureGateAllow()
              : const FeatureGateLimited(),
        SubscriptionState.grace => const FeatureGateAllow(),
        SubscriptionState.pendingSync => const FeatureGateLimited(),
        SubscriptionState.expired => const FeatureGateLimited(),
        SubscriptionState.revoked =>
          const FeatureGateDeny(FeatureGateDenyReason.revokedAccess),
      };
    }

    // catalog-viewing / vocabulary-registration / completed-result-viewing are
    // always allowed except under `revoked`, which the earlier branch handled.
    return const FeatureGateAllow();
  }
}
