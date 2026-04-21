import 'package:flutter/material.dart';

import '../vs_tokens.dart';
import 'vs_spinner.dart';

/// Visual state for a single row in the `VSAddGenerating` stages list.
enum VsStageState { pending, active, done }

/// One line of the generation progress list — icon (dot / spinner / check)
/// + label + optional sub-label; opacity drops for pending rows.
class VsStageStep extends StatelessWidget {
  const VsStageStep({
    required this.state,
    required this.label,
    this.sub,
    this.isLast = false,
    super.key,
  });

  final VsStageState state;
  final String label;
  final String? sub;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final opacity = state == VsStageState.pending ? 0.35 : 1.0;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isLast ? Colors.transparent : VsTokens.inkHair,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 20,
              height: 20,
              child: Center(child: _buildLeading()),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontSize: 13,
                    ),
                  ),
                  if (sub != null && state == VsStageState.active) ...<Widget>[
                    const SizedBox(height: 1),
                    Text(
                      sub!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: VsTokens.inkMute,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeading() {
    switch (state) {
      case VsStageState.done:
        return const Icon(Icons.check, size: 16, color: VsTokens.ok);
      case VsStageState.active:
        return const VsSpinner(size: 14);
      case VsStageState.pending:
        return Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: VsTokens.inkHair,
            shape: BoxShape.circle,
          ),
        );
    }
  }
}
