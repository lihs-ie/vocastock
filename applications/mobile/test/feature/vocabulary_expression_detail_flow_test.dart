import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/app.dart';
import 'package:vocastock_mobile/src/app_bindings.dart';
import 'package:vocastock_mobile/src/domain/identifier/identifier.dart';
import '../support/stubs/stub_actor_handoff_controller.dart';
import '../support/stubs/stub_vocabulary_catalog.dart';

Future<void> _pumpSignedIn(
  WidgetTester tester, {
  required StubActorHandoffController handoff,
  required StubVocabularyCatalog catalog,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        actorHandoffReaderProvider.overrideWithValue(handoff),
        loginCommandProvider.overrideWithValue(handoff),
        logoutCommandProvider.overrideWithValue(handoff),
        vocabularyCatalogReaderProvider.overrideWithValue(catalog),
        registerVocabularyExpressionCommandProvider.overrideWithValue(catalog),
        vocabularyExpressionDetailReaderProvider.overrideWithValue(catalog),
        requestExplanationGenerationCommandProvider.overrideWithValue(catalog),
        requestImageGenerationCommandProvider.overrideWithValue(catalog),
        retryGenerationCommandProvider.overrideWithValue(catalog),
      ],
      child: const VocastockApp(),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('login.provider.basic')));
  await tester.pumpAndSettle();
}

Future<VocabularyExpressionIdentifier> _preloadEntry(
  StubVocabularyCatalog catalog,
  String text,
) async {
  await catalog.register(
    text: text,
    idempotencyKey: IdempotencyKey('idem-$text'),
  );
  return catalog.current.entries.first.identifier;
}

void main() {
  group('vocabulary expression detail', () {
    testWidgets('tapping a catalog entry lands on detail with status-only',
        (tester) async {
      final handoff = StubActorHandoffController();
      final catalog = StubVocabularyCatalog();
      addTearDown(handoff.dispose);
      addTearDown(catalog.dispose);

      await _preloadEntry(catalog, 'serendipity');

      await _pumpSignedIn(tester, handoff: handoff, catalog: catalog);

      // Catalog renders the preloaded entry; tap it.
      await tester.tap(find.text('serendipity'));
      await tester.pumpAndSettle();

      // Detail status aggregation is visible.
      expect(find.byKey(const Key('detail.text')), findsOneWidget);
      expect(
        find.byKey(const Key('detail.explanation-status')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('detail.image-status')), findsOneWidget);
    });

    testWidgets(
      'requestExplanation completes and the see-explanation CTA appears',
      (tester) async {
        final handoff = StubActorHandoffController();
        final catalog = StubVocabularyCatalog();
        addTearDown(handoff.dispose);
        addTearDown(catalog.dispose);

        final identifier = await _preloadEntry(catalog, 'ephemeral');
        await catalog.requestExplanation(
          vocabularyExpression: identifier,
          idempotencyKey: IdempotencyKey('idem-req-exp'),
        );

        await _pumpSignedIn(tester, handoff: handoff, catalog: catalog);

        await tester.tap(find.text('ephemeral'));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('detail.open-explanation')),
          findsOneWidget,
        );
        // Phase 4 still renders CTA enabled; completed body is gated by
        // Phase 5 detail screen.
      },
    );

    testWidgets('requestImage completes and the see-image CTA appears',
        (tester) async {
      final handoff = StubActorHandoffController();
      final catalog = StubVocabularyCatalog();
      addTearDown(handoff.dispose);
      addTearDown(catalog.dispose);

      final identifier = await _preloadEntry(catalog, 'petrichor');
      await catalog.requestExplanation(
        vocabularyExpression: identifier,
        idempotencyKey: IdempotencyKey('idem-req-exp'),
      );
      await catalog.requestImage(
        vocabularyExpression: identifier,
        idempotencyKey: IdempotencyKey('idem-req-img'),
      );

      await _pumpSignedIn(tester, handoff: handoff, catalog: catalog);

      await tester.tap(find.text('petrichor'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('detail.open-image')), findsOneWidget);
    });

    testWidgets('image failed renders retry CTA; retry produces success',
        (tester) async {
      final handoff = StubActorHandoffController();
      final catalog = StubVocabularyCatalog();
      addTearDown(handoff.dispose);
      addTearDown(catalog.dispose);

      final identifier = await _preloadEntry(catalog, 'halcyon');
      await catalog.requestExplanation(
        vocabularyExpression: identifier,
        idempotencyKey: IdempotencyKey('idem-req-exp'),
      );
      catalog.markImageFailed(identifier);

      await _pumpSignedIn(tester, handoff: handoff, catalog: catalog);

      await tester.tap(find.text('halcyon'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('detail.retry-image')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('detail.retry-image')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('detail.open-image')), findsOneWidget);
    });

    testWidgets(
      'requestImage button is visible when explanation is completed and image is pending',
      (tester) async {
        final handoff = StubActorHandoffController();
        final catalog = StubVocabularyCatalog();
        addTearDown(handoff.dispose);
        addTearDown(catalog.dispose);

        final identifier = await _preloadEntry(catalog, 'verbose');
        await catalog.requestExplanation(
          vocabularyExpression: identifier,
          idempotencyKey: IdempotencyKey('idem-req-exp'),
        );

        await _pumpSignedIn(tester, handoff: handoff, catalog: catalog);

        await tester.tap(find.text('verbose'));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('detail.request-image')),
          findsOneWidget,
        );
      },
    );

    testWidgets('explanation failed renders retry CTA and recovers',
        (tester) async {
      final handoff = StubActorHandoffController();
      final catalog = StubVocabularyCatalog();
      addTearDown(handoff.dispose);
      addTearDown(catalog.dispose);

      final identifier = await _preloadEntry(catalog, 'arcane');
      catalog.markExplanationFailed(identifier);

      await _pumpSignedIn(tester, handoff: handoff, catalog: catalog);

      await tester.tap(find.text('arcane'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('detail.retry-explanation')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('detail.retry-explanation')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('detail.open-explanation')),
        findsOneWidget,
      );
    });
  });
}
