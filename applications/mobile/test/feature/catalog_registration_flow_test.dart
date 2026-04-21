import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/app.dart';
import 'package:vocastock_mobile/src/app_bindings.dart';
import 'package:vocastock_mobile/src/domain/identifier/identifier.dart';
import 'package:vocastock_mobile/src/infrastructure/stub/stub_actor_handoff_controller.dart';
import 'package:vocastock_mobile/src/infrastructure/stub/stub_vocabulary_catalog.dart';

Future<void> _pumpAsSignedInUser(
  WidgetTester tester, {
  required StubActorHandoffController handoff,
  required StubVocabularyCatalog catalog,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        stubActorHandoffControllerProvider.overrideWithValue(handoff),
        stubVocabularyCatalogProvider.overrideWithValue(catalog),
      ],
      child: const VocastockApp(),
    ),
  );
  await tester.pumpAndSettle();

  // Drive the handoff through the login UI so pumpAndSettle controls all
  // async timing (pumping handoff.signIn directly races with the widget
  // tester's fake clock).
  await tester.tap(find.byKey(const Key('login.provider.basic')));
  await tester.pumpAndSettle();
}

void main() {
  group('catalog & registration flow', () {
    testWidgets(
      'empty catalog → registration submit → catalog reflects new entry',
      (tester) async {
        final handoff = StubActorHandoffController();
        final catalog = StubVocabularyCatalog();
        addTearDown(handoff.dispose);
        addTearDown(catalog.dispose);

        await _pumpAsSignedInUser(
          tester,
          handoff: handoff,
          catalog: catalog,
        );

        expect(
          find.byKey(const Key('catalog.empty-placeholder')),
          findsOneWidget,
        );

        await tester.tap(find.byKey(const Key('catalog.add')));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('registration.text-field')),
          findsOneWidget,
        );

        await tester.enterText(
          find.byKey(const Key('registration.text-field')),
          'serendipity',
        );
        await tester.tap(find.byKey(const Key('registration.submit')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('catalog.list')), findsOneWidget);
        expect(find.text('serendipity'), findsOneWidget);
        expect(catalog.current.entries.length, equals(1));
      },
    );

    testWidgets('duplicate submit reuses existing entry', (WidgetTester tester) async {
      final handoff = StubActorHandoffController();
      final catalog = StubVocabularyCatalog();
      addTearDown(handoff.dispose);
      addTearDown(catalog.dispose);

      await catalog.register(
        text: 'serendipity',
        idempotencyKey: IdempotencyKey('idem-pre'),
      );

      await _pumpAsSignedInUser(
        tester,
        handoff: handoff,
        catalog: catalog,
      );

      expect(find.byKey(const Key('catalog.list')), findsOneWidget);

      await tester.tap(find.byKey(const Key('catalog.add')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('registration.text-field')),
        'serendipity',
      );
      await tester.tap(find.byKey(const Key('registration.submit')));
      await tester.pumpAndSettle();

      expect(catalog.current.entries.length, equals(1));
    });

    testWidgets('validation failure surfaces inline error', (WidgetTester tester) async {
      final handoff = StubActorHandoffController();
      final catalog = StubVocabularyCatalog();
      addTearDown(handoff.dispose);
      addTearDown(catalog.dispose);

      await _pumpAsSignedInUser(
        tester,
        handoff: handoff,
        catalog: catalog,
      );

      await tester.tap(find.byKey(const Key('catalog.add')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('registration.submit')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('registration.error-message')),
        findsOneWidget,
      );
      expect(catalog.current.isEmpty, isTrue);
    });
  });
}
