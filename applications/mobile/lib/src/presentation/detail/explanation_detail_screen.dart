import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_bindings.dart';
import '../../domain/identifier/identifier.dart';
import '../theme/vs_tokens.dart';
import '../theme/widgets/vs_section_label.dart';
import '../theme/widgets/vs_skeleton.dart';
import '../theme/widgets/vs_wordmark.dart';

/// Spec 013 canonical `ExplanationDetail` screen.
///
/// Visual reference: `screens.jsx` `VSDetail` sense body. The completed
/// explanation payload is rendered as a dictionary-style page: a Mincho
/// body paragraph and hairline-separated example sentences in serif italic.
/// When the reader returns null the screen pops back without flashing
/// provisional content (spec 013 generation-result-visibility).
class ExplanationDetailScreen extends ConsumerWidget {
  const ExplanationDetailScreen({required this.identifier, super.key});

  final ExplanationIdentifier identifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(explanationDetailFutureProvider(identifier));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: VsTokens.paper,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _ExplanationHeader(onBack: () => context.pop()),
            const Divider(thickness: 0.5, height: 0.5),
            Expanded(
              child: detailAsync.when(
                data: (detail) {
                  if (detail == null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (context.mounted) context.pop();
                    });
                    return const SizedBox.shrink();
                  }
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                    children: <Widget>[
                      Text(
                        '解説',
                        style: theme.textTheme.displaySmall,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        detail.body,
                        key: const Key('explanation-detail.body'),
                        style: const TextStyle(
                          fontFamily: VsTokens.serif,
                          fontSize: 17,
                          height: 1.8,
                          color: VsTokens.ink,
                        ),
                      ),
                      if (detail.exampleSentences.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 28),
                        const Divider(thickness: 0.5, height: 0.5),
                        const SizedBox(height: 16),
                        const VsSectionLabel('EXAMPLES'),
                        const SizedBox(height: 10),
                        for (var i = 0;
                            i < detail.exampleSentences.length;
                            i++)
                          _ExampleRow(
                            sentence: detail.exampleSentences[i],
                            isFirst: i == 0,
                          ),
                      ],
                    ],
                  );
                },
                loading: () => const _LoadingBody(),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: VsTokens.accentSoft,
                        borderRadius: BorderRadius.circular(VsTokens.radiusMd),
                      ),
                      child: Text(
                        'エラーが発生しました: $error',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: VsTokens.err,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExplanationHeader extends StatelessWidget {
  const _ExplanationHeader({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.chevron_left, size: 18),
            label: const Text('戻る'),
            style: TextButton.styleFrom(
              foregroundColor: VsTokens.inkSoft,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              textStyle: const TextStyle(
                fontFamily: VsTokens.sans,
                fontSize: 14,
              ),
            ),
          ),
          const VsWordmark(size: 13),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.star_border,
              size: 18,
              color: VsTokens.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleRow extends StatelessWidget {
  const _ExampleRow({required this.sentence, required this.isFirst});
  final String sentence;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isFirst ? VsTokens.inkHair : Colors.transparent,
            width: 0.5,
          ),
          bottom: const BorderSide(color: VsTokens.inkHair, width: 0.5),
        ),
      ),
      child: Text(
        sentence,
        key: const Key('explanation-detail.example'),
        style: const TextStyle(
          fontFamily: VsTokens.serif,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          fontStyle: FontStyle.italic,
          height: 1.5,
          color: VsTokens.ink,
        ),
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      key: Key('explanation-detail.loading'),
      padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          VsSkeleton(height: 28, width: 120),
          SizedBox(height: 24),
          VsSkeleton(),
          SizedBox(height: 6),
          VsSkeleton(),
          SizedBox(height: 6),
          VsSkeleton(width: 240),
        ],
      ),
    );
  }
}
