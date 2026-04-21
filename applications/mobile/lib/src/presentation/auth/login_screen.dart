import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_bindings.dart';
import '../../domain/auth/actor_handoff_status.dart';
import '../theme/vs_tokens.dart';
import '../theme/widgets/vs_spinner.dart';
import '../theme/widgets/vs_wordmark.dart';

/// Spec 013 canonical `Login` screen (Auth route group).
///
/// State variants:
///  - `statusOnly`: idle, provider selector is available.
///  - `loading`: sign-in in progress; selector is disabled and a spinner
///    indicates which stage is running.
///  - `retryableFailure`: handoff failed; provider selector is re-enabled
///    and the reason is surfaced as a `UserFacingMessage`.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(actorHandoffStatusProvider);
    final loginCommand = ref.watch(loginCommandProvider);
    final theme = Theme.of(context);

    final status = statusAsync.value ?? const ActorHandoffNotStarted();
    final isSigningIn = status is ActorHandoffInProgress;
    final failure = status is ActorHandoffFailed ? status : null;

    return Scaffold(
      backgroundColor: VsTokens.paper,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const VsWordmark(size: 15),
              const SizedBox(height: 80),
              Text(
                'VOCASTOCK',
                style: theme.textTheme.labelMedium,
              ),
              const SizedBox(height: 6),
              Text(
                '多義の深さに、\n画像を添えて。',
                style: theme.textTheme.displayMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'AIが生成する辞書的な解説と、単語を視覚で捉える画像。',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: VsTokens.inkMute,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                key: const Key('login.provider.basic'),
                onPressed: isSigningIn
                    ? null
                    : () => unawaited(
                          loginCommand.signIn(AuthProvider.basic),
                        ),
                child: const Text('メールでサインイン'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                key: const Key('login.provider.google'),
                onPressed: isSigningIn
                    ? null
                    : () => unawaited(
                          loginCommand.signIn(AuthProvider.google),
                        ),
                child: const Text('Google でサインイン'),
              ),
              const SizedBox(height: 24),
              if (isSigningIn)
                const Center(child: VsSpinner(size: 18))
              else if (failure != null)
                Text(
                  failure.message.text,
                  key: const Key('login.failure-message'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: VsTokens.err,
                  ),
                )
              else
                const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}
