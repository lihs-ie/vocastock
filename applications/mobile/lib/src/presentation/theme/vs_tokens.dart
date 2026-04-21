import 'package:flutter/material.dart';

/// Dictionary-style design tokens for the vocastock Flutter client.
///
/// Mirrors the handoff bundle `tokens.jsx`: paper-toned surfaces, ink text,
/// a single vermilion accent, and typography anchored on Japanese serif faces.
@immutable
final class VsTokens {
  const VsTokens._();

  static const Color paper = Color(0xFFF6F1E7);
  static const Color paperSoft = Color(0xFFFAF6EC);
  static const Color paperDeep = Color(0xFFEBE3D3);

  static const Color ink = Color(0xFF2A241D);
  static const Color inkSoft = Color(0xFF5A4F42);
  static const Color inkMute = Color(0xFF8A7F6E);
  static const Color inkHair = Color(0x142A241D);

  static const Color accent = Color(0xFFB4613F);
  static const Color accentDeep = Color(0xFF8A4A30);
  static const Color accentSoft = Color(0xFFF0E0D6);

  static const Color ok = Color(0xFF5A8055);
  static const Color warn = Color(0xFFA57F3A);
  static const Color err = Color(0xFFA44A3F);

  static const Color profLearning = Color(0xFFB87333);
  static const Color profLearned = Color(0xFF6A7A3E);
  static const Color profInternalized = Color(0xFF3E6A5A);
  static const Color profFluent = Color(0xFF4A3E6A);

  static const String serif =
      '"Hiragino Mincho ProN", "Yu Mincho", "Times New Roman", serif';
  static const String sans =
      '"Hiragino Sans", "Yu Gothic", "Helvetica Neue", system-ui, sans-serif';
  static const String mono = 'ui-monospace, "SF Mono", Menlo, monospace';

  static const double radiusSm = 4;
  static const double radiusMd = 8;
  static const double radiusLg = 14;
  static const double radiusXl = 20;

  static const Duration shimmerDuration = Duration(milliseconds: 1600);
  static const Duration fadeInDuration = Duration(milliseconds: 200);
  static const Duration spinnerDuration = Duration(milliseconds: 900);

  static const double fabSize = 56;
  static const double thumbnailSize = 56;
}
