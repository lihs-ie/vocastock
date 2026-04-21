import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_bindings.dart';
import '../../domain/auth/actor_handoff_status.dart';
import '../theme/vs_tokens.dart';
import '../theme/widgets/vs_brand_mark.dart';
import '../theme/widgets/vs_spinner.dart';

/// Spec 013 canonical `Login` screen (Auth route group).
///
/// Visual reference: `screens.jsx` `VSLoginWelcome`. Hero layout with brand
/// mark, serif wordmark, uppercase tagline, a two-line Mincho headline
/// ("多義の深さに、画像を添えて。"), a paper-toned OAuth button pair, and a
/// dark ink primary CTA. Failure messages surface in muted vermilion.
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
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
          child: Column(
            children: <Widget>[
              const Spacer(),
              const VsBrandMark(),
              const SizedBox(height: 28),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontFamily: VsTokens.serif,
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    letterSpacing: -0.4,
                    color: VsTokens.ink,
                  ),
                  children: <InlineSpan>[
                    TextSpan(text: 'vocastock'),
                    TextSpan(
                      text: '·',
                      style: TextStyle(
                        color: VsTokens.accent,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'AI DICTIONARY FOR LEARNERS',
                style: theme.textTheme.labelMedium?.copyWith(
                  letterSpacing: 3,
                  color: VsTokens.inkMute,
                ),
              ),
              const SizedBox(height: 48),
              const _HeroHeadline(),
              const SizedBox(height: 14),
              Text(
                '登録した英単語を、AIが複数のSense・例文・\n視覚イメージに分解します。',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.7,
                  color: VsTokens.inkSoft,
                ),
              ),
              const Spacer(),
              _OAuthButton(
                keyValue: 'login.provider.google',
                label: 'Google で続ける',
                icon: Icons.g_mobiledata,
                onPressed: isSigningIn
                    ? null
                    : () => unawaited(
                          loginCommand.signIn(AuthProvider.google),
                        ),
              ),
              const SizedBox(height: 10),
              const _OrDivider(),
              const SizedBox(height: 10),
              _PrimaryCta(
                keyValue: 'login.provider.basic',
                label: 'メールで続ける',
                onPressed: isSigningIn
                    ? null
                    : () => unawaited(loginCommand.signIn(AuthProvider.basic)),
                loading: isSigningIn,
              ),
              const SizedBox(height: 14),
              if (failure != null)
                _FailureBanner(message: failure.message.text)
              else
                const SizedBox(height: 28),
              const SizedBox(height: 12),
              Text(
                '続行することで利用規約とプライバシーポリシーに同意したものとみなします。',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  height: 1.6,
                  color: VsTokens.inkMute,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroHeadline extends StatelessWidget {
  const _HeroHeadline();

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        style: TextStyle(
          fontFamily: VsTokens.serif,
          fontSize: 22,
          fontWeight: FontWeight.w500,
          height: 1.5,
          color: VsTokens.ink,
        ),
        children: <InlineSpan>[
          TextSpan(text: '多義の深さに、\n'),
          TextSpan(
            text: '画像',
            style: TextStyle(color: VsTokens.accent),
          ),
          TextSpan(text: 'を添えて。'),
        ],
      ),
    );
  }
}

class _OAuthButton extends StatelessWidget {
  const _OAuthButton({
    required this.keyValue,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String keyValue;
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        key: Key(keyValue),
        onPressed: onPressed,
        icon: Icon(icon, size: 20, color: VsTokens.ink),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          backgroundColor: VsTokens.paperSoft,
          foregroundColor: VsTokens.ink,
          side: const BorderSide(color: VsTokens.inkHair),
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(VsTokens.radiusMd)),
          ),
          textStyle: const TextStyle(
            fontFamily: VsTokens.sans,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    const line = Expanded(
      child: Divider(color: VsTokens.inkHair, thickness: 0.5, height: 0.5),
    );
    return Row(
      children: <Widget>[
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'または',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: VsTokens.inkMute,
                  letterSpacing: 1,
                ),
          ),
        ),
        line,
      ],
    );
  }
}

class _PrimaryCta extends StatelessWidget {
  const _PrimaryCta({
    required this.keyValue,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String keyValue;
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        key: Key(keyValue),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: VsTokens.ink,
          foregroundColor: VsTokens.paper,
          disabledBackgroundColor: VsTokens.inkMute,
          disabledForegroundColor: VsTokens.paperSoft,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(VsTokens.radiusMd)),
          ),
          textStyle: const TextStyle(
            fontFamily: VsTokens.sans,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: VsSpinner(color: VsTokens.paper),
              )
            : Text(label),
      ),
    );
  }
}

class _FailureBanner extends StatelessWidget {
  const _FailureBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: VsTokens.accentSoft,
        borderRadius: BorderRadius.circular(VsTokens.radiusSm),
      ),
      child: Text(
        message,
        key: const Key('login.failure-message'),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: VsTokens.sans,
          fontSize: 12,
          height: 1.5,
          color: VsTokens.err,
        ),
      ),
    );
  }
}
