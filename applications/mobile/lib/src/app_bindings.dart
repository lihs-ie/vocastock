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
import 'infrastructure/graphql/adapters/ferry_learning_state.dart';
import 'infrastructure/graphql/adapters/ferry_subscription.dart';
import 'infrastructure/graphql/adapters/ferry_vocabulary_catalog.dart';
import 'infrastructure/graphql/graphql_client.dart';

/// Composition root for the mobile client.
///
/// Every application-layer port resolves to the Firebase + ferry live
/// adapter. Tests inject in-memory stubs via
/// `ProviderScope(overrides: [<port>.overrideWithValue(stub), ...])` —
/// the stubs live under `test/support/stubs/` and never link into the
/// release binary (spec 024 plan.md dependency rules).

final firebaseActorHandoffControllerProvider =
    Provider<FirebaseActorHandoffController>((ref) {
  final controller = FirebaseActorHandoffController();
  ref.onDispose(controller.dispose);
  return controller;
});

final actorHandoffReaderProvider = Provider<ActorHandoffReader>(
  (ref) => ref.watch(firebaseActorHandoffControllerProvider),
);

final loginCommandProvider = Provider<LoginCommand>(
  (ref) => ref.watch(firebaseActorHandoffControllerProvider),
);

final logoutCommandProvider = Provider<LogoutCommand>(
  (ref) => ref.watch(firebaseActorHandoffControllerProvider),
);

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

/// Ferry `Client` used by every GraphQL adapter.
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

/// Learning state reader backed by the `learningStates` batch query.
/// [FerryLearningStateReader.load] populates the synchronous cache on
/// first access; subsequent [proficiencyFor] calls return from cache.
final ferryLearningStateReaderProvider =
    Provider<FerryLearningStateReader>((ref) {
  return FerryLearningStateReader(
    client: ref.watch(graphqlClientProvider),
  );
});

final learningStateReaderProvider = Provider<LearningStateReader>(
  (ref) => ref.watch(ferryLearningStateReaderProvider),
);

final ferryVocabularyCatalogProvider =
    Provider<FerryVocabularyCatalog>((ref) {
  final catalog = FerryVocabularyCatalog(
    client: ref.watch(graphqlClientProvider),
  );
  ref.onDispose(() => unawaited(catalog.dispose()));
  return catalog;
});

final vocabularyCatalogReaderProvider = Provider<VocabularyCatalogReader>(
  (ref) => ref.watch(ferryVocabularyCatalogProvider),
);

final registerVocabularyExpressionCommandProvider =
    Provider<RegisterVocabularyExpressionCommand>(
  (ref) => ref.watch(ferryVocabularyCatalogProvider),
);

final vocabularyExpressionDetailReaderProvider =
    Provider<VocabularyExpressionDetailReader>(
  (ref) => ref.watch(ferryVocabularyCatalogProvider),
);

final requestExplanationGenerationCommandProvider =
    Provider<RequestExplanationGenerationCommand>(
  (ref) => ref.watch(ferryVocabularyCatalogProvider),
);

final requestImageGenerationCommandProvider =
    Provider<RequestImageGenerationCommand>(
  (ref) => ref.watch(ferryVocabularyCatalogProvider),
);

final retryGenerationCommandProvider = Provider<RetryGenerationCommand>(
  (ref) => ref.watch(ferryVocabularyCatalogProvider),
);

final ferryCompletedDetailsProvider = Provider<FerryCompletedDetails>((ref) {
  return FerryCompletedDetails(client: ref.watch(graphqlClientProvider));
});

final explanationDetailReaderProvider = Provider<ExplanationDetailReader>(
  (ref) => ref.watch(ferryCompletedDetailsProvider),
);

final visualImageDetailReaderProvider = Provider<VisualImageDetailReader>(
  (ref) => ref.watch(ferryCompletedDetailsProvider),
);

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

final ferrySubscriptionStateProvider =
    Provider<FerrySubscriptionState>((ref) {
  final state = FerrySubscriptionState(
    client: ref.watch(graphqlClientProvider),
  );
  ref.onDispose(() => unawaited(state.dispose()));
  return state;
});

final subscriptionStatusReaderProvider = Provider<SubscriptionStatusReader>(
  (ref) => ref.watch(ferrySubscriptionStateProvider),
);

final requestPurchaseCommandProvider = Provider<RequestPurchaseCommand>(
  (ref) => ref.watch(ferrySubscriptionStateProvider),
);

final requestRestorePurchaseCommandProvider =
    Provider<RequestRestorePurchaseCommand>(
  (ref) => ref.watch(ferrySubscriptionStateProvider),
);

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
