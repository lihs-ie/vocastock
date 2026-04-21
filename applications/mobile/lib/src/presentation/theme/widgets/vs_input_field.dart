import 'package:flutter/material.dart';

import '../vs_tokens.dart';

/// Large serif text field with an ink underline — mirrors `VSAddInput`'s
/// main entry and `VSField`'s single-line email / password inputs.
class VsInputField extends StatelessWidget {
  const VsInputField({
    required this.controller,
    this.fontSize = 34,
    this.fontFamily = VsTokens.serif,
    this.autofocus = false,
    this.enabled = true,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.keyboardType,
    super.key,
  });

  final TextEditingController controller;
  final double fontSize;
  final String fontFamily;
  final bool autofocus;
  final bool enabled;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      cursorColor: VsTokens.accent,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: TextStyle(
        fontFamily: fontFamily,
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: VsTokens.ink,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: VsTokens.inkMute,
        ),
        isCollapsed: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 6),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: VsTokens.inkHair),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: VsTokens.ink),
        ),
      ),
    );
  }
}
