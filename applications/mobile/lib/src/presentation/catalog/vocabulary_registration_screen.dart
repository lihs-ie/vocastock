import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../app_bindings.dart';
import '../../application/envelope/command_response_envelope.dart';
import '../../domain/identifier/identifier.dart';
import '../router/router.dart';
import '../theme/vs_tokens.dart';
import '../theme/widgets/vs_input_field.dart';
import '../theme/widgets/vs_section_label.dart';
import '../theme/widgets/vs_spinner.dart';

/// Spec 013 canonical `VocabularyRegistration` screen.
///
/// Visual reference: `screens.jsx` `VSAddInput`. Top chrome is キャンセル /
/// 新規登録 / 登録 (register submit). Body is a Mincho 34 single-line field
/// with a hint, a preset-detail radio card, and an accent-soft info box
/// describing asynchronous generation.
class VocabularyRegistrationScreen extends ConsumerStatefulWidget {
  const VocabularyRegistrationScreen({super.key});

  @override
  ConsumerState<VocabularyRegistrationScreen> createState() =>
      _VocabularyRegistrationScreenState();
}

enum _DetailPreset { standard, rich, minimal }

class _VocabularyRegistrationScreenState
    extends ConsumerState<VocabularyRegistrationScreen> {
  final TextEditingController _textController = TextEditingController();
  static const Uuid _uuidGenerator = Uuid();
  bool _submitting = false;
  String? _errorText;
  _DetailPreset _preset = _DetailPreset.standard;

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
                    style: TextButton.styleFrom(
                      foregroundColor: VsTokens.inkSoft,
                    ),
                    child: const Text('キャンセル'),
                  ),
                  Text(
                    '新規登録',
                    style: theme.textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: _submitting ? null : _submit,
                    style: TextButton.styleFrom(
                      foregroundColor: VsTokens.accent,
                    ),
                    child: const Text('登録'),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 0.5, height: 0.5),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                  const VsSectionLabel('ENGLISH EXPRESSION'),
                  const SizedBox(height: 12),
                  VsInputField(
                    key: const Key('registration.text-field'),
                    controller: _textController,
                    enabled: !_submitting,
                    autofocus: true,
                    onChanged: (_) => setState(() {}),
                    hint: 'serendipity',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '単語 / 連語どちらも可。小文字・原形での登録を推奨。 '
                    '重複は学習者ごとの正規化テキストで判定。',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: VsTokens.inkMute,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const VsSectionLabel('AI生成の詳細度'),
                  const SizedBox(height: 10),
                  _PresetCard(
                    selected: _preset,
                    onChanged: (value) =>
                        setState(() => _preset = value),
                  ),
                  const SizedBox(height: 24),
                  const _InfoBox(),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: ElevatedButton(
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
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetOption {
  const _PresetOption({
    required this.value,
    required this.label,
    required this.description,
  });

  final _DetailPreset value;
  final String label;
  final String description;
}

const List<_PresetOption> _presetOptions = <_PresetOption>[
  _PresetOption(
    value: _DetailPreset.standard,
    label: '標準',
    description: 'Sense・発音・例文・コロケーション',
  ),
  _PresetOption(
    value: _DetailPreset.rich,
    label: '詳細',
    description: '+ 類似表現・語源・使い分け',
  ),
  _PresetOption(
    value: _DetailPreset.minimal,
    label: '最小',
    description: '代表 Sense のみ（素早く）',
  ),
];

class _PresetCard extends StatelessWidget {
  const _PresetCard({required this.selected, required this.onChanged});

  final _DetailPreset selected;
  final ValueChanged<_DetailPreset> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: VsTokens.paperSoft,
        borderRadius: BorderRadius.circular(VsTokens.radiusMd),
        border: Border.all(color: VsTokens.inkHair),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          for (var index = 0; index < _presetOptions.length; index++)
            _PresetRow(
              option: _presetOptions[index],
              isLast: index == _presetOptions.length - 1,
              isSelected: _presetOptions[index].value == selected,
              onTap: () => onChanged(_presetOptions[index].value),
              theme: theme,
            ),
        ],
      ),
    );
  }
}

class _PresetRow extends StatelessWidget {
  const _PresetRow({
    required this.option,
    required this.isLast,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  final _PresetOption option;
  final bool isLast;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isLast ? Colors.transparent : VsTokens.inkHair,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    option.label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontFamily: VsTokens.sans,
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: VsTokens.ink,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: VsTokens.inkMute,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, size: 16, color: VsTokens.accent),
          ],
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: VsTokens.accentSoft,
        borderRadius: BorderRadius.circular(VsTokens.radiusMd),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.auto_awesome, size: 16, color: VsTokens.accentDeep),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '解説生成は非同期で 10〜30 秒ほど。完了時に通知します。',
              style: TextStyle(
                fontFamily: VsTokens.sans,
                fontSize: 11,
                height: 1.5,
                color: VsTokens.accentDeep,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
