import 'dart:async';

import 'package:vocastock_mobile/src/application/command/purchase_commands.dart';
import 'package:vocastock_mobile/src/application/envelope/command_error.dart';
import 'package:vocastock_mobile/src/application/envelope/command_response_envelope.dart';
import 'package:vocastock_mobile/src/application/reader/subscription_status_reader.dart';
import 'package:vocastock_mobile/src/domain/common/user_facing_message.dart';
import 'package:vocastock_mobile/src/domain/identifier/identifier.dart';
import 'package:vocastock_mobile/src/domain/status/subscription_state.dart';
import 'package:vocastock_mobile/src/domain/subscription/entitlement.dart';
import 'package:vocastock_mobile/src/domain/subscription/plan.dart';
import 'package:vocastock_mobile/src/domain/subscription/subscription_status_view.dart';
import 'package:vocastock_mobile/src/domain/subscription/usage_allowance.dart';

/// In-memory adapter for subscription reads and purchase commands.
///
/// Feature tests drive the state with [setState] and [setPlan]; real backend
/// adapters will replace this while the interfaces stay identical.
class StubSubscriptionState
    implements
        SubscriptionStatusReader,
        RequestPurchaseCommand,
        RequestRestorePurchaseCommand {
  StubSubscriptionState({
    SubscriptionState initialState = SubscriptionState.active,
    PlanCode initialPlan = PlanCode.free,
    UsageAllowance initialAllowance = const UsageAllowance(
      remainingExplanationGenerations: 10,
      remainingImageGenerations: 3,
    ),
  }) : _state = initialState,
       _plan = initialPlan,
       _allowance = initialAllowance;

  SubscriptionState _state;
  PlanCode _plan;
  UsageAllowance _allowance;
  final StreamController<SubscriptionStatusView> _controller =
      StreamController<SubscriptionStatusView>.broadcast();

  @override
  SubscriptionStatusView get current => _view();

  @override
  Stream<SubscriptionStatusView> watch() => _controller.stream;

  void setState(SubscriptionState state) {
    _state = state;
    _emit();
  }

  void setPlan(PlanCode plan) {
    _plan = plan;
    _emit();
  }

  void setAllowance(UsageAllowance allowance) {
    _allowance = allowance;
    _emit();
  }

  @override
  Future<CommandResponseEnvelope> purchase({
    required PlanCode plan,
    required IdempotencyKey idempotencyKey,
  }) async {
    if (plan == PlanCode.free) {
      return const CommandResponseRejected(
        message: UserFacingMessage(
          key: 'purchase.invalid-plan',
          text: '選択できないプランです',
        ),
        category: CommandErrorCategory.validationFailed,
      );
    }
    _plan = plan;
    _state = SubscriptionState.active;
    _allowance = _allowanceFor(plan);
    _emit();
    return const CommandResponseAccepted(
      message: UserFacingMessage(
        key: 'purchase.accepted',
        text: '購入が完了しました',
      ),
      outcome: AcceptanceOutcome.accepted,
    );
  }

  @override
  Future<CommandResponseEnvelope> restore({
    required IdempotencyKey idempotencyKey,
  }) async {
    // Restore restores the last paid plan; the stub assumes standard.
    _plan = PlanCode.standardMonthly;
    _state = SubscriptionState.active;
    _allowance = _allowanceFor(_plan);
    _emit();
    return const CommandResponseAccepted(
      message: UserFacingMessage(
        key: 'restore.accepted',
        text: '購入履歴を復元しました',
      ),
      outcome: AcceptanceOutcome.accepted,
    );
  }

  Future<void> dispose() async {
    await _controller.close();
  }

  void _emit() {
    _controller.add(_view());
  }

  SubscriptionStatusView _view() {
    return SubscriptionStatusView(
      state: _state,
      plan: _plan,
      entitlement: _entitlementFor(_plan),
      allowance: _allowance,
    );
  }

  EntitlementBundle _entitlementFor(PlanCode plan) {
    return switch (plan.tier) {
      PlanTier.free => EntitlementBundle.freeBasic,
      PlanTier.premium => EntitlementBundle.premiumGeneration,
    };
  }

  UsageAllowance _allowanceFor(PlanCode plan) {
    return switch (plan) {
      PlanCode.free => const UsageAllowance(
        remainingExplanationGenerations: 10,
        remainingImageGenerations: 3,
      ),
      PlanCode.standardMonthly => const UsageAllowance(
        remainingExplanationGenerations: 100,
        remainingImageGenerations: 30,
      ),
      PlanCode.proMonthly => const UsageAllowance(
        remainingExplanationGenerations: 300,
        remainingImageGenerations: 100,
      ),
    };
  }
}
