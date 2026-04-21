import 'dart:ui';

import 'package:flutter/material.dart';

import '../vs_tokens.dart';

/// Bottom tab chrome mirroring `screens.jsx` `VSTabBar`.
///
/// Driven by the parent shell's current branch index. The shell owns the
/// selection state so tab switches only swap the body subtree — the tab
/// bar itself stays pinned across navigations.
class VsBottomTabBar extends StatelessWidget {
  const VsBottomTabBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<_TabDefinition> _tabs = <_TabDefinition>[
    _TabDefinition(
      label: '単語帳',
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book,
    ),
    _TabDefinition(
      label: '習熟',
      icon: Icons.layers_outlined,
      activeIcon: Icons.layers,
    ),
    _TabDefinition(
      label: 'プラン',
      icon: Icons.emoji_events_outlined,
      activeIcon: Icons.emoji_events,
    ),
    _TabDefinition(
      label: '設定',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Color(0xE0F6F1E7),
            border: Border(
              top: BorderSide(color: VsTokens.inkHair, width: 0.5),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              0,
              8,
              0,
              bottomInset > 0 ? bottomInset : 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                for (var index = 0; index < _tabs.length; index++)
                  _TabButton(
                    tab: _tabs[index],
                    isActive: index == currentIndex,
                    onTap: () => onTap(index),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

@immutable
class _TabDefinition {
  const _TabDefinition({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  final _TabDefinition tab;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? VsTokens.accent : VsTokens.inkMute;
    return Semantics(
      button: true,
      selected: isActive,
      label: tab.label,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                isActive ? tab.activeIcon : tab.icon,
                size: 22,
                color: color,
              ),
              const SizedBox(height: 2),
              Text(
                tab.label,
                style: TextStyle(
                  fontFamily: VsTokens.sans,
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
