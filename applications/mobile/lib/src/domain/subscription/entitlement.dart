import 'package:meta/meta.dart';

/// Entitlement bundle as defined by spec 014 entitlement-policy-contract.
enum EntitlementBundle {
  freeBasic,
  premiumGeneration,
}

/// Feature keys that the feature gate evaluates (spec 014
/// feature-gate-matrix-contract).
enum FeatureKey {
  catalogViewing,
  vocabularyRegistration,
  explanationGeneration,
  imageGeneration,
  completedResultViewing,
  subscriptionStatusAccess,
  restoreAccess,
}

/// Result of evaluating a feature key against subscription state and plan.
@immutable
sealed class FeatureGateDecision {
  const FeatureGateDecision();
}

@immutable
final class FeatureGateAllow extends FeatureGateDecision {
  const FeatureGateAllow();
}

@immutable
final class FeatureGateLimited extends FeatureGateDecision {
  const FeatureGateLimited();
}

@immutable
final class FeatureGateDeny extends FeatureGateDecision {
  const FeatureGateDeny(this.reason);
  final FeatureGateDenyReason reason;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeatureGateDeny && other.reason == reason);

  @override
  int get hashCode => reason.hashCode;
}

enum FeatureGateDenyReason {
  revokedAccess,
}
