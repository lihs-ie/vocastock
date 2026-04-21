import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/app.dart';
import 'package:vocastock_mobile/src/app_bindings.dart';
import 'package:vocastock_mobile/src/domain/identifier/identifier.dart';
import 'package:vocastock_mobile/src/infrastructure/stub/stub_actor_handoff_controller.dart';
import 'package:vocastock_mobile/src/infrastructure/stub/stub_subscription_state.dart';
import 'package:vocastock_mobile/src/infrastructure/stub/stub_vocabulary_catalog.dart';
import 'package:vocastock_mobile/src/presentation/router/router.dart';

void main() {
  group('ProficiencyScreen', () {
    testWidgets('renders title and sections after navigating from catalog',
        (WidgetTester tester) async {
      final handoff = StubActorHandoffController();
      final catalog = StubVocabularyCatalog();
      final subscription = StubSubscriptionState();
      addTearDown(handoff.dispose);
      addTearDown(catalog.dispose);
      addTearDown(subscription.dispose);

      await catalog.register(
        text: 'serendipity',
        idempotencyKey: IdempotencyKey('idem-1'),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            stubActorHandoffControllerProvider.overrideWithValue(handoff),
            stubVocabularyCatalogProvider.overrideWithValue(catalog),
            stubSubscriptionStateProvider.overrideWithValue(subscription),
          ],
          child: const VocastockApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('login.provider.basic')));
      await tester.pumpAndSettle();

      final element = tester.element(find.byType(MaterialApp));
      ProviderScope.containerOf(element)
          .read(routerProvider)
          .go(AppRoutes.proficiency);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('proficiency.title')), findsOneWidget);
      expect(find.byKey(const Key('proficiency.list')), findsOneWidget);
      expect(find.text('serendipity'), findsOneWidget);
    });

    testWidgets('renders empty state when catalog is empty',
        (WidgetTester tester) async {
      final handoff = StubActorHandoffController();
      final catalog = StubVocabularyCatalog();
      final subscription = StubSubscriptionState();
      addTearDown(handoff.dispose);
      addTearDown(catalog.dispose);
      addTearDown(subscription.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            stubActorHandoffControllerProvider.overrideWithValue(handoff),
            stubVocabularyCatalogProvider.overrideWithValue(catalog),
            stubSubscriptionStateProvider.overrideWithValue(subscription),
          ],
          child: const VocastockApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('login.provider.basic')));
      await tester.pumpAndSettle();

      final element = tester.element(find.byType(MaterialApp));
      ProviderScope.containerOf(element)
          .read(routerProvider)
          .go(AppRoutes.proficiency);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('proficiency.empty')), findsOneWidget);
    });
  });
}
