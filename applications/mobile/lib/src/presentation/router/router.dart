import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_bindings.dart';
import '../../domain/auth/actor_handoff_status.dart';
import '../../domain/identifier/identifier.dart';
import '../auth/login_screen.dart';
import '../auth/session_resolving_screen.dart';
import '../catalog/vocabulary_catalog_screen.dart';
import '../catalog/vocabulary_registration_screen.dart';
import '../detail/explanation_detail_screen.dart';
import '../detail/image_detail_screen.dart';
import '../detail/vocabulary_expression_detail_screen.dart';

/// Canonical route paths (spec 013 navigation-topology-contract).
class AppRoutes {
  static const login = '/login';
  static const sessionResolving = '/session-resolving';
  static const catalog = '/catalog';
  static const registration = '/registration';
  static const vocabularyPrefix = '/vocabulary';
  static const explanationPrefix = '/explanation';
  static const imagePrefix = '/image';
}

/// Provides the app's [GoRouter]. Built once; handoff state changes trigger
/// `refreshListenable` instead of a provider rebuild so MaterialApp.router
/// does not re-mount a new Navigator on every state emission.
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ValueNotifier<int>(0);
  final subscription = ref.listen<AsyncValue<ActorHandoffStatus>>(
    actorHandoffStatusProvider,
    (_, _) => notifier.value++,
  );
  ref.onDispose(() {
    subscription.close();
    notifier.dispose();
  });

  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: notifier,
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
        builder: (context, state) => const VocabularyCatalogScreen(),
      ),
      GoRoute(
        path: AppRoutes.registration,
        builder: (context, state) => const VocabularyRegistrationScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.vocabularyPrefix}/:identifier',
        builder: (context, state) => VocabularyExpressionDetailScreen(
          identifier: VocabularyExpressionIdentifier(
            state.pathParameters['identifier']!,
          ),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.explanationPrefix}/:identifier',
        builder: (context, state) => ExplanationDetailScreen(
          identifier: ExplanationIdentifier(
            state.pathParameters['identifier']!,
          ),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.imagePrefix}/:identifier',
        builder: (context, state) => ImageDetailScreen(
          identifier: VisualImageIdentifier(
            state.pathParameters['identifier']!,
          ),
        ),
      ),
    ],
  );
});

bool _isAppShellLocation(String location) {
  return location == AppRoutes.catalog ||
      location == AppRoutes.registration ||
      location.startsWith('${AppRoutes.vocabularyPrefix}/') ||
      location.startsWith('${AppRoutes.explanationPrefix}/') ||
      location.startsWith('${AppRoutes.imagePrefix}/');
}

String? _redirect(ActorHandoffStatus status, String location) {
  switch (status) {
    case ActorHandoffCompleted():
      if (location == AppRoutes.login ||
          location == AppRoutes.sessionResolving) {
        return AppRoutes.catalog;
      }
      return null;
    case ActorHandoffInProgress():
      if (location == AppRoutes.login || _isAppShellLocation(location)) {
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
