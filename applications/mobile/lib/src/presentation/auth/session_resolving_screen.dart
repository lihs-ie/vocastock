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
/// Visual reference: `screens.jsx` running / loading pattern. A compact
/// wordmark at the top, a centered spinner with a Mincho stage label and a
/// muted sans helper, and a cancel text button at the foot.
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
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Column(
            children: <Widget>[
              const Align(
                alignment: Alignment.centerLeft,
                child: VsWordmark(size: 13),
              ),
              const Spacer(),
              const VsSpinner(size: 24),
              const SizedBox(height: 24),
              Text(
                stageLabel,
                key: const Key('session-resolving.stage'),
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
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
                style: TextButton.styleFrom(
                  foregroundColor: VsTokens.inkMute,
                ),
                child: const Text('キャンセル'),
              ),
              const SizedBox(height: 8),
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
