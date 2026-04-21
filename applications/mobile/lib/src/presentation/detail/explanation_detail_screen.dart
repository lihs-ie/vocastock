import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_bindings.dart';
import '../../domain/explanation/explanation_detail.dart';
import '../../domain/identifier/identifier.dart';
import '../theme/vs_tokens.dart';
import '../theme/widgets/vs_section_label.dart';
import '../theme/widgets/vs_skeleton.dart';
import '../theme/widgets/vs_wordmark.dart';
import 'detail_layout_preference.dart';

/// Spec 013 canonical `ExplanationDetail` screen.
///
/// Visual reference: `screens.jsx` `VSDetail`. The body can be rendered
/// in three layout variants (Tab / Page / Cards) driven by
/// `detailLayoutProvider`; the selection lives in Settings. With
/// `CompletedExplanationDetail` currently carrying a single body and
/// example list the layouts operate on a single synthetic sense — the
/// structure is ready for spec 017/021 to populate sense[] without
/// further churn.
class ExplanationDetailScreen extends ConsumerWidget {
  const ExplanationDetailScreen({required this.identifier, super.key});

  final ExplanationIdentifier identifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(explanationDetailFutureProvider(identifier));
    final layout = ref.watch(detailLayoutProvider);
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
                  return switch (layout) {
                    DetailLayout.tab => _TabLayout(detail: detail),
                    DetailLayout.page => _PageLayout(detail: detail),
                    DetailLayout.cards => _CardsLayout(detail: detail),
                  };
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

class _TabLayout extends StatelessWidget {
  const _TabLayout({required this.detail});
  final CompletedExplanationDetail detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      children: <Widget>[
        Text('解説', style: theme.textTheme.displaySmall),
        const SizedBox(height: 16),
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: VsTokens.inkHair, width: 0.5),
            ),
          ),
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(bottom: 10),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: VsTokens.accent, width: 2),
                  ),
                ),
                child: const Row(
                  children: <Widget>[
                    _SenseBadge(order: 1, isActive: true),
                    SizedBox(width: 6),
                    Text(
                      'Sense 1',
                      style: TextStyle(
                        fontFamily: VsTokens.sans,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: VsTokens.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _ExplanationBody(detail: detail),
        const SizedBox(height: 24),
        const _DeferredFooter(),
      ],
    );
  }
}

class _PageLayout extends StatelessWidget {
  const _PageLayout({required this.detail});
  final CompletedExplanationDetail detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'SENSE 01 / 01',
                    style: TextStyle(
                      fontFamily: VsTokens.mono,
                      fontSize: 10,
                      letterSpacing: 2,
                      color: VsTokens.inkMute,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '「解説」',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            const _PageArrow(
              icon: Icons.chevron_left,
              onTap: null,
            ),
            const SizedBox(width: 8),
            const _PageArrow(
              icon: Icons.chevron_right,
              onTap: null,
              filled: true,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: Container(
                height: 3,
                color: VsTokens.ink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _ExplanationBody(detail: detail),
        const SizedBox(height: 24),
        const _DeferredFooter(),
      ],
    );
  }
}

class _CardsLayout extends StatelessWidget {
  const _CardsLayout({required this.detail});
  final CompletedExplanationDetail detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
          child: Text(
            '解説',
            style: theme.textTheme.displaySmall,
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(8, 0, 8, 12),
          child: VsSectionLabel('Senses · 1 義'),
        ),
        Container(
          decoration: BoxDecoration(
            color: VsTokens.paperSoft,
            border: Border.all(color: VsTokens.inkHair),
            borderRadius: BorderRadius.circular(VsTokens.radiusMd),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(
                  children: <Widget>[
                    _SenseBadge(order: 1, isActive: true, size: 24),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '「解説」',
                        style: TextStyle(
                          fontFamily: VsTokens.serif,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: VsTokens.ink,
                        ),
                      ),
                    ),
                    Icon(Icons.expand_less, size: 16, color: VsTokens.inkMute),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _ExplanationBody(detail: detail),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: _DeferredFooter(),
        ),
      ],
    );
  }
}

class _ExplanationBody extends StatelessWidget {
  const _ExplanationBody({required this.detail});
  final CompletedExplanationDetail detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const VsSectionLabel('NUANCE'),
        const SizedBox(height: 6),
        Text(
          detail.body,
          key: const Key('explanation-detail.body'),
          style: const TextStyle(
            fontFamily: VsTokens.serif,
            fontSize: 16,
            height: 1.7,
            color: VsTokens.ink,
          ),
        ),
        if (detail.exampleSentences.isNotEmpty) ...<Widget>[
          const SizedBox(height: 20),
          const VsSectionLabel('EXAMPLES'),
          const SizedBox(height: 10),
          for (var i = 0; i < detail.exampleSentences.length; i++)
            _ExampleRow(
              sentence: detail.exampleSentences[i],
              isFirst: i == 0,
            ),
        ],
      ],
    );
  }
}

class _SenseBadge extends StatelessWidget {
  const _SenseBadge({
    required this.order,
    required this.isActive,
    this.size = 18,
  });

  final int order;
  final bool isActive;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isActive ? VsTokens.ink : VsTokens.paperDeep,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      alignment: Alignment.center,
      child: Text(
        '$order',
        style: TextStyle(
          fontFamily: VsTokens.sans,
          fontSize: size < 20 ? 10 : 11,
          fontWeight: FontWeight.w600,
          color: isActive ? VsTokens.paper : VsTokens.inkSoft,
        ),
      ),
    );
  }
}

class _PageArrow extends StatelessWidget {
  const _PageArrow({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final background = filled ? VsTokens.ink : VsTokens.paperSoft;
    final foreground = filled ? VsTokens.paper : VsTokens.inkSoft;
    return Opacity(
      opacity: onTap == null ? 0.3 : 1,
      child: Material(
        color: background,
        shape: CircleBorder(
          side: filled
              ? BorderSide.none
              : const BorderSide(color: VsTokens.inkHair, width: 0.5),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(icon, size: 18, color: foreground),
          ),
        ),
      ),
    );
  }
}

class _DeferredFooter extends StatelessWidget {
  const _DeferredFooter();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Divider(thickness: 0.5, height: 0.5),
        const SizedBox(height: 16),
        const VsSectionLabel('類似表現 · 語源 · 習熟度'),
        const SizedBox(height: 6),
        Text(
          'spec 017 / 021 で拡張予定のセクションです。',
          style: theme.textTheme.bodySmall?.copyWith(
            color: VsTokens.inkMute,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
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
