import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/app.dart';
import 'package:vocastock_mobile/src/app_bindings.dart';
import 'package:vocastock_mobile/src/domain/identifier/identifier.dart';
import 'package:vocastock_mobile/src/domain/status/subscription_state.dart';
import 'package:vocastock_mobile/src/domain/subscription/usage_allowance.dart';
import 'package:vocastock_mobile/src/presentation/router/router.dart';
import '../support/stubs/stub_actor_handoff_controller.dart';
import '../support/stubs/stub_subscription_state.dart';
import '../support/stubs/stub_vocabulary_catalog.dart';

Future<void> _pumpSignedIn(
  WidgetTester tester, {
  required StubActorHandoffController handoff,
  required StubVocabularyCatalog catalog,
  required StubSubscriptionState subscription,
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
        subscriptionStatusReaderProvider.overrideWithValue(subscription),
        requestPurchaseCommandProvider.overrideWithValue(subscription),
        requestRestorePurchaseCommandProvider.overrideWithValue(subscription),
      ],
      child: const VocastockApp(),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('login.provider.basic')));
  await tester.pumpAndSettle();
}

void main() {
  group('edge cases', () {
    testWidgets(
      'logout from subscription screen returns to login',
      (tester) async {
        final handoff = StubActorHandoffController();
        final catalog = StubVocabularyCatalog();
        final subscription = StubSubscriptionState();
        addTearDown(handoff.dispose);
        addTearDown(catalog.dispose);
        addTearDown(subscription.dispose);

        await _pumpSignedIn(
          tester,
          handoff: handoff,
          catalog: catalog,
          subscription: subscription,
        );

        final element = tester.element(find.byType(MaterialApp));
        ProviderScope.containerOf(element)
            .read(routerProvider)
            .go(AppRoutes.subscriptionStatus);
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('subscription-status.logout')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('login.provider.basic')), findsOneWidget);
      },
    );

    testWidgets(
      'expired + depleted allowance routes requestImage tap to paywall',
      (tester) async {
        final handoff = StubActorHandoffController();
        final catalog = StubVocabularyCatalog();
        final subscription = StubSubscriptionState(
          initialState: SubscriptionState.expired,
          initialAllowance: const UsageAllowance(
            remainingExplanationGenerations: 5,
            remainingImageGenerations: 0,
          ),
        );
        addTearDown(handoff.dispose);
        addTearDown(catalog.dispose);
        addTearDown(subscription.dispose);

        await catalog.register(
          text: 'aurora',
          idempotencyKey: IdempotencyKey('idem-1'),
        );
        final id = catalog.current.entries.first.identifier;
        await catalog.requestExplanation(
          vocabularyExpression: id,
          idempotencyKey: IdempotencyKey('idem-2'),
        );

        await _pumpSignedIn(
          tester,
          handoff: handoff,
          catalog: catalog,
          subscription: subscription,
        );

        await tester.tap(find.text('aurora'));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('detail.request-image')),
          findsOneWidget,
        );

        await tester.tap(find.byKey(const Key('detail.request-image')));
        await tester.pumpAndSettle();

        // The Paywall screen should have opened because the feature gate
        // returned limited + no remaining image allowance.
        expect(find.byKey(const Key('paywall.plan.standard')), findsOneWidget);
      },
    );
  });
}
