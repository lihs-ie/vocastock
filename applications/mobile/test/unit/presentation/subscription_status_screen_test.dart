import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/app.dart';
import 'package:vocastock_mobile/src/app_bindings.dart';
import 'package:vocastock_mobile/src/domain/status/subscription_state.dart';
import 'package:vocastock_mobile/src/domain/subscription/plan.dart';
import 'package:vocastock_mobile/src/infrastructure/stub/stub_actor_handoff_controller.dart';
import 'package:vocastock_mobile/src/infrastructure/stub/stub_subscription_state.dart';
import 'package:vocastock_mobile/src/infrastructure/stub/stub_vocabulary_catalog.dart';
import 'package:vocastock_mobile/src/presentation/router/router.dart';

Future<void> _pumpSubscription(
  WidgetTester tester, {
  required StubSubscriptionState subscription,
}) async {
  final handoff = StubActorHandoffController();
  final catalog = StubVocabularyCatalog();
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
      .go('/subscription');
  await tester.pumpAndSettle();
}

void main() {
  group('SubscriptionStatusScreen', () {
    testWidgets('renders all four sections for active + free', (WidgetTester tester) async {
      await _pumpSubscription(
        tester,
        subscription: StubSubscriptionState(),
      );
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
      expect(
        find.byKey(const Key('subscription-status.restore')),
        findsOneWidget,
      );
    });

    testWidgets('restore CTA activates the last paid plan', (WidgetTester tester) async {
      final subscription = StubSubscriptionState(
        initialState: SubscriptionState.expired,
      );
      await _pumpSubscription(tester, subscription: subscription);

      await tester.tap(find.byKey(const Key('subscription-status.restore')));
      await tester.pumpAndSettle();

      expect(subscription.current.state, equals(SubscriptionState.active));
      expect(subscription.current.plan, equals(PlanCode.standardMonthly));
    });

    testWidgets('grace state label differs from active', (WidgetTester tester) async {
      final subscription = StubSubscriptionState(
        initialState: SubscriptionState.grace,
        initialPlan: PlanCode.proMonthly,
      );
      await _pumpSubscription(tester, subscription: subscription);
      expect(find.text('猶予期間'), findsOneWidget);
      expect(find.text('プロ (月額)'), findsOneWidget);
    });

    testWidgets('pending-sync state label renders as 同期中', (WidgetTester tester) async {
      final subscription = StubSubscriptionState(
        initialState: SubscriptionState.pendingSync,
      );
      await _pumpSubscription(tester, subscription: subscription);
      expect(find.text('同期中'), findsOneWidget);
    });

    testWidgets('expired state label renders', (WidgetTester tester) async {
      final subscription = StubSubscriptionState(
        initialState: SubscriptionState.expired,
      );
      await _pumpSubscription(tester, subscription: subscription);
      expect(find.text('期限切れ'), findsOneWidget);
    });
  });
}
