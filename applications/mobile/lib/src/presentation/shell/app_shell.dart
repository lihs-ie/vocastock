import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/vs_tokens.dart';
import '../theme/widgets/vs_bottom_tab_bar.dart';

/// Persistent chrome that hosts the four main AppShell branches
/// (catalog / proficiency / paywall / subscription-status).
///
/// The `StatefulShellRoute.indexedStack` builder hands in a
/// [StatefulNavigationShell] whose body must be rendered above the tab
/// bar. Because the tab bar lives in the shell (not on each screen), it
/// does not participate in the route-transition animation when the user
/// switches tabs — matching the `screens.jsx` `VSTabBar` behaviour.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VsTokens.paper,
      body: navigationShell,
      bottomNavigationBar: VsBottomTabBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
