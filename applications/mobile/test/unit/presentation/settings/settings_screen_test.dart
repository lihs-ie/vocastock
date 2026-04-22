import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/app.dart';
import 'package:vocastock_mobile/src/app_bindings.dart';
import 'package:vocastock_mobile/src/presentation/router/router.dart';
import '../../../support/stubs/stub_actor_handoff_controller.dart';
import '../../../support/stubs/stub_subscription_state.dart';
import '../../../support/stubs/stub_vocabulary_catalog.dart';

Future<void> _pumpSettings(WidgetTester tester) async {
  final handoff = StubActorHandoffController();
  final catalog = StubVocabularyCatalog();
  final subscription = StubSubscriptionState();
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

  final element = tester.element(find.byType(MaterialApp));
  ProviderScope.containerOf(element)
      .read(routerProvider)
      .go(AppRoutes.settings);
  await tester.pumpAndSettle();
}

void main() {
  group('SettingsScreen', () {
    testWidgets('renders three section groups with labelled rows',
        (WidgetTester tester) async {
      await _pumpSettings(tester);
      expect(find.text('アカウント'), findsOneWidget);
      expect(find.text('生成設定'), findsOneWidget);
      expect(find.text('アプリ'), findsOneWidget);
      expect(find.byKey(const Key('settings.row.profile')), findsOneWidget);
      expect(
        find.byKey(const Key('settings.row.subscription')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('settings.row.detail-layout')),
        findsOneWidget,
      );
    });

    testWidgets(
        'tapping the subscription row navigates to /subscription',
        (WidgetTester tester) async {
      await _pumpSettings(tester);
      await tester.ensureVisible(
        find.byKey(const Key('settings.row.subscription')),
      );
      await tester.tap(find.byKey(const Key('settings.row.subscription')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('subscription-status.state')),
        findsOneWidget,
      );
    });
  });
}
