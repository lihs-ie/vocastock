import 'package:flutter/material.dart';

import '../vs_tokens.dart';

/// Brand wordmark — `vocastock·` with the dot in accent vermilion.
class VsWordmark extends StatelessWidget {
  const VsWordmark({this.size = 14, this.color = VsTokens.ink, super.key});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: VsTokens.serif,
          fontSize: size,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          fontStyle: FontStyle.italic,
          color: color,
        ),
        children: const <InlineSpan>[
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
    );
  }
}
