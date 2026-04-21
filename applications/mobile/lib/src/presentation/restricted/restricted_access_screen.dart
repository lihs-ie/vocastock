import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_bindings.dart';
import '../router/router.dart';

/// Spec 013 canonical `RestrictedAccess` screen (Restricted route group).
///
/// Hard stop — the learner cannot see any AppShell content. Only two
/// recovery options are exposed: review subscription status, or sign out
/// and attempt to sign back in.
class RestrictedAccessScreen extends ConsumerWidget {
  const RestrictedAccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('ご利用になれません')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.block,
              key: Key('restricted.icon'),
              size: 72,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            const Text(
              'このアカウントは現在ご利用いただけません',
              key: Key('restricted.message'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
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
              child: const Text('サインアウトして再試行'),
            ),
          ],
        ),
      ),
    );
  }
}
