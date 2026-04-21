import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_bindings.dart';
import '../router/router.dart';
import '../theme/vs_tokens.dart';
import '../theme/widgets/vs_wordmark.dart';

/// Spec 013 canonical `RestrictedAccess` screen (Restricted route group).
///
/// Visual reference: `screens.jsx` restricted template. Accent-soft badge
/// with a block icon, Mincho headline, muted sans body, and two recovery
/// CTAs (status check + sign-out).
class RestrictedAccessScreen extends ConsumerWidget {
  const RestrictedAccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: VsTokens.paper,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Align(
                alignment: Alignment.centerLeft,
                child: VsWordmark(size: 13),
              ),
              const Spacer(),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: VsTokens.accentSoft,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.block,
                    key: Key('restricted.icon'),
                    size: 32,
                    color: VsTokens.accentDeep,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'ご利用になれません',
                textAlign: TextAlign.center,
                style: theme.textTheme.displaySmall,
              ),
              const SizedBox(height: 10),
              Text(
                'このアカウントは現在ご利用いただけません',
                key: const Key('restricted.message'),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: VsTokens.inkMute,
                  height: 1.6,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                key: const Key('restricted.status-link'),
                onPressed: () => context.go(AppRoutes.subscriptionStatus),
                child: const Text('サブスクリプション状態を確認'),
              ),
              const SizedBox(height: 8),
              TextButton(
                key: const Key('restricted.logout'),
                onPressed: () async {
                  await ref.read(logoutCommandProvider).signOut();
                  if (!context.mounted) return;
                  context.go(AppRoutes.login);
                },
                style: TextButton.styleFrom(
                  foregroundColor: VsTokens.inkMute,
                ),
                child: const Text('サインアウトして再試行'),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
