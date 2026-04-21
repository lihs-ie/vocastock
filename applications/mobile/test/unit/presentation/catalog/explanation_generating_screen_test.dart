import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:vocastock_mobile/src/presentation/catalog/explanation_generating_screen.dart';
import 'package:vocastock_mobile/src/presentation/router/router.dart';

void main() {
  testWidgets('ExplanationGeneratingScreen advances through five stages',
      (WidgetTester tester) async {
    var reachedCatalog = false;
    final router = GoRouter(
      initialLocation: AppRoutes.registrationGenerating,
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.registrationGenerating,
          builder: (context, state) =>
              const ExplanationGeneratingScreen(text: 'serendipity'),
        ),
        GoRoute(
          path: AppRoutes.catalog,
          builder: (context, state) {
            reachedCatalog = true;
            return const Scaffold(body: Text('catalog landed'));
          },
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();

    expect(find.text('serendipity'), findsOneWidget);

    // Let the 5-stage timer run plus the exit delay.
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();

    expect(reachedCatalog, isTrue);
  });
}
