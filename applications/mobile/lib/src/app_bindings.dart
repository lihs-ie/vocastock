import 'dart:async';

import 'package:ferry/ferry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'application/auth/actor_handoff_reader.dart';
import 'application/auth/login_command.dart';
import 'application/auth/logout_command.dart';
import 'application/command/generation_commands.dart';
import 'application/command/purchase_commands.dart';
import 'application/command/register_vocabulary_expression_command.dart';
import 'application/gate/subscription_feature_gate.dart';
import 'application/reader/completed_detail_readers.dart';
import 'application/reader/learning_state_reader.dart';
import 'application/reader/subscription_status_reader.dart';
import 'application/reader/vocabulary_catalog_reader.dart';
import 'application/reader/vocabulary_expression_detail_reader.dart';
import 'domain/auth/actor_handoff_status.dart';
import 'domain/explanation/explanation_detail.dart';
import 'domain/identifier/identifier.dart';
import 'domain/subscription/subscription_status_view.dart';
import 'domain/visual/visual_image_detail.dart';
import 'domain/vocabulary/vocabulary_expression_entry.dart';
import 'infrastructure/firebase/firebase_actor_handoff_controller.dart';
import 'infrastructure/firebase/firebase_auth_token_supplier.dart';
import 'infrastructure/graphql/adapters/ferry_completed_details.dart';
import 'infrastructure/graphql/adapters/ferry_subscription.dart';
import 'infrastructure/graphql/adapters/ferry_vocabulary_catalog.dart';
import 'infrastructure/graphql/graphql_client.dart';
import 'infrastructure/stub/stub_actor_handoff_controller.dart';
import 'infrastructure/stub/stub_completed_details.dart';
import 'infrastructure/stub/stub_subscription_state.dart';
import 'infrastructure/stub/stub_vocabulary_catalog.dart';

/// Composition root for the mobile client.
///
/// The presentation layer must only `ref.watch` the `application`-layer
/// providers declared here. Infrastructure bindings can be swapped via
/// `ProviderScope(overrides: ...)` in tests without the presentation layer
/// knowing which adapter is being used (spec 024 plan.md dependency rules).

/// Build-time flag that re-points every reader / command from the
/// in-memory stubs to the ferry + Firebase adapters driven by the local
/// emulator stack. Flip on with
/// `flutter run --dart-define=USE_LIVE_BACKEND=true`.
const bool useLiveBackend =
    bool.fromEnvironment('USE_LIVE_BACKEND');

/// Stub implementation of the auth handoff controller.
///
/// Kept available for every Flutter unit / widget / feature test. Live
/// adapter (Firebase Auth) is wired via [useLiveBackend].
final stubActorHandoffControllerProvider =
    Provider<StubActorHandoffController>((ref) {
  final controller = StubActorHandoffController();
  ref.onDispose(controller.dispose);
  return controller;
});

final firebaseActorHandoffControllerProvider =
    Provider<FirebaseActorHandoffController>((ref) {
  final controller = FirebaseActorHandoffController();
  ref.onDispose(controller.dispose);
  return controller;
});

final actorHandoffReaderProvider = Provider<ActorHandoffReader>((ref) {
  if (useLiveBackend) {
    return ref.watch(firebaseActorHandoffControllerProvider);
  }
  return ref.watch(stubActorHandoffControllerProvider);
});

final loginCommandProvider = Provider<LoginCommand>((ref) {
  if (useLiveBackend) {
    return ref.watch(firebaseActorHandoffControllerProvider);
  }
  return ref.watch(stubActorHandoffControllerProvider);
});

