import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/app.dart';
import 'package:vocastock_mobile/src/app_bindings.dart';
import 'package:vocastock_mobile/src/domain/identifier/identifier.dart';
import 'package:vocastock_mobile/src/domain/status/subscription_state.dart';
import 'package:vocastock_mobile/src/domain/subscription/plan.dart';
import 'package:vocastock_mobile/src/infrastructure/stub/stub_actor_handoff_controller.dart';
import 'package:vocastock_mobile/src/infrastructure/stub/stub_subscription_state.dart';
import 'package:vocastock_mobile/src/infrastructure/stub/stub_vocabulary_catalog.dart';

Future<void> _pumpSignedIn(
  WidgetTester tester, {
  required StubActorHandoffController handoff,
  required StubVocabularyCatalog catalog,
  required StubSubscriptionState subscription,
}) async {
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
}

void main() {
  group('subscription flow', () {
    testWidgets('revoked state redirects from catalog to restricted screen',
        (tester) async {
      final handoff = StubActorHandoffController();
      final catalog = StubVocabularyCatalog();
      final subscription = StubSubscriptionState(
        initialState: SubscriptionState.revoked,
      );
      addTearDown(handoff.dispose);
      addTearDown(catalog.dispose);
      addTearDown(subscription.dispose);

      await _pumpSignedIn(
        tester,
        handoff: handoff,
        catalog: catalog,
        subscription: subscription,
      );

      expect(find.byKey(const Key('restricted.message')), findsOneWidget);
    });

    testWidgets('recovering from revoked lands on subscription status',
        (tester) async {
      final handoff = StubActorHandoffController();
      final catalog = StubVocabularyCatalog();
      final subscription = StubSubscriptionState(
        initialState: SubscriptionState.revoked,
      );
      addTearDown(handoff.dispose);
      addTearDown(catalog.dispose);
      addTearDown(subscription.dispose);

      await _pumpSignedIn(
        tester,
        handoff: handoff,
        catalog: catalog,
        subscription: subscription,
      );

      expect(find.byKey(const Key('restricted.message')), findsOneWidget);

      subscription.setState(SubscriptionState.active);
      await tester.pumpAndSettle();

      // Router redirects /restricted → /subscription when state is no longer
      // revoked; all four subscription sections should be visible.
      expect(
        find.byKey(const Key('subscription-status.state')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('subscription-status.plan')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('subscription-status.entitlement')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('subscription-status.allowance')),
        findsOneWidget,
      );
    });

    testWidgets('restore command recovers the last paid plan', (tester) async {
      final handoff = StubActorHandoffController();
      final catalog = StubVocabularyCatalog();
      final subscription = StubSubscriptionState(
        initialState: SubscriptionState.expired,
      );
      addTearDown(handoff.dispose);
      addTearDown(catalog.dispose);
      addTearDown(subscription.dispose);

      await _pumpSignedIn(
        tester,
        handoff: handoff,
        catalog: catalog,
        subscription: subscription,
      );

      await subscription.restore(
        idempotencyKey: IdempotencyKey('idem-restore-1'),
      );
      expect(subscription.current.state, equals(SubscriptionState.active));
    });

    testWidgets('paywall purchase activates the plan', (tester) async {
      final handoff = StubActorHandoffController();
      final catalog = StubVocabularyCatalog();
      final subscription = StubSubscriptionState(
        initialState: SubscriptionState.expired,
      );
      addTearDown(handoff.dispose);
      addTearDown(catalog.dispose);
      addTearDown(subscription.dispose);

      await _pumpSignedIn(
        tester,
        handoff: handoff,
        catalog: catalog,
        subscription: subscription,
      );

      // We verify the adapter-level effect; UI navigation from catalog to
      // paywall on expired+premium attempt is covered in Phase 7.
      await subscription.purchase(
        plan: PlanCode.standardMonthly,
        idempotencyKey: IdempotencyKey('idem-purchase-1'),
      );
      expect(subscription.current.state, equals(SubscriptionState.active));
      expect(subscription.current.plan, equals(PlanCode.standardMonthly));
    });
  });
}
