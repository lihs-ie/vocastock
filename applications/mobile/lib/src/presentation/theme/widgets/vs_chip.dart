import 'package:flutter/material.dart';

import '../vs_tokens.dart';

/// Semantic tone palette for [VsChip].
enum VsChipTone { neutral, accent, ok, warn, err, dark }

class _VsChipColors {
  const _VsChipColors({required this.background, required this.foreground});
  final Color background;
  final Color foreground;
}

_VsChipColors _tonePalette(VsChipTone tone) {
  switch (tone) {
    case VsChipTone.neutral:
      return const _VsChipColors(
        background: VsTokens.paperDeep,
        foreground: VsTokens.inkSoft,
      );
    case VsChipTone.accent:
      return const _VsChipColors(
        background: VsTokens.accentSoft,
        foreground: VsTokens.accentDeep,
      );
    case VsChipTone.ok:
      return const _VsChipColors(
        background: Color(0xFFE6EEDF),
        foreground: Color(0xFF3E5A37),
      );
    case VsChipTone.warn:
      return const _VsChipColors(
        background: Color(0xFFF2E8D4),
        foreground: Color(0xFF6E531C),
      );
    case VsChipTone.err:
      return const _VsChipColors(
        background: Color(0xFFF2DDD8),
        foreground: Color(0xFF6E322A),
      );
    case VsChipTone.dark:
      return const _VsChipColors(
        background: VsTokens.ink,
        foreground: VsTokens.paper,
      );
  }
}

/// Pill label mirroring the handoff bundle's `VSChip`.
///
/// Supports an optional leading [icon] (sized to 12 px by default) and an
/// [outlined] mode that replaces the tone background with a transparent
/// fill and a 0.8 px border in the tone foreground.
class VsChip extends StatelessWidget {
  const VsChip({
    required this.label,
    this.tone = VsChipTone.neutral,
    this.icon,
    this.outlined = false,
    this.color,
    super.key,
  });

  final String label;
  final VsChipTone tone;
  final Widget? icon;

  /// Render as an outlined pill with transparent fill. Uses [color] if
  /// provided, otherwise the tone's foreground.
  final bool outlined;

  /// Overrides the resolved foreground (useful for proficiency chips where
  /// the color comes from `VsTokens.prof*`).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final palette = _tonePalette(tone);
    final foreground = color ?? palette.foreground;
    final background = outlined ? Colors.transparent : palette.background;
    final decoration = BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(999),
      border: outlined ? Border.all(color: foreground, width: 0.8) : null,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: decoration,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            IconTheme(
              data: IconThemeData(color: foreground, size: 12),
              child: icon!,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: VsTokens.sans,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
              height: 1.6,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

/// Deprecated wrapper retained for source-level compatibility; delegates to
/// `VsChip(outlined: true, color: color)`.
@Deprecated('Use VsChip(outlined: true, color: ...) instead.')
class VsOutlinedChip extends StatelessWidget {
  @Deprecated('Use VsChip(outlined: true, color: ...) instead.')
  const VsOutlinedChip({
    required this.label,
    required this.color,
    super.key,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return VsChip(label: label, outlined: true, color: color);
  }
}
