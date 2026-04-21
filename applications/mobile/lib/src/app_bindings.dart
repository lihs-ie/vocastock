import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'application/auth/actor_handoff_reader.dart';
import 'application/auth/login_command.dart';
import 'application/auth/logout_command.dart';
import 'application/gate/subscription_feature_gate.dart';
import 'domain/auth/actor_handoff_status.dart';
import 'infrastructure/stub/stub_actor_handoff_controller.dart';

/// Composition root for the mobile client.
///
/// The presentation layer must only `ref.watch` the `application`-layer
/// providers declared here. Infrastructure bindings can be swapped via
/// `ProviderScope(overrides: ...)` in tests without the presentation layer
/// knowing which adapter is being used (spec 024 plan.md dependency rules).

/// Stub implementation of the auth handoff controller.
///
/// Real Firebase / backend adapters will replace this provider later; the
/// `ActorHandoffReader` / `LoginCommand` / `LogoutCommand` interfaces remain
/// stable so the presentation layer does not change.
final stubActorHandoffControllerProvider =
    Provider<StubActorHandoffController>((ref) {
  final controller = StubActorHandoffController();
  ref.onDispose(controller.dispose);
  return controller;
});

final actorHandoffReaderProvider = Provider<ActorHandoffReader>((ref) {
  return ref.watch(stubActorHandoffControllerProvider);
});

final loginCommandProvider = Provider<LoginCommand>((ref) {
  return ref.watch(stubActorHandoffControllerProvider);
});

final logoutCommandProvider = Provider<LogoutCommand>((ref) {
  return ref.watch(stubActorHandoffControllerProvider);
});

/// Streams the current handoff status, starting with the controller's current
/// value so subscribers do not miss the initial state.
final actorHandoffStatusProvider = StreamProvider<ActorHandoffStatus>((ref) {
  final reader = ref.watch(actorHandoffReaderProvider);
  final controller = StreamController<ActorHandoffStatus>()
    ..add(reader.current);
  final subscription = reader.watch().listen(controller.add);
  ref.onDispose(() {
    unawaited(subscription.cancel());
    unawaited(controller.close());
  });
  return controller.stream;
});

/// Pure-function feature gate; no infrastructure dependency.
final subscriptionFeatureGateProvider = Provider<SubscriptionFeatureGate>((ref) {
  return const SubscriptionFeatureGate();
});
