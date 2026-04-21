import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:vocastock_mobile/src/presentation/router/router.dart';
import 'package:vocastock_mobile/src/presentation/theme/widgets/vs_bottom_tab_bar.dart';

void main() {
  testWidgets('VsBottomTabBar renders the four main tabs',
      (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: AppRoutes.catalog,
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.catalog,
          builder: (context, state) => const Scaffold(
            bottomNavigationBar: VsBottomTabBar(),
            body: SizedBox.shrink(),
          ),
        ),
        GoRoute(
          path: AppRoutes.proficiency,
          builder: (context, state) => const Scaffold(
            bottomNavigationBar: VsBottomTabBar(),
            body: SizedBox.shrink(),
          ),
        ),
        GoRoute(
          path: AppRoutes.paywall,
          builder: (context, state) => const Scaffold(
            bottomNavigationBar: VsBottomTabBar(),
            body: SizedBox.shrink(),
          ),
        ),
        GoRoute(
          path: AppRoutes.subscriptionStatus,
          builder: (context, state) => const Scaffold(
            bottomNavigationBar: VsBottomTabBar(),
            body: SizedBox.shrink(),
          ),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('単語帳'), findsOneWidget);
    expect(find.text('習熟'), findsOneWidget);
    expect(find.text('プラン'), findsOneWidget);
    expect(find.text('設定'), findsOneWidget);
  });

  testWidgets('tapping a tab navigates to the target route',
      (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: AppRoutes.catalog,
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.catalog,
          builder: (context, state) => const Scaffold(
            bottomNavigationBar: VsBottomTabBar(),
            body: SizedBox.shrink(),
          ),
        ),
        GoRoute(
          path: AppRoutes.proficiency,
          builder: (context, state) => const Scaffold(
            key: Key('proficiency-target'),
            bottomNavigationBar: VsBottomTabBar(),
            body: SizedBox.shrink(),
          ),
        ),
        GoRoute(
          path: AppRoutes.paywall,
          builder: (context, state) => const Scaffold(
            bottomNavigationBar: VsBottomTabBar(),
            body: SizedBox.shrink(),
          ),
        ),
        GoRoute(
          path: AppRoutes.subscriptionStatus,
          builder: (context, state) => const Scaffold(
            bottomNavigationBar: VsBottomTabBar(),
            body: SizedBox.shrink(),
          ),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('習熟'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('proficiency-target')), findsOneWidget);
  });
}
