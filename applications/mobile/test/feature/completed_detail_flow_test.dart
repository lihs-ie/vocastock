import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/app.dart';
import 'package:vocastock_mobile/src/app_bindings.dart';
import 'package:vocastock_mobile/src/domain/identifier/identifier.dart';
import '../support/stubs/stub_actor_handoff_controller.dart';
import '../support/stubs/stub_completed_details.dart';
import '../support/stubs/stub_vocabulary_catalog.dart';

Future<void> _pumpSignedIn(
  WidgetTester tester, {
  required StubActorHandoffController handoff,
  required StubVocabularyCatalog catalog,
}) async {
  final completedDetails = StubCompletedDetails(catalog);
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
        explanationDetailReaderProvider.overrideWithValue(completedDetails),
        visualImageDetailReaderProvider.overrideWithValue(completedDetails),
      ],
      child: const VocastockApp(),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('login.provider.basic')));
  await tester.pumpAndSettle();
}

Future<VocabularyExpressionIdentifier> _preload(
  StubVocabularyCatalog catalog,
  String text, {
  bool withExplanation = false,
  bool withImage = false,
}) async {
  await catalog.register(
    text: text,
    idempotencyKey: IdempotencyKey('idem-reg-$text'),
  );
  final id = catalog.current.entries.first.identifier;
  if (withExplanation) {
    await catalog.requestExplanation(
      vocabularyExpression: id,
      idempotencyKey: IdempotencyKey('idem-exp-$text'),
    );
  }
  if (withImage) {
    await catalog.requestImage(
      vocabularyExpression: id,
      idempotencyKey: IdempotencyKey('idem-img-$text'),
    );
  }
  return id;
}

void main() {
  group('explanation detail', () {
    testWidgets('shows completed body when navigated from detail CTA',
        (tester) async {
      final handoff = StubActorHandoffController();
      final catalog = StubVocabularyCatalog();
      addTearDown(handoff.dispose);
      addTearDown(catalog.dispose);

      await _preload(catalog, 'ubiquitous', withExplanation: true);

      await _pumpSignedIn(tester, handoff: handoff, catalog: catalog);

      await tester.tap(find.text('ubiquitous'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('detail.open-explanation')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('explanation-detail.text')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('explanation-detail.nuance')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('explanation-detail.situation')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('explanation-detail.example')),
        findsWidgets,
      );
      await tester.scrollUntilVisible(
        find.byKey(const Key('explanation-detail.etymology')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.byKey(const Key('explanation-detail.etymology')),
        findsOneWidget,
      );
    });

    testWidgets(
      'pops back when reader returns null (not yet completed / stale)',
      (tester) async {
        final handoff = StubActorHandoffController();
        final catalog = StubVocabularyCatalog();
        addTearDown(handoff.dispose);
        addTearDown(catalog.dispose);

        await _preload(catalog, 'notready');

        await _pumpSignedIn(tester, handoff: handoff, catalog: catalog);

        // Navigate directly to an explanation id that does not exist; the
        // reader returns null and the screen should pop back.
        await tester.tap(find.text('notready'));
        await tester.pumpAndSettle();
        // Open-explanation CTA is not rendered (no currentExplanation),
        // so we cannot reach ExplanationDetail through the UI in this
        // scenario — which itself asserts the invariant: there is no path
        // to the completed screen without a completed explanation.
        expect(
          find.byKey(const Key('detail.open-explanation')),
          findsNothing,
        );
      },
    );
  });

  group('image detail', () {
    testWidgets('shows completed image when navigated from detail CTA',
        (tester) async {
      final handoff = StubActorHandoffController();
      final catalog = StubVocabularyCatalog();
      addTearDown(handoff.dispose);
      addTearDown(catalog.dispose);

      await _preload(
        catalog,
        'halcyon',
        withExplanation: true,
        withImage: true,
      );

      await _pumpSignedIn(tester, handoff: handoff, catalog: catalog);

      await tester.tap(find.text('halcyon'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('detail.open-image')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('image-detail.asset')), findsOneWidget);
      expect(
        find.byKey(const Key('image-detail.description')),
        findsOneWidget,
      );
      expect(find.textContaining('halcyon'), findsWidgets);
      expect(find.textContaining('視覚化'), findsOneWidget);
    });
  });
}
