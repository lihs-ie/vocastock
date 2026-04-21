import 'package:meta/meta.dart';

import '../status/subscription_state.dart';
import 'entitlement.dart';
import 'plan.dart';
import 'usage_allowance.dart';

/// Aggregate projection rendered by the `SubscriptionStatus` screen
/// (spec 013 subscription-access-recovery-contract).
///
/// The four concepts — subscription state, entitlement bundle, usage
/// allowance, and gate result — MUST be rendered in separate sections per
/// constitution §VI; this type carries them together but does not collapse
/// them into a single status.
@immutable
class SubscriptionStatusView {
  const SubscriptionStatusView({
    required this.state,
    required this.plan,
    required this.entitlement,
    required this.allowance,
  });

  final SubscriptionState state;
  final PlanCode plan;
  final EntitlementBundle entitlement;
  final UsageAllowance allowance;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubscriptionStatusView &&
          other.state == state &&
          other.plan == plan &&
          other.entitlement == entitlement &&
          other.allowance == allowance);

  @override
  int get hashCode => Object.hash(state, plan, entitlement, allowance);
}
