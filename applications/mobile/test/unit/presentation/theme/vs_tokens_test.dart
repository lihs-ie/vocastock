import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/presentation/theme/vs_tokens.dart';

void main() {
  group('VsTokens', () {
    test('paper family keeps warm low-chroma hues', () {
      expect(VsTokens.paper, const Color(0xFFF6F1E7));
      expect(VsTokens.paperSoft, const Color(0xFFFAF6EC));
      expect(VsTokens.paperDeep, const Color(0xFFEBE3D3));
    });

    test('ink family anchors the text scale', () {
      expect(VsTokens.ink, const Color(0xFF2A241D));
      expect(VsTokens.inkSoft, const Color(0xFF5A4F42));
      expect(VsTokens.inkMute, const Color(0xFF8A7F6E));
      expect((VsTokens.inkHair.a * 255).round(), 0x14);
    });

    test('accent family expresses vermilion', () {
      expect(VsTokens.accent, const Color(0xFFB4613F));
      expect(VsTokens.accentDeep, const Color(0xFF8A4A30));
      expect(VsTokens.accentSoft, const Color(0xFFF0E0D6));
    });

    test('proficiency palette stages from warm to cool', () {
      expect(VsTokens.profLearning, const Color(0xFFB87333));
      expect(VsTokens.profLearned, const Color(0xFF6A7A3E));
      expect(VsTokens.profInternalized, const Color(0xFF3E6A5A));
      expect(VsTokens.profFluent, const Color(0xFF4A3E6A));
    });

    test('typography families name Japanese-friendly faces', () {
      expect(VsTokens.serif.contains('Hiragino Mincho'), isTrue);
      expect(VsTokens.sans.contains('Hiragino Sans'), isTrue);
      expect(VsTokens.mono.contains('SF Mono'), isTrue);
    });

    test('radius scale matches handoff bundle (4/8/14/20)', () {
      expect(VsTokens.radiusSm, 4);
      expect(VsTokens.radiusMd, 8);
      expect(VsTokens.radiusLg, 14);
      expect(VsTokens.radiusXl, 20);
    });

    test('motion durations are finite', () {
      expect(VsTokens.shimmerDuration.inMilliseconds, 1600);
      expect(VsTokens.fadeInDuration.inMilliseconds, 200);
      expect(VsTokens.spinnerDuration.inMilliseconds, 900);
    });
  });
}
