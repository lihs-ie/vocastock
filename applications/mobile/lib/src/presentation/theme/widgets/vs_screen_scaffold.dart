import 'package:flutter/material.dart';

import '../vs_tokens.dart';
import 'vs_wordmark.dart';

/// Paper-toned Scaffold replacement with a dictionary-style header.
///
/// Renders:
///   - Top safe area strip carrying the wordmark and optional trailing slot
///   - Mincho serif title (optional eyebrow) and caption line
///   - A hairline divider separating header from body
class VsScreenScaffold extends StatelessWidget {
  const VsScreenScaffold({
    required this.title,
    required this.body,
    this.eyebrow,
    this.caption,
    this.trailing,
    this.leading,
    this.showWordmark = true,
    this.floatingActionButton,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 12),
    super.key,
  });

  final String title;
  final Widget body;
  final String? eyebrow;
  final String? caption;
  final Widget? trailing;
  final Widget? leading;
  final bool showWordmark;
  final Widget? floatingActionButton;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: VsTokens.paper,
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          if (leading != null) ...<Widget>[
                            leading!,
                            const SizedBox(width: 8),
                          ],
                          if (showWordmark) const VsWordmark(size: 15),
                        ],
                      ),
                      ?trailing,
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (eyebrow != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        eyebrow!,
                        style: textTheme.labelMedium?.copyWith(
                          color: VsTokens.inkMute,
                        ),
                      ),
                    ),
                  Text(
                    title,
                    style: textTheme.displaySmall,
                  ),
                  if (caption != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        caption!,
                        style: textTheme.bodySmall?.copyWith(
                          color: VsTokens.inkMute,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 0.5, thickness: 0.5),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
