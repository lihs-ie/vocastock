import 'package:flutter/material.dart';

import '../vs_tokens.dart';

/// Circular icon button in paperSoft — mirrors the search icon chrome used
/// in `screens.jsx` `VSHome` top-right.
class VsIconCircle extends StatelessWidget {
  const VsIconCircle({
    required this.icon,
    this.onTap,
    this.size = 32,
    this.iconSize = 16,
    this.background = VsTokens.paperSoft,
    this.foreground = VsTokens.inkSoft,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: iconSize, color: foreground),
        ),
      ),
    );
  }
}
