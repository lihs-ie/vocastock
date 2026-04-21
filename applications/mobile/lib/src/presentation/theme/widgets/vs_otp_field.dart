import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../vs_tokens.dart';

/// Six-digit OTP input mirroring `screens.jsx` `VSLoginVerify`. Each digit
/// is a separate 42x52 paper-framed cell; focus auto-advances on input and
/// retreats on backspace. Emits the full code via [onCompleted] when all
/// six digits are filled.
class VsOtpField extends StatefulWidget {
  const VsOtpField({
    required this.onCompleted,
    this.length = 6,
    super.key,
  });

  final void Function(String code) onCompleted;
  final int length;

  @override
  State<VsOtpField> createState() => _VsOtpFieldState();
}

class _VsOtpFieldState extends State<VsOtpField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List<TextEditingController>.generate(
      widget.length,
      (_) => TextEditingController(),
    );
    _focusNodes =
        List<FocusNode>.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _focusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _handleChange(int index, String value) {
    if (value.length > 1) {
      _controllers[index].text = value.substring(value.length - 1);
      _controllers[index].selection = TextSelection.fromPosition(
        TextPosition(offset: _controllers[index].text.length),
      );
    }
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    final code = _controllers.map((c) => c.text).join();
    if (code.length == widget.length && !code.contains(' ')) {
      widget.onCompleted(code);
    }
    setState(() {});
  }

  KeyEventResult _handleKey(int index, FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].text = '';
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (var index = 0; index < widget.length; index++)
          Padding(
            padding: EdgeInsets.only(
              right: index == widget.length - 1 ? 0 : 8,
            ),
            child: _OtpCell(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              onChanged: (v) => _handleChange(index, v),
              onKeyEvent: (n, e) => _handleKey(index, n, e),
            ),
          ),
      ],
    );
  }
}

class _OtpCell extends StatelessWidget {
  const _OtpCell({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onKeyEvent,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final KeyEventResult Function(FocusNode, KeyEvent) onKeyEvent;

  @override
  Widget build(BuildContext context) {
    final hasValue = controller.text.isNotEmpty;
    return SizedBox(
      width: 42,
      height: 52,
      child: Focus(
        onKeyEvent: onKeyEvent,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          maxLength: 1,
          textAlign: TextAlign.center,
          cursorColor: VsTokens.accent,
          style: const TextStyle(
            fontFamily: VsTokens.serif,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: VsTokens.ink,
          ),
          decoration: InputDecoration(
            counterText: '',
            isCollapsed: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            filled: true,
            fillColor:
                hasValue ? VsTokens.paperSoft : Colors.transparent,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(VsTokens.radiusSm),
              borderSide: BorderSide(
                color: hasValue ? VsTokens.ink : VsTokens.inkHair,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(VsTokens.radiusSm),
              borderSide: const BorderSide(color: VsTokens.ink, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}
