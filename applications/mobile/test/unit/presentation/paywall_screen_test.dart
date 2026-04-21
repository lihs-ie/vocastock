import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/app.dart';
import 'package:vocastock_mobile/src/app_bindings.dart';
import 'package:vocastock_mobile/src/domain/status/subscription_state.dart';
import 'package:vocastock_mobile/src/infrastructure/stub/stub_actor_handoff_controller.dart';
import 'package:vocastock_mobile/src/infrastructure/stub/stub_subscription_state.dart';
import 'package:vocastock_mobile/src/infrastructure/stub/stub_vocabulary_catalog.dart';
import 'package:vocastock_mobile/src/presentation/router/router.dart';

void main() {
  group('PaywallScreen', () {
    testWidgets('shows two plan cards and a status link', (tester) async {
      final handoff = StubActorHandoffController();
      final catalog = StubVocabularyCatalog();
      final subscription = StubSubscriptionState(
        initialState: SubscriptionState.expired,
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

      // Navigate to paywall programmatically via the location provider.
      final element = tester.element(find.byType(MaterialApp));
      // Use the stub subscription state setter: expired leaves the catalog
      // reachable. We push /paywall via the app_bindings router.
      ProviderScope.containerOf(element).read(routerProvider).go('/paywall');
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('paywall.plan.standard')), findsOneWidget);
      expect(find.byKey(const Key('paywall.plan.pro')), findsOneWidget);
      expect(find.byKey(const Key('paywall.status-link')), findsOneWidget);
    });

    testWidgets('tapping status link navigates to subscription status',
        (tester) async {
      final handoff = StubActorHandoffController();
      final catalog = StubVocabularyCatalog();
      final subscription = StubSubscriptionState(
        initialState: SubscriptionState.expired,
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

      final element = tester.element(find.byType(MaterialApp));
      ProviderScope.containerOf(element).read(routerProvider).go('/paywall');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('paywall.status-link')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('subscription-status.state')),
        findsOneWidget,
      );
    });
  });
}
