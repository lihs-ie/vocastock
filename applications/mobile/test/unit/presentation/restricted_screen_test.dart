import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/app.dart';
import 'package:vocastock_mobile/src/app_bindings.dart';
import 'package:vocastock_mobile/src/domain/status/subscription_state.dart';
import 'package:vocastock_mobile/src/infrastructure/stub/stub_actor_handoff_controller.dart';
import 'package:vocastock_mobile/src/infrastructure/stub/stub_subscription_state.dart';
import 'package:vocastock_mobile/src/infrastructure/stub/stub_vocabulary_catalog.dart';

void main() {
  group('RestrictedAccessScreen', () {
    testWidgets('renders icon, message, and two recovery CTAs', (tester) async {
      final handoff = StubActorHandoffController();
      final catalog = StubVocabularyCatalog();
      final subscription = StubSubscriptionState(
        initialState: SubscriptionState.revoked,
      );
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

      expect(find.byKey(const Key('restricted.icon')), findsOneWidget);
      expect(find.byKey(const Key('restricted.message')), findsOneWidget);
      expect(find.byKey(const Key('restricted.status-link')), findsOneWidget);
      expect(find.byKey(const Key('restricted.logout')), findsOneWidget);
    });

    testWidgets('logout from restricted returns to login', (WidgetTester tester) async {
      final handoff = StubActorHandoffController();
      final catalog = StubVocabularyCatalog();
      final subscription = StubSubscriptionState(
        initialState: SubscriptionState.revoked,
      );
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

      await tester.tap(find.byKey(const Key('restricted.logout')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('login.provider.basic')), findsOneWidget);
    });
  });
}
