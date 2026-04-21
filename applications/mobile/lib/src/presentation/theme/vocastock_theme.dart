import 'package:flutter/material.dart';

import 'vs_tokens.dart';

/// Builds the [ThemeData] families used throughout the vocastock app.
///
/// Only the dictionary (paper + mincho + vermilion) direction is defined for
/// now; the playful variant is deferred.
@immutable
final class VocastockTheme {
  const VocastockTheme._();

  /// Dictionary-style light theme.
  static ThemeData dictionaryLight() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: VsTokens.accent,
      onPrimary: VsTokens.paper,
      primaryContainer: VsTokens.accentSoft,
      onPrimaryContainer: VsTokens.accentDeep,
      secondary: VsTokens.ink,
      onSecondary: VsTokens.paper,
      secondaryContainer: VsTokens.paperDeep,
      onSecondaryContainer: VsTokens.ink,
      tertiary: VsTokens.inkSoft,
      onTertiary: VsTokens.paper,
      error: VsTokens.err,
      onError: VsTokens.paper,
      surface: VsTokens.paper,
      onSurface: VsTokens.ink,
      surfaceContainer: VsTokens.paperSoft,
      surfaceContainerHighest: VsTokens.paperDeep,
      onSurfaceVariant: VsTokens.inkSoft,
      outline: VsTokens.inkHair,
      outlineVariant: VsTokens.inkHair,
    );

    final textTheme = _buildTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: VsTokens.paper,
      canvasColor: VsTokens.paper,
      dividerColor: VsTokens.inkHair,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: VsTokens.paper,
        surfaceTintColor: VsTokens.paper,
        foregroundColor: VsTokens.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleMedium,
      ),
      cardTheme: const CardThemeData(
        color: VsTokens.paperSoft,
        surfaceTintColor: VsTokens.paperSoft,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(VsTokens.radiusMd)),
          side: BorderSide(color: VsTokens.inkHair),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: VsTokens.inkHair,
        thickness: 0.5,
        space: 0.5,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: VsTokens.ink,
        foregroundColor: VsTokens.paper,
        elevation: 0,
        highlightElevation: 0,
        hoverElevation: 0,
        focusElevation: 0,
        shape: CircleBorder(),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: VsTokens.accent,
          foregroundColor: VsTokens.paper,
          disabledBackgroundColor: VsTokens.paperDeep,
          disabledForegroundColor: VsTokens.inkMute,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(VsTokens.radiusMd)),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: VsTokens.ink,
          side: const BorderSide(color: VsTokens.inkSoft),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(VsTokens.radiusMd)),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: VsTokens.accentDeep,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        labelStyle: textTheme.labelMedium?.copyWith(
          color: VsTokens.inkMute,
          letterSpacing: 1,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: VsTokens.inkMute),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: VsTokens.inkHair),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: VsTokens.ink),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: VsTokens.err),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: VsTokens.err, width: 1.5),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: VsTokens.inkSoft,
        textColor: VsTokens.ink,
        titleTextStyle: textTheme.titleSmall,
        subtitleTextStyle: textTheme.bodySmall?.copyWith(
          color: VsTokens.inkMute,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: VsTokens.ink,
        contentTextStyle:
            TextStyle(color: VsTokens.paper, fontFamily: VsTokens.sans),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: VsTokens.accent,
        linearTrackColor: VsTokens.paperDeep,
        circularTrackColor: VsTokens.paperDeep,
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    const serif = VsTokens.serif;
    const sans = VsTokens.sans;

    return const TextTheme(
      displayLarge: TextStyle(
        fontFamily: serif,
        fontSize: 44,
        fontWeight: FontWeight.w600,
        letterSpacing: -1,
        height: 1.1,
        color: VsTokens.ink,
      ),
      displayMedium: TextStyle(
        fontFamily: serif,
        fontSize: 34,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.8,
        height: 1.15,
        color: VsTokens.ink,
      ),
      displaySmall: TextStyle(
        fontFamily: serif,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.6,
        height: 1.2,
        color: VsTokens.ink,
      ),
      headlineLarge: TextStyle(
        fontFamily: serif,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        height: 1.25,
        color: VsTokens.ink,
      ),
      headlineMedium: TextStyle(
        fontFamily: serif,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        height: 1.3,
        color: VsTokens.ink,
      ),
      headlineSmall: TextStyle(
        fontFamily: serif,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: VsTokens.ink,
      ),
      titleLarge: TextStyle(
        fontFamily: serif,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: VsTokens.ink,
      ),
      titleMedium: TextStyle(
        fontFamily: serif,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: VsTokens.ink,
      ),
      titleSmall: TextStyle(
        fontFamily: sans,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: VsTokens.ink,
      ),
      bodyLarge: TextStyle(
        fontFamily: sans,
        fontSize: 15,
        height: 1.7,
        color: VsTokens.ink,
      ),
      bodyMedium: TextStyle(
        fontFamily: sans,
        fontSize: 13,
        height: 1.6,
        color: VsTokens.inkSoft,
      ),
      bodySmall: TextStyle(
        fontFamily: sans,
        fontSize: 12,
        height: 1.5,
        color: VsTokens.inkSoft,
      ),
      labelLarge: TextStyle(
        fontFamily: sans,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: VsTokens.ink,
      ),
      labelMedium: TextStyle(
        fontFamily: sans,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1,
        color: VsTokens.inkMute,
      ),
      labelSmall: TextStyle(
        fontFamily: sans,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        color: VsTokens.inkMute,
      ),
    );
  }
}
