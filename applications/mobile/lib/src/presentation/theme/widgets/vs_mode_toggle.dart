import 'package:flutter/material.dart';

import '../vs_tokens.dart';

/// Pill-shaped two-option toggle used by the login form to switch between
/// sign-in and sign-up modes (`screens.jsx` `VSLoginEmail` mode toggle).
class VsModeToggle<T> extends StatelessWidget {
  const VsModeToggle({
    required this.options,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final List<VsModeOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: VsTokens.paperSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: VsTokens.inkHair),
      ),
      child: Row(
        children: <Widget>[
          for (final option in options)
            Expanded(
              child: _ModeButton<T>(
                option: option,
                isActive: option.value == selected,
                onTap: () => onChanged(option.value),
              ),
            ),
        ],
      ),
    );
  }
}

@immutable
class VsModeOption<T> {
  const VsModeOption({required this.value, required this.label});
  final T value;
  final String label;
}

class _ModeButton<T> extends StatelessWidget {
  const _ModeButton({
    required this.option,
    required this.isActive,
    required this.onTap,
  });

  final VsModeOption<T> option;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? VsTokens.ink : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            option.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: VsTokens.sans,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? VsTokens.paper : VsTokens.inkSoft,
            ),
          ),
        ),
      ),
    );
  }
}
