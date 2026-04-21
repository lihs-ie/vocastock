import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../app_bindings.dart';
import '../../application/envelope/command_response_envelope.dart';
import '../../domain/identifier/identifier.dart';
import '../router/router.dart';
import '../theme/vs_tokens.dart';
import '../theme/widgets/vs_spinner.dart';
import '../theme/widgets/vs_wordmark.dart';

/// Spec 013 canonical `VocabularyRegistration` screen.
///
/// UI state:
///  - `statusOnly` while the form is idle.
///  - `loading` while the command is in flight.
///  - `retryableFailure` when the backend rejects the submission.
class VocabularyRegistrationScreen extends ConsumerStatefulWidget {
  const VocabularyRegistrationScreen({super.key});

  @override
  ConsumerState<VocabularyRegistrationScreen> createState() =>
      _VocabularyRegistrationScreenState();
}

class _VocabularyRegistrationScreenState
    extends ConsumerState<VocabularyRegistrationScreen> {
  final TextEditingController _textController = TextEditingController();
  static const Uuid _uuidGenerator = Uuid();
  bool _submitting = false;
  String? _errorText;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final command = ref.read(registerVocabularyExpressionCommandProvider);
    setState(() {
      _submitting = true;
      _errorText = null;
    });
    final response = await command.register(
      text: _textController.text,
      idempotencyKey: IdempotencyKey(_uuidGenerator.v4()),
    );
    if (!mounted) return;
    setState(() {
      _submitting = false;
    });
    switch (response) {
      case CommandResponseAccepted():
        context.go(AppRoutes.catalog);
      case CommandResponseRejected(:final message):
        setState(() {
          _errorText = message.text;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: VsTokens.paper,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  TextButton(
                    onPressed: _submitting
                        ? null
                        : () => context.go(AppRoutes.catalog),
                    child: const Text('キャンセル'),
                  ),
                  const VsWordmark(),
                  TextButton(
                    onPressed: _submitting ? null : _submit,
                    child: const Text('登録'),
                  ),
                ],
              ),
            ),
            const Divider(height: 0.5, thickness: 0.5),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'ENGLISH EXPRESSION',
                      style: theme.textTheme.labelMedium,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      key: const Key('registration.text-field'),
                      controller: _textController,
                      enabled: !_submitting,
                      autofocus: true,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(
                        fontFamily: VsTokens.serif,
                        fontSize: 34,
                        fontWeight: FontWeight.w600,
                        color: VsTokens.ink,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'serendipity',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '単語 / 連語どちらも可。小文字・原形での登録を推奨。',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: VsTokens.inkMute,
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      key: const Key('registration.submit'),
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: VsSpinner(color: VsTokens.paper),
                            )
                          : const Text('この表現を登録'),
                    ),
                    if (_errorText != null) ...<Widget>[
                      const SizedBox(height: 16),
                      Text(
                        _errorText!,
                        key: const Key('registration.error-message'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: VsTokens.err,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
