import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../app_bindings.dart';
import '../../application/envelope/command_response_envelope.dart';
import '../../domain/identifier/identifier.dart';
import '../router/router.dart';

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
        // Both `accepted` and `reusedExisting` land on the catalog so the
        // learner can see their entry.
        context.go(AppRoutes.catalog);
      case CommandResponseRejected(:final message):
        setState(() {
          _errorText = message.text;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新しい単語を登録')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const Key('registration.text-field'),
              controller: _textController,
              enabled: !_submitting,
              decoration: const InputDecoration(
                labelText: '単語または表現',
                hintText: '例: serendipity',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              key: const Key('registration.submit'),
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('登録する'),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorText!,
                key: const Key('registration.error-message'),
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
