import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_bindings.dart';
import '../../domain/auth/actor_handoff_status.dart';
import '../theme/vs_tokens.dart';
import '../theme/widgets/vs_brand_mark.dart';
import '../theme/widgets/vs_input_field.dart';
import '../theme/widgets/vs_mode_toggle.dart';
import '../theme/widgets/vs_otp_field.dart';
import '../theme/widgets/vs_section_label.dart';
import '../theme/widgets/vs_spinner.dart';

/// Spec 013 canonical `Login` screen.
///
/// The screen hosts an internal state machine mirroring `screens.jsx`
/// `VSLogin`: welcome → sign-in / sign-up → verify → done. Each step is a
/// private widget; the route itself stays at `/login`.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

enum _LoginStep { welcome, signIn, signUp, verify, done }

class _LoginScreenState extends ConsumerState<LoginScreen> {
  _LoginStep _step = _LoginStep.welcome;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _verifying = false;
  Timer? _doneTimer;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _doneTimer?.cancel();
    super.dispose();
  }

  void _goto(_LoginStep next) => setState(() => _step = next);

  Future<void> _submitSignIn() async {
    final command = ref.read(loginCommandProvider);
    unawaited(command.signIn(AuthProvider.basic));
  }

  void _submitSignUp() {
    _goto(_LoginStep.verify);
  }

  void _onCodeCompleted(String _) {
    setState(() => _verifying = true);
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      _goto(_LoginStep.done);
      _doneTimer = Timer(const Duration(seconds: 2), () {
        if (!mounted) return;
        unawaited(ref.read(loginCommandProvider).signIn(AuthProvider.basic));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(actorHandoffStatusProvider);
    final status = statusAsync.value ?? const ActorHandoffNotStarted();
    final isSigningIn = status is ActorHandoffInProgress;
    final failure = status is ActorHandoffFailed ? status : null;

    return Scaffold(
      backgroundColor: VsTokens.paper,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _buildStep(context, isSigningIn, failure),
        ),
      ),
    );
  }

  Widget _buildStep(
    BuildContext context,
    bool isSigningIn,
    ActorHandoffFailed? failure,
  ) {
    switch (_step) {
      case _LoginStep.welcome:
        return _WelcomeStep(
          key: const ValueKey<String>('login.step.welcome'),
          isSigningIn: isSigningIn,
          failure: failure,
          onGoogle: () => unawaited(
            ref.read(loginCommandProvider).signIn(AuthProvider.google),
          ),
          onEmailContinue: () =>
              unawaited(ref.read(loginCommandProvider).signIn(AuthProvider.basic)),
          onSignUp: () => _goto(_LoginStep.signUp),
        );
      case _LoginStep.signIn:
        return _EmailFormStep(
          key: const ValueKey<String>('login.step.signin'),
          mode: _LoginStep.signIn,
          emailController: _emailController,
          passwordController: _passwordController,
          isSigningIn: isSigningIn,
          failure: failure,
          onBack: () => _goto(_LoginStep.welcome),
          onModeChanged: _goto,
          onSubmit: () => unawaited(_submitSignIn()),
        );
      case _LoginStep.signUp:
        return _EmailFormStep(
          key: const ValueKey<String>('login.step.signup'),
          mode: _LoginStep.signUp,
          emailController: _emailController,
          passwordController: _passwordController,
          isSigningIn: isSigningIn,
          failure: failure,
          onBack: () => _goto(_LoginStep.welcome),
          onModeChanged: _goto,
          onSubmit: _submitSignUp,
        );
      case _LoginStep.verify:
        return _VerifyStep(
          key: const ValueKey<String>('login.step.verify'),
          email: _emailController.text.isEmpty
              ? 'you@example.com'
              : _emailController.text,
          verifying: _verifying,
          onBack: () => _goto(_LoginStep.signUp),
          onCompleted: _onCodeCompleted,
          onResend: () {},
        );
      case _LoginStep.done:
        return const _DoneStep(key: ValueKey<String>('login.step.done'));
    }
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({
    required this.isSigningIn,
    required this.failure,
    required this.onGoogle,
    required this.onEmailContinue,
    required this.onSignUp,
    super.key,
  });

  final bool isSigningIn;
  final ActorHandoffFailed? failure;
  final VoidCallback onGoogle;
  final VoidCallback onEmailContinue;
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 20),
      child: Column(
        children: <Widget>[
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
          const SizedBox(height: 48),
          _OAuthButton(
            keyValue: 'login.provider.google',
            label: 'Google で続ける',
            icon: Icons.g_mobiledata,
            onPressed: isSigningIn ? null : onGoogle,
          ),
          const SizedBox(height: 10),
          const _OrDivider(),
          const SizedBox(height: 10),
          _PrimaryCta(
            keyValue: 'login.provider.basic',
            label: 'メールで続ける',
            onPressed: isSigningIn ? null : onEmailContinue,
          ),
          const SizedBox(height: 10),
          TextButton(
            key: const Key('login.signup-link'),
            onPressed: isSigningIn ? null : onSignUp,
            style: TextButton.styleFrom(foregroundColor: VsTokens.accentDeep),
            child: const Text('新規登録はこちら →'),
          ),
          const SizedBox(height: 14),
          if (failure != null)
            _FailureBanner(message: failure!.message.text)
          else
            const SizedBox(height: 20),
          const SizedBox(height: 8),
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
    );
  }
}

