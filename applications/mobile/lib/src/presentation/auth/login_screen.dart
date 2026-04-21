import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_bindings.dart';
import '../../domain/auth/actor_handoff_status.dart';

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

    final status = statusAsync.value ?? const ActorHandoffNotStarted();
    final isSigningIn = status is ActorHandoffInProgress;
    final failure = status is ActorHandoffFailed ? status : null;

    return Scaffold(
      appBar: AppBar(title: const Text('vocastock')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'サインインして vocastock を始める',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              key: const Key('login.provider.basic'),
              onPressed: isSigningIn
                  ? null
                  : () => unawaited(loginCommand.signIn(AuthProvider.basic)),
              child: const Text('メールでサインイン'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              key: const Key('login.provider.google'),
              onPressed: isSigningIn
                  ? null
                  : () => unawaited(loginCommand.signIn(AuthProvider.google)),
              child: const Text('Google でサインイン'),
            ),
            if (isSigningIn) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
            if (failure != null) ...[
              const SizedBox(height: 24),
              Text(
                failure.message.text,
                key: const Key('login.failure-message'),
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
