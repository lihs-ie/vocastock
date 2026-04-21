import 'package:flutter/material.dart';

import '../vs_tokens.dart';

/// Hairline progress bar — paperDeep track, vermilion fill.
class VsProgress extends StatelessWidget {
  const VsProgress({
    required this.value,
    this.color = VsTokens.accent,
    this.height = 3,
    super.key,
  });

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Stack(
        children: <Widget>[
          Container(height: height, color: VsTokens.paperDeep),
          FractionallySizedBox(
            widthFactor: clamped,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              height: height,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
