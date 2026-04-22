import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/app.dart';
import 'package:vocastock_mobile/src/app_bindings.dart';
import 'package:vocastock_mobile/src/domain/status/subscription_state.dart';
import '../../support/stubs/stub_actor_handoff_controller.dart';
import '../../support/stubs/stub_subscription_state.dart';
import '../../support/stubs/stub_vocabulary_catalog.dart';

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

      await tester.tap(find.byKey(const Key('restricted.logout')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('login.provider.basic')), findsOneWidget);
    });
  });
}