final logoutCommandProvider = Provider<LogoutCommand>((ref) {
  if (useLiveBackend) {
    return ref.watch(firebaseActorHandoffControllerProvider);
  }
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

/// Ferry `Client` used by every GraphQL adapter in live mode.
final graphqlClientProvider = Provider<Client>((ref) {
  final client = GraphQLClientFactory.create(
    tokenSupplier: FirebaseAuthTokenSupplier(),
  );
  ref.onDispose(() => unawaited(client.dispose()));
  return client;
});

/// Pure-function feature gate; no infrastructure dependency.
final subscriptionFeatureGateProvider = Provider<SubscriptionFeatureGate>((ref) {
  return const SubscriptionFeatureGate();
});

/// Learning state reader — currently stub-only across both modes because
/// spec 005 `LearningState` aggregate is not yet exposed through the
/// GraphQL gateway.
final learningStateReaderProvider = Provider<LearningStateReader>((ref) {
  return const StubLearningStateReader();
});

/// Stub vocabulary catalog backing both the reader and registration command.
final stubVocabularyCatalogProvider = Provider<StubVocabularyCatalog>((ref) {
  final catalog = StubVocabularyCatalog();
  ref.onDispose(catalog.dispose);
  return catalog;
});

final ferryVocabularyCatalogProvider =
    Provider<FerryVocabularyCatalog>((ref) {
  final catalog = FerryVocabularyCatalog(
    client: ref.watch(graphqlClientProvider),
  );
  ref.onDispose(() => unawaited(catalog.dispose()));
  return catalog;
});

final vocabularyCatalogReaderProvider = Provider<VocabularyCatalogReader>((ref) {
  if (useLiveBackend) {
    return ref.watch(ferryVocabularyCatalogProvider);
  }
  return ref.watch(stubVocabularyCatalogProvider);
});

final registerVocabularyExpressionCommandProvider =
    Provider<RegisterVocabularyExpressionCommand>((ref) {
  if (useLiveBackend) {
    return ref.watch(ferryVocabularyCatalogProvider);
  }
  return ref.watch(stubVocabularyCatalogProvider);
});

final vocabularyExpressionDetailReaderProvider =
    Provider<VocabularyExpressionDetailReader>((ref) {
  if (useLiveBackend) {
    return ref.watch(ferryVocabularyCatalogProvider);
  }
  return ref.watch(stubVocabularyCatalogProvider);
});

final requestExplanationGenerationCommandProvider =
    Provider<RequestExplanationGenerationCommand>((ref) {
  if (useLiveBackend) {
    return ref.watch(ferryVocabularyCatalogProvider);
  }
  return ref.watch(stubVocabularyCatalogProvider);
});

final requestImageGenerationCommandProvider =
    Provider<RequestImageGenerationCommand>((ref) {
  if (useLiveBackend) {
    return ref.watch(ferryVocabularyCatalogProvider);
  }
  return ref.watch(stubVocabularyCatalogProvider);
});

final retryGenerationCommandProvider = Provider<RetryGenerationCommand>((ref) {
  if (useLiveBackend) {
    return ref.watch(ferryVocabularyCatalogProvider);
  }
  return ref.watch(stubVocabularyCatalogProvider);
});

final stubCompletedDetailsProvider = Provider<StubCompletedDetails>((ref) {
  return StubCompletedDetails(ref.watch(stubVocabularyCatalogProvider));
});

final ferryCompletedDetailsProvider = Provider<FerryCompletedDetails>((ref) {
  return FerryCompletedDetails(client: ref.watch(graphqlClientProvider));
});

final explanationDetailReaderProvider =
    Provider<ExplanationDetailReader>((ref) {
  if (useLiveBackend) {
    return ref.watch(ferryCompletedDetailsProvider);
  }
  return ref.watch(stubCompletedDetailsProvider);
});

final visualImageDetailReaderProvider =
    Provider<VisualImageDetailReader>((ref) {
  if (useLiveBackend) {
    return ref.watch(ferryCompletedDetailsProvider);
  }
  return ref.watch(stubCompletedDetailsProvider);
});

// Reason: AutoDisposeStreamProviderFamily / AutoDisposeFutureProviderFamily
// type names are not part of riverpod 3.x's stable public API surface.
// ignore: specify_nonobvious_property_types
final explanationDetailFutureProvider = FutureProvider.autoDispose
    .family<CompletedExplanationDetail?, ExplanationIdentifier>(
  (ref, identifier) =>
      ref.watch(explanationDetailReaderProvider).readExplanation(identifier),
);

// Reason: AutoDisposeStreamProviderFamily / AutoDisposeFutureProviderFamily
// type names are not part of riverpod 3.x's stable public API surface.
// ignore: specify_nonobvious_property_types
final imageDetailFutureProvider = FutureProvider.autoDispose
    .family<CompletedImageDetail?, VisualImageIdentifier>(
  (ref, identifier) =>
      ref.watch(visualImageDetailReaderProvider).readImage(identifier),
);

final stubSubscriptionStateProvider =
    Provider<StubSubscriptionState>((ref) {
  final state = StubSubscriptionState();
  ref.onDispose(state.dispose);
  return state;
});

final ferrySubscriptionStateProvider =
    Provider<FerrySubscriptionState>((ref) {
  final state = FerrySubscriptionState(
    client: ref.watch(graphqlClientProvider),
  );
  ref.onDispose(() => unawaited(state.dispose()));
  return state;
});

final subscriptionStatusReaderProvider =
    Provider<SubscriptionStatusReader>((ref) {
  if (useLiveBackend) {
    return ref.watch(ferrySubscriptionStateProvider);
  }
  return ref.watch(stubSubscriptionStateProvider);
});

final requestPurchaseCommandProvider =
    Provider<RequestPurchaseCommand>((ref) {
  if (useLiveBackend) {
    return ref.watch(ferrySubscriptionStateProvider);
  }
  return ref.watch(stubSubscriptionStateProvider);
});

final requestRestorePurchaseCommandProvider =
    Provider<RequestRestorePurchaseCommand>((ref) {
  if (useLiveBackend) {
    return ref.watch(ferrySubscriptionStateProvider);
  }
  return ref.watch(stubSubscriptionStateProvider);
});

final subscriptionStatusStreamProvider =
    StreamProvider<SubscriptionStatusView>((ref) {
  final reader = ref.watch(subscriptionStatusReaderProvider);
  final controller = StreamController<SubscriptionStatusView>()
    ..add(reader.current);
  final subscription = reader.watch().listen(controller.add);
  ref.onDispose(() {
    unawaited(subscription.cancel());
    unawaited(controller.close());
  });
  return controller.stream;
});

/// Streams a single entry for the `VocabularyExpressionDetail` screen,
/// prepended with the current value so first frame is never null.
// Reason: AutoDisposeStreamProviderFamily / AutoDisposeFutureProviderFamily
// type names are not part of riverpod 3.x's stable public API surface.
// ignore: specify_nonobvious_property_types
final vocabularyExpressionDetailStreamProvider = StreamProvider.autoDispose
    .family<VocabularyExpressionEntry?, VocabularyExpressionIdentifier>(
  (ref, identifier) {
    final reader = ref.watch(vocabularyExpressionDetailReaderProvider);
    final controller = StreamController<VocabularyExpressionEntry?>();
    unawaited(reader.readDetail(identifier).then(controller.add));
    final subscription = reader.watchDetail(identifier).listen(controller.add);
    ref.onDispose(() {
      unawaited(subscription.cancel());
      unawaited(controller.close());
    });
    return controller.stream;
  },
);

/// Streams the current catalog snapshot, prepending the reader's initial
/// value so subscribers never render on a null first frame.
final vocabularyCatalogStreamProvider =
    StreamProvider<VocabularyCatalog>((ref) {
  final reader = ref.watch(vocabularyCatalogReaderProvider);
  final controller = StreamController<VocabularyCatalog>()
    ..add(reader.current);
  final subscription = reader.watch().listen(controller.add);
  ref.onDispose(() {
    unawaited(subscription.cancel());
    unawaited(controller.close());
  });
  return controller.stream;
});
