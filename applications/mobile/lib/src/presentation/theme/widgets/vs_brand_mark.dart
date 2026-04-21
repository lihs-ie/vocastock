import 'package:flutter/material.dart';

import '../vs_tokens.dart';

/// Brand glyph in paperSoft circle with a serif "V" stroke and an accent
/// dot at the lower-right — mirrors `VSLoginWelcome`'s hero brand mark.
class VsBrandMark extends StatelessWidget {
  const VsBrandMark({this.size = 72, this.accentDotSize = 10, super.key});

  final double size;
  final double accentDotSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: <Widget>[
          DecoratedBox(
            decoration: const BoxDecoration(
              color: VsTokens.paperSoft,
              shape: BoxShape.circle,
            ),
            child: CustomPaint(
              size: Size(size, size),
              painter: const _VGlyphPainter(),
            ),
          ),
          Positioned(
            right: size * 0.14,
            bottom: size * 0.14,
            child: Container(
              width: accentDotSize,
              height: accentDotSize,
              decoration: const BoxDecoration(
                color: VsTokens.accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VGlyphPainter extends CustomPainter {
  const _VGlyphPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = VsTokens.ink
      ..strokeWidth = size.width * 0.07
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.28, size.height * 0.32)
      ..lineTo(size.width * 0.5, size.height * 0.68)
      ..lineTo(size.width * 0.72, size.height * 0.32);

    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _VGlyphPainter oldDelegate) => false;
}