class _EmailFormStep extends StatelessWidget {
  const _EmailFormStep({
    required this.mode,
    required this.emailController,
    required this.passwordController,
    required this.isSigningIn,
    required this.failure,
    required this.onBack,
    required this.onModeChanged,
    required this.onSubmit,
    super.key,
  });

  final _LoginStep mode;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isSigningIn;
  final ActorHandoffFailed? failure;
  final VoidCallback onBack;
  final ValueChanged<_LoginStep> onModeChanged;
  final VoidCallback onSubmit;

  bool get _isSignUp => mode == _LoginStep.signUp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.chevron_left, size: 18),
              label: const Text('戻る'),
              style: TextButton.styleFrom(
                foregroundColor: VsTokens.inkSoft,
                padding: EdgeInsets.zero,
                textStyle: const TextStyle(
                  fontFamily: VsTokens.sans,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Center(child: VsBrandMark(size: 48)),
          const SizedBox(height: 28),
          Text(
            _isSignUp ? '新しい単語帳を、作ろう。' : 'おかえりなさい。',
            textAlign: TextAlign.center,
            style: theme.textTheme.displaySmall?.copyWith(fontSize: 26),
          ),
          const SizedBox(height: 6),
          Text(
            _isSignUp
                ? '30秒で登録、登録語数に制限はありません'
                : '続きからはじめましょう',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: VsTokens.inkMute,
            ),
          ),
          const SizedBox(height: 20),
          VsModeToggle<_LoginStep>(
            selected: mode,
            onChanged: onModeChanged,
            options: const <VsModeOption<_LoginStep>>[
              VsModeOption<_LoginStep>(
                value: _LoginStep.signIn,
                label: 'ログイン',
              ),
              VsModeOption<_LoginStep>(
                value: _LoginStep.signUp,
                label: '新規登録',
              ),
            ],
          ),
          const SizedBox(height: 24),
          const VsSectionLabel('EMAIL'),
          const SizedBox(height: 8),
          VsInputField(
            key: const Key('login.email.field'),
            controller: emailController,
            autofocus: true,
            enabled: !isSigningIn,
            fontSize: 18,
            keyboardType: TextInputType.emailAddress,
            hint: 'you@example.com',
          ),
          const SizedBox(height: 18),
          const VsSectionLabel('PASSWORD'),
          const SizedBox(height: 8),
          VsInputField(
            key: const Key('login.password.field'),
            controller: passwordController,
            enabled: !isSigningIn,
            fontSize: 18,
            obscureText: true,
            hint: '••••••••',
            fontFamily: VsTokens.mono,
          ),
          if (_isSignUp) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              '8文字以上・英数字を含む',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: VsTokens.inkMute,
              ),
            ),
          ],
          if (_isSignUp) ...<Widget>[
            const SizedBox(height: 18),
            const _AgreementNotice(),
          ],
          const SizedBox(height: 28),
          ElevatedButton(
            key: _isSignUp
                ? const Key('login.signup.submit')
                : const Key('login.signin.submit'),
            onPressed: isSigningIn ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: VsTokens.ink,
              foregroundColor: VsTokens.paper,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(VsTokens.radiusMd)),
              ),
            ),
            child: isSigningIn
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: VsSpinner(size: 14, color: VsTokens.paper),
                      ),
                      SizedBox(width: 8),
                      Text('認証中...'),
                    ],
                  )
                : Text(_isSignUp ? 'アカウントを作成' : 'ログイン'),
          ),
          if (failure != null) ...<Widget>[
            const SizedBox(height: 14),
            _FailureBanner(message: failure!.message.text),
          ],
        ],
      ),
    );
  }
}

