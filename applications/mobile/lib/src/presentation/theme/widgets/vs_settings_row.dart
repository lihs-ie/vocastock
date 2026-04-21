import 'package:flutter/material.dart';

import '../vs_tokens.dart';

/// Row used by `screens.jsx` `VSSettings` — icon box on the left, label +
/// optional sub on the right, and a trailing chevron. Sibling rows share a
/// hairline divider handled by the caller through [isLast].
class VsSettingsRow extends StatelessWidget {
  const VsSettingsRow({
    required this.icon,
    required this.label,
    this.sub,
    this.onTap,
    this.isLast = false,
    this.trailing,
    super.key,
  });

  final IconData icon;
  final String label;
  final String? sub;
  final VoidCallback? onTap;
  final bool isLast;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isLast ? Colors.transparent : VsTokens.inkHair,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: VsTokens.paperDeep,
                borderRadius: BorderRadius.circular(VsTokens.radiusSm),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 15, color: VsTokens.inkSoft),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: theme.textTheme.titleSmall,
                  ),
                  if (sub != null) ...<Widget>[
                    const SizedBox(height: 1),
                    Text(
                      sub!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: VsTokens.inkMute,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else
              const Icon(
                Icons.chevron_right,
                size: 12,
                color: VsTokens.inkMute,
              ),
          ],
        ),
      ),
    );
  }
}
