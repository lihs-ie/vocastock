import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/presentation/theme/vocastock_theme.dart';
import 'package:vocastock_mobile/src/presentation/theme/vs_tokens.dart';

void main() {
  group('VocastockTheme.dictionaryLight', () {
    final theme = VocastockTheme.dictionaryLight();

    test('uses Material 3 surfaces painted with paper tones', () {
      expect(theme.useMaterial3, isTrue);
      expect(theme.scaffoldBackgroundColor, VsTokens.paper);
      expect(theme.colorScheme.surface, VsTokens.paper);
      expect(theme.colorScheme.surfaceContainer, VsTokens.paperSoft);
    });

    test('primary is vermilion accent', () {
      expect(theme.colorScheme.primary, VsTokens.accent);
      expect(theme.colorScheme.onPrimary, VsTokens.paper);
      expect(theme.colorScheme.primaryContainer, VsTokens.accentSoft);
    });

    test('headline typography uses the serif family', () {
      expect(
        theme.textTheme.displayMedium?.fontFamily,
        VsTokens.serif,
      );
      expect(
        theme.textTheme.headlineMedium?.fontWeight,
        FontWeight.w600,
      );
    });

    test('body typography uses the sans family', () {
      expect(theme.textTheme.bodyMedium?.fontFamily, VsTokens.sans);
      expect(theme.textTheme.labelLarge?.fontFamily, VsTokens.sans);
    });

    test('card theme draws a hairline outline on paperSoft', () {
      final card = theme.cardTheme;
      expect(card.color, VsTokens.paperSoft);
      expect(card.elevation, 0);
      final shape = card.shape;
      expect(shape, isA<RoundedRectangleBorder>());
    });

    test('FAB is ink with paper foreground', () {
      final fab = theme.floatingActionButtonTheme;
      expect(fab.backgroundColor, VsTokens.ink);
      expect(fab.foregroundColor, VsTokens.paper);
      expect(fab.elevation, 0);
    });

    test('divider theme is hairline inkHair 0.5 px', () {
      expect(theme.dividerTheme.color, VsTokens.inkHair);
      expect(theme.dividerTheme.thickness, 0.5);
    });

    test('progress indicator uses accent with paperDeep track', () {
      final progress = theme.progressIndicatorTheme;
      expect(progress.color, VsTokens.accent);
      expect(progress.linearTrackColor, VsTokens.paperDeep);
    });
  });
}