class _VerifyStep extends StatelessWidget {
  const _VerifyStep({
    required this.email,
    required this.verifying,
    required this.onBack,
    required this.onCompleted,
    required this.onResend,
    super.key,
  });

  final String email;
  final bool verifying;
  final VoidCallback onBack;
  final void Function(String) onCompleted;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.chevron_left, size: 18),
              label: const Text('戻る'),
              style: TextButton.styleFrom(
                foregroundColor: VsTokens.inkSoft,
                padding: EdgeInsets.zero,
                textStyle: const TextStyle(
                  fontFamily: VsTokens.sans,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Center(child: VsBrandMark(size: 48)),
          const SizedBox(height: 28),
          Text(
            '確認コードを入力',
            textAlign: TextAlign.center,
            style: theme.textTheme.displaySmall?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              style: theme.textTheme.bodySmall?.copyWith(
                color: VsTokens.inkSoft,
                height: 1.6,
              ),
              children: <InlineSpan>[
                TextSpan(
                  text: email,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: VsTokens.ink,
                  ),
                ),
                const TextSpan(text: ' に\n6桁のコードを送信しました'),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          VsOtpField(
            key: const Key('login.verify.code'),
            onCompleted: onCompleted,
          ),
          const SizedBox(height: 20),
          if (verifying)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const VsSpinner(size: 14),
                const SizedBox(width: 8),
                Text(
                  'コードを確認中...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: VsTokens.inkSoft,
                  ),
                ),
              ],
            )
          else ...<Widget>[
            Text(
              '届いていませんか？',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: VsTokens.inkMute,
              ),
            ),
            TextButton(
              onPressed: onResend,
              child: const Text('コードを再送信'),
            ),
          ],
          const Spacer(),
          const _VerifyInfoBox(),
        ],
      ),
    );
  }
}

class _DoneStep extends StatelessWidget {
  const _DoneStep({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: Column(
          key: const Key('login.done'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 350),
              tween: Tween<double>(begin: 0.96, end: 1),
              curve: Curves.easeOut,
              builder: (context, value, child) => Transform.scale(
                scale: value,
                child: Opacity(opacity: value, child: child),
              ),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: <Widget>[
                  const VsBrandMark(size: 80),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: VsTokens.ok,
                      shape: BoxShape.circle,
                      border: Border.all(color: VsTokens.paper, width: 2),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 14,
                      color: VsTokens.paper,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'ようこそ、vocastock へ。',
              textAlign: TextAlign.center,
              style: theme.textTheme.displaySmall?.copyWith(
                fontSize: 22,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '最初の単語を登録しましょう',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: VsTokens.inkSoft,
              ),
            ),
          ],
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
          TextSpan(text: '画像', style: TextStyle(color: VsTokens.accent)),
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
  });

  final String keyValue;
  final String label;
  final VoidCallback? onPressed;

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
        child: Text(label),
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

class _AgreementNotice extends StatelessWidget {
  const _AgreementNotice();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: VsTokens.ink,
            borderRadius: BorderRadius.circular(VsTokens.radiusSm),
          ),
          child: const Icon(Icons.check, size: 12, color: VsTokens.paper),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '学習進捗を端末間で同期します。メールアドレスは '
            'Learner.identifier として正規化されます。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: VsTokens.inkSoft,
                  height: 1.6,
                ),
          ),
        ),
      ],
    );
  }
}

class _VerifyInfoBox extends StatelessWidget {
  const _VerifyInfoBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: VsTokens.paperSoft,
        border: Border.all(color: VsTokens.inkHair),
        borderRadius: BorderRadius.circular(VsTokens.radiusMd),
      ),
      child: const Row(
        children: <Widget>[
          Icon(Icons.schedule_outlined, size: 14, color: VsTokens.inkMute),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'コード有効期限 10 分',
                  style: TextStyle(
                    fontFamily: VsTokens.sans,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: VsTokens.ink,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'EmailVerificationStatus: pending',
                  style: TextStyle(
                    fontFamily: VsTokens.mono,
                    fontSize: 10,
                    color: VsTokens.inkSoft,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
