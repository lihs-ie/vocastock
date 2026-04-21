import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../vs_tokens.dart';

/// Striped paper panel mirroring the design bundle's `IllustrationPanel`.
///
/// Used as a placeholder for AI-generated imagery: diagonal stripes with a
/// centered serif label that hints at the content.
class VsIllustrationPanel extends StatelessWidget {
  const VsIllustrationPanel({
    required this.label,
    this.seed = 0,
    this.height = 180,
    this.borderRadius = VsTokens.radiusSm,
    super.key,
  });

  final String label;
  final int seed;
  final double height;
  final double borderRadius;

  static const List<Color> _backgrounds = <Color>[
    Color(0xFFF2E8D2),
    Color(0xFFEFE2D0),
    Color(0xFFF3E6CC),
    Color(0xFFD6E4E6),
    Color(0xFFEEDFD9),
    Color(0xFFDEE6D8),
  ];

  static const List<Color> _textColors = <Color>[
    Color(0xFF805236),
    Color(0xFF7A3F2B),
    Color(0xFF7F5B23),
    Color(0xFF2E5059),
    Color(0xFF7A3E34),
    Color(0xFF3E5E2E),
  ];

  @override
  Widget build(BuildContext context) {
    final index = seed.abs() % _backgrounds.length;
    final bg = _backgrounds[index];
    final fg = _textColors[index];
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned.fill(child: ColoredBox(color: bg)),
            Positioned.fill(
              child: CustomPaint(painter: _StripesPainter(fg.withAlpha(30))),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: VsTokens.serif,
                    fontSize: height < 80 ? 16 : 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    color: fg,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StripesPainter extends CustomPainter {
  const _StripesPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const spacing = 14.0;
    final diagonal =
        math.sqrt(size.width * size.width + size.height * size.height);
    canvas
      ..save()
      ..translate(size.width / 2, size.height / 2)
      ..rotate(35 * math.pi / 180);
    for (var x = -diagonal; x < diagonal; x += spacing) {
      canvas.drawLine(Offset(x, -diagonal), Offset(x, diagonal), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _StripesPainter oldDelegate) =>
      oldDelegate.color != color;
}
