import 'package:flutter/material.dart';

import '../vs_tokens.dart';

/// Uppercase eyebrow / section label: sans 11 w500 inkMute, letter-spacing 1.
///
/// Mirrors the `label` style used throughout `screens.jsx` for
/// "ENGLISH EXPRESSION", "EXAMPLES", "NUANCE" etc.
class VsSectionLabel extends StatelessWidget {
  const VsSectionLabel(
    this.text, {
    this.color = VsTokens.inkMute,
    this.letterSpacing = 1,
    super.key,
  });

  final String text;
  final Color color;
  final double letterSpacing;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: VsTokens.sans,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: letterSpacing,
        color: color,
      ),
    );
  }
}
