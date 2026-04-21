import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_bindings.dart';
import '../../domain/auth/actor_handoff_status.dart';
import '../../domain/identifier/identifier.dart';
import '../../domain/status/subscription_state.dart';
import '../auth/login_screen.dart';
import '../auth/session_resolving_screen.dart';
import '../catalog/vocabulary_catalog_screen.dart';
import '../catalog/vocabulary_registration_screen.dart';
import '../detail/explanation_detail_screen.dart';
import '../detail/image_detail_screen.dart';
import '../detail/vocabulary_expression_detail_screen.dart';
import '../paywall/paywall_screen.dart';
import '../proficiency/proficiency_screen.dart';
import '../restricted/restricted_access_screen.dart';
import '../shell/app_shell.dart';
import '../subscription/subscription_status_screen.dart';

/// Canonical route paths (spec 013 navigation-topology-contract).
class AppRoutes {
  static const login = '/login';
  static const sessionResolving = '/session-resolving';
  static const catalog = '/catalog';
  static const registration = '/registration';
  static const vocabularyPrefix = '/vocabulary';
  static const explanationPrefix = '/explanation';
  static const imagePrefix = '/image';
  static const subscriptionStatus = '/subscription';
  static const paywall = '/paywall';
  static const proficiency = '/proficiency';
  static const restricted = '/restricted';
}

/// Provides the app's [GoRouter]. Built once; handoff and subscription
/// status changes trigger `refreshListenable` so MaterialApp.router does not
/// re-mount a new Navigator on every state emission.
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ValueNotifier<int>(0);
  final handoffSubscription = ref.listen<AsyncValue<ActorHandoffStatus>>(
    actorHandoffStatusProvider,
    (_, _) => notifier.value++,
  );
  final subscriptionSubscription = ref.listen(
    subscriptionStatusStreamProvider,
    (_, _) => notifier.value++,
  );
  ref.onDispose(() {
    handoffSubscription.close();
    subscriptionSubscription.close();
    notifier.dispose();
  });

  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: notifier,
    redirect: (context, state) {
      final handoff = ref.read(actorHandoffStatusProvider).value ??
          const ActorHandoffNotStarted();
      final subscription =
          ref.read(subscriptionStatusStreamProvider).value?.state;
      return _redirect(handoff, subscription, state.matchedLocation);
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.sessionResolving,
        builder: (context, state) => const SessionResolvingScreen(),
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
      GoRoute(
        path: AppRoutes.restricted,
        builder: (context, state) => const RestrictedAccessScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.catalog,
                builder: (context, state) => const VocabularyCatalogScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.proficiency,
                builder: (context, state) => const ProficiencyScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.paywall,
                builder: (context, state) => const PaywallScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.subscriptionStatus,
                builder: (context, state) =>
                    const SubscriptionStatusScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

bool _isAppShellLocation(String location) {
  return location == AppRoutes.catalog ||
      location == AppRoutes.registration ||
      location.startsWith('${AppRoutes.vocabularyPrefix}/') ||
      location.startsWith('${AppRoutes.explanationPrefix}/') ||
      location.startsWith('${AppRoutes.imagePrefix}/') ||
      location == AppRoutes.subscriptionStatus ||
      location == AppRoutes.paywall ||
      location == AppRoutes.proficiency;
}

String? _redirect(
  ActorHandoffStatus handoff,
  SubscriptionState? subscription,
  String location,
) {
  // Auth boundary takes precedence over subscription state.
  switch (handoff) {
    case ActorHandoffCompleted():
      break; // fall through to subscription checks
    case ActorHandoffInProgress():
      if (location == AppRoutes.login || _isAppShellLocation(location)) {
        return AppRoutes.sessionResolving;
      }
      return null;
    case ActorHandoffNotStarted():
    case ActorHandoffFailed():
      if (location == AppRoutes.restricted) {
        return null; // restricted screen handles its own logout flow
      }
      if (location != AppRoutes.login) {
        return AppRoutes.login;
      }
      return null;
  }

  // Handoff is completed — subscription access policy applies.
  if (subscription == SubscriptionState.revoked &&
      location != AppRoutes.restricted) {
    return AppRoutes.restricted;
  }
  if (subscription != SubscriptionState.revoked &&
      location == AppRoutes.restricted) {
    return AppRoutes.subscriptionStatus;
  }

  if (location == AppRoutes.login ||
      location == AppRoutes.sessionResolving) {
    return AppRoutes.catalog;
  }
  return null;
}
