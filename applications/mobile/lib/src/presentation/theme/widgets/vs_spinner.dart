import 'package:flutter/material.dart';

import '../vs_tokens.dart';

/// Thin vermilion spinner — the only non-static motion affordance
/// used across the app while a generation job is running.
class VsSpinner extends StatelessWidget {
  const VsSpinner({this.size = 16, this.color = VsTokens.accent, super.key});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 1.5,
        valueColor: AlwaysStoppedAnimation<Color>(color),
        backgroundColor: VsTokens.inkHair,
      ),
    );
  }
}
