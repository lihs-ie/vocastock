import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_bindings.dart';
import '../../domain/auth/actor_handoff_status.dart';
import '../theme/vs_tokens.dart';
import '../theme/widgets/vs_spinner.dart';
import '../theme/widgets/vs_wordmark.dart';

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
    final theme = Theme.of(context);

    final stageLabel = switch (status) {
      ActorHandoffInProgress(:final stage) => _stageLabel(stage),
      _ => '初期化中',
    };

    return Scaffold(
      backgroundColor: VsTokens.paper,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 32),
              const Align(
                alignment: Alignment.centerLeft,
                child: VsWordmark(size: 15),
              ),
              const Spacer(),
              const VsSpinner(size: 20),
              const SizedBox(height: 20),
              Text(
                stageLabel,
                key: const Key('session-resolving.stage'),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'サインインを完了しています',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: VsTokens.inkMute,
                ),
              ),
              const Spacer(),
              TextButton(
                key: const Key('session-resolving.cancel'),
                onPressed: () => unawaited(logoutCommand.signOut()),
                child: const Text('キャンセル'),
              ),
              const SizedBox(height: 24),
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
