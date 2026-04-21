import 'package:flutter/material.dart';

import '../vs_tokens.dart';

/// Single entry used by [VsPillTabs].
@immutable
class VsPillTab<T> {
  const VsPillTab({required this.value, required this.label, this.count});

  final T value;
  final String label;
  final int? count;
}

/// Pill-shaped horizontal tab control mirroring `screens.jsx` `VSHome` filter
/// pills: active pill is filled ink, inactive is transparent.
class VsPillTabs<T> extends StatelessWidget {
  const VsPillTabs({
    required this.tabs,
    required this.selected,
    required this.onChanged,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    super.key,
  });

  final List<VsPillTab<T>> tabs;
  final T selected;
  final ValueChanged<T> onChanged;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: <Widget>[
          for (final tab in tabs)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: _PillButton<T>(
                tab: tab,
                isActive: tab.value == selected,
                onTap: () => onChanged(tab.value),
              ),
            ),
        ],
      ),
    );
  }
}

class _PillButton<T> extends StatelessWidget {
  const _PillButton({
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  final VsPillTab<T> tab;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = isActive ? VsTokens.ink : Colors.transparent;
    final foreground = isActive ? VsTokens.paper : VsTokens.inkSoft;
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                tab.label,
                style: TextStyle(
                  fontFamily: VsTokens.sans,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: foreground,
                ),
              ),
              if (tab.count != null) ...<Widget>[
                const SizedBox(width: 3),
                Opacity(
                  opacity: 0.6,
                  child: Text(
                    '${tab.count}',
                    style: TextStyle(
                      fontFamily: VsTokens.sans,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: foreground,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
