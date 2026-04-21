import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_bindings.dart';
import '../../domain/auth/actor_handoff_status.dart';

/// Spec 013 canonical `SessionResolving` screen (Auth route group).
///
/// Always renders as `loading`. Displays the current handoff stage label as
/// progress hint; does not expose actor reference itself.
class SessionResolvingScreen extends ConsumerWidget {
  const SessionResolvingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(actorHandoffStatusProvider);
    final logoutCommand = ref.watch(logoutCommandProvider);
    final status = statusAsync.value ?? const ActorHandoffNotStarted();

    final stageLabel = switch (status) {
      ActorHandoffInProgress(:final stage) => _stageLabel(stage),
      _ => '初期化中',
    };

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                stageLabel,
                key: const Key('session-resolving.stage'),
              ),
              const SizedBox(height: 32),
              TextButton(
                key: const Key('session-resolving.cancel'),
                onPressed: () => unawaited(logoutCommand.signOut()),
                child: const Text('キャンセル'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _stageLabel(ActorHandoffStage stage) {
    return switch (stage) {
      ActorHandoffStage.providerSignIn => '認証プロバイダに接続しています',
      ActorHandoffStage.backendTokenVerify => 'トークンを検証しています',
      ActorHandoffStage.actorResolve => 'アカウント情報を取得しています',
    };
  }
}
