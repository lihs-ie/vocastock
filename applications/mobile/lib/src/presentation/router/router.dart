import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_bindings.dart';
import '../../domain/auth/actor_handoff_status.dart';
import '../auth/login_screen.dart';
import '../auth/session_resolving_screen.dart';
import '../catalog/vocabulary_catalog_placeholder.dart';

/// Canonical route paths (spec 013 navigation-topology-contract).
class AppRoutes {
  static const login = '/login';
  static const sessionResolving = '/session-resolving';
  static const catalog = '/catalog';
}

/// Provides the app's [GoRouter]. The router is rebuilt when the handoff
/// status changes, which fires `redirect` to enforce the Auth/AppShell
/// boundary without the UI having to remember intermediate routes.
final routerProvider = Provider<GoRouter>((ref) {
  // React to handoff status updates so redirects re-evaluate on sign-in.
  ref.watch(actorHandoffStatusProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final status = ref.read(actorHandoffStatusProvider).value ??
          const ActorHandoffNotStarted();
      return _redirect(status, state.matchedLocation);
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.sessionResolving,
        builder: (context, state) => const SessionResolvingScreen(),
      ),
      GoRoute(
        path: AppRoutes.catalog,
        builder: (context, state) => const VocabularyCatalogPlaceholder(),
      ),
    ],
  );
});

String? _redirect(ActorHandoffStatus status, String location) {
  switch (status) {
    case ActorHandoffCompleted():
      if (location == AppRoutes.login ||
          location == AppRoutes.sessionResolving) {
        return AppRoutes.catalog;
      }
      return null;
    case ActorHandoffInProgress():
      if (location == AppRoutes.login || location == AppRoutes.catalog) {
        return AppRoutes.sessionResolving;
      }
      return null;
    case ActorHandoffNotStarted():
    case ActorHandoffFailed():
      if (location != AppRoutes.login) {
        return AppRoutes.login;
      }
      return null;
  }
}
