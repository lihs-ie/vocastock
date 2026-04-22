import 'dart:async';

import 'package:ferry/ferry.dart';

import '../../../application/command/purchase_commands.dart';
import '../../../application/envelope/command_response_envelope.dart';
import '../../../application/reader/subscription_status_reader.dart';
import '../../../domain/identifier/identifier.dart';
import '../../../domain/status/subscription_state.dart';
import '../../../domain/subscription/entitlement.dart';
import '../../../domain/subscription/plan.dart';
import '../../../domain/subscription/subscription_status_view.dart';
import '../../../domain/subscription/usage_allowance.dart';
import '../__generated__/schema.schema.gql.dart' as schema;
import '../operations/__generated__/subscription.req.gql.dart';
import 'ferry_envelope_mappers.dart';

/// Ferry-backed implementation of the subscription reader and the
/// purchase / restore commands.
///
/// The stream is backed by polling-on-demand rather than a true
/// subscription because the gateway currently exposes queries only. The
/// poll cadence can be adjusted via [pollInterval]; the default matches
/// the Flutter UI's typical "open screen and leave" usage.
class FerrySubscriptionState
    implements
        SubscriptionStatusReader,
        RequestPurchaseCommand,
        RequestRestorePurchaseCommand {
  FerrySubscriptionState({
    required Client client,
    Duration pollInterval = const Duration(seconds: 30),
  })  : _client = client,
        _pollInterval = pollInterval,
        _current = _initial;

  static const SubscriptionStatusView _initial = SubscriptionStatusView(
    state: SubscriptionState.pendingSync,
    plan: PlanCode.free,
    entitlement: EntitlementBundle.freeBasic,
    allowance: UsageAllowance(
      remainingExplanationGenerations: 0,
      remainingImageGenerations: 0,
    ),
  );

  final Client _client;
  final Duration _pollInterval;
  SubscriptionStatusView _current;

  Timer? _pollTimer;
  final StreamController<SubscriptionStatusView> _controller =
      StreamController<SubscriptionStatusView>.broadcast(
    onListen: () {},
    onCancel: () {},
  );

  @override
  SubscriptionStatusView get current => _current;

  @override
  Stream<SubscriptionStatusView> watch() {
    _startPolling();
    return _controller.stream;
  }

  void _startPolling() {
    _pollTimer?.cancel();
    unawaited(_refresh());
    _pollTimer = Timer.periodic(_pollInterval, (_) => unawaited(_refresh()));
  }

  Future<void> _refresh() async {
    final request = GSubscriptionStatusQueryReq(
      (b) => b..fetchPolicy = FetchPolicy.NetworkOnly,
    );
    final response = await _client.request(request).first;
    final data = response.data?.subscriptionStatus;
    if (data == null) return;
    _current = SubscriptionStatusView(
      state: _state(data.state),
      plan: _plan(data.plan),
      entitlement: _entitlement(data.entitlement),
      allowance: UsageAllowance(
        remainingExplanationGenerations:
            data.allowance.remainingExplanationGenerations,
        remainingImageGenerations:
            data.allowance.remainingImageGenerations,
      ),
    );
    _controller.add(_current);
  }

  @override
  Future<CommandResponseEnvelope> purchase({
    required PlanCode plan,
    required IdempotencyKey idempotencyKey,
  }) async {
    final request = GRequestPurchaseMutationReq(
      (b) => b
        ..vars.input.planCode = _planCode(plan)
        ..vars.input.idempotencyKey = idempotencyKey.value,
    );
    final response = await _client.request(request).first;
    final envelope = FerryEnvelopeMappers.fromResponse(
      response.data?.requestPurchase,
      response.linkException,
      response.graphqlErrors,
    );
    unawaited(_refresh());
    return envelope;
  }

  @override
  Future<CommandResponseEnvelope> restore({
    required IdempotencyKey idempotencyKey,
  }) async {
    final request = GRequestRestorePurchaseMutationReq(
      (b) => b..vars.input.idempotencyKey = idempotencyKey.value,
    );
    final response = await _client.request(request).first;
    final envelope = FerryEnvelopeMappers.fromResponse(
      response.data?.requestRestorePurchase,
      response.linkException,
      response.graphqlErrors,
    );
    unawaited(_refresh());
    return envelope;
  }

  Future<void> dispose() async {
    _pollTimer?.cancel();
    await _controller.close();
  }

  SubscriptionState _state(schema.GSubscriptionState value) {
    return switch (value) {
      schema.GSubscriptionState.ACTIVE => SubscriptionState.active,
      schema.GSubscriptionState.GRACE => SubscriptionState.grace,
      schema.GSubscriptionState.PENDING_SYNC => SubscriptionState.pendingSync,
      schema.GSubscriptionState.EXPIRED => SubscriptionState.expired,
      schema.GSubscriptionState.REVOKED => SubscriptionState.revoked,
      _ => SubscriptionState.pendingSync,
    };
  }

  PlanCode _plan(schema.GPlanCode value) {
    return switch (value) {
      schema.GPlanCode.FREE => PlanCode.free,
      schema.GPlanCode.STANDARD_MONTHLY => PlanCode.standardMonthly,
      schema.GPlanCode.PRO_MONTHLY => PlanCode.proMonthly,
      _ => PlanCode.free,
    };
  }

  EntitlementBundle _entitlement(schema.GEntitlementBundle value) {
    return switch (value) {
      schema.GEntitlementBundle.FREE_BASIC => EntitlementBundle.freeBasic,
      schema.GEntitlementBundle.PREMIUM_GENERATION =>
        EntitlementBundle.premiumGeneration,
      _ => EntitlementBundle.freeBasic,
    };
  }

  schema.GPlanCode _planCode(PlanCode value) {
    return switch (value) {
      PlanCode.free => schema.GPlanCode.FREE,
      PlanCode.standardMonthly => schema.GPlanCode.STANDARD_MONTHLY,
      PlanCode.proMonthly => schema.GPlanCode.PRO_MONTHLY,
    };
  }
}
