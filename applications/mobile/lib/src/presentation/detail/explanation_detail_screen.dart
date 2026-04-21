import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_bindings.dart';
import '../../domain/explanation/explanation_detail.dart';
import '../../domain/explanation/frequency_level.dart';
import '../../domain/explanation/pronunciation.dart';
import '../../domain/explanation/sense.dart';
import '../../domain/explanation/similar_expression.dart';
import '../../domain/explanation/sophistication_level.dart';
import '../../domain/identifier/identifier.dart';
import '../theme/vs_tokens.dart';
import '../theme/widgets/vs_chip.dart';
import '../theme/widgets/vs_illustration_panel.dart';
import '../theme/widgets/vs_section_label.dart';
import '../theme/widgets/vs_skeleton.dart';
import '../theme/widgets/vs_wordmark.dart';
import 'detail_layout_preference.dart';

/// Spec 013 canonical `ExplanationDetail` screen.
///
/// Visual reference: `screens.jsx` `VSDetailTab` / `VSDetailPage` /
/// `VSDetailCards`. Renders the full dictionary entry — pronunciation,
/// frequency / sophistication chips, multi-sense body (NUANCE /
/// SITUATION / EXAMPLES / COLLOCATIONS), similar expressions, etymology
/// and proficiency selector — driven by `detailLayoutProvider`
/// (managed from Settings).
class ExplanationDetailScreen extends ConsumerStatefulWidget {
  const ExplanationDetailScreen({required this.identifier, super.key});

  final ExplanationIdentifier identifier;

  @override
  ConsumerState<ExplanationDetailScreen> createState() =>
      _ExplanationDetailScreenState();
}

class _ExplanationDetailScreenState
    extends ConsumerState<ExplanationDetailScreen> {
  int _senseIdx = 0;
  int _imageIdx = 0;
  _ProficiencyOption _selectedProficiency = _ProficiencyOption.learning;

  @override
  Widget build(BuildContext context) {
    final detailAsync =
        ref.watch(explanationDetailFutureProvider(widget.identifier));
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
                  final senses = detail.senses;
                  final safeSenseIdx =
                      senses.isEmpty ? 0 : _senseIdx.clamp(0, senses.length - 1);
                  return ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      _DetailMeta(detail: detail),
                      _ImageCarousel(
                        seedBase: widget.identifier.value.length,
                        imageIdx: _imageIdx,
                        totalImages: 3,
                        senseLabel: senses.isEmpty
                            ? null
                            : senses[safeSenseIdx].label,
                        onSelect: (idx) => setState(() => _imageIdx = idx),
                        onRefresh: () => setState(
                          () => _imageIdx = (_imageIdx + 1) % 3,
                        ),
                      ),
                      if (senses.isNotEmpty)
                        switch (layout) {
                          DetailLayout.tab => _TabLayout(
                              senses: senses,
                              activeIdx: safeSenseIdx,
                              onSelect: (idx) =>
                                  setState(() => _senseIdx = idx),
                            ),
                          DetailLayout.page => _PageLayout(
                              senses: senses,
                              activeIdx: safeSenseIdx,
                              onSelect: (idx) =>
                                  setState(() => _senseIdx = idx),
                            ),
                          DetailLayout.cards => _CardsLayout(
                              senses: senses,
                              activeIdx: safeSenseIdx,
                              onSelect: (idx) =>
                                  setState(() => _senseIdx = idx),
                            ),
                        },
                      _DetailFooter(
                        similarities: detail.similarities,
                        etymology: detail.etymology,
                        selected: _selectedProficiency,
                        onSelect: (option) => setState(
                          () => _selectedProficiency = option,
                        ),
                      ),
                      const SizedBox(height: 32),
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
          const IconButton(
            key: Key('explanation-detail.bookmark'),
            onPressed: null,
            icon: Icon(Icons.star_border, size: 18),
            color: VsTokens.inkSoft,
            disabledColor: VsTokens.inkMute,
            tooltip: 'ブックマークは実装準備中です',
            splashRadius: 18,
          ),
        ],
      ),
    );
  }
}

class _DetailMeta extends StatelessWidget {
  const _DetailMeta({required this.detail});
  final CompletedExplanationDetail detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const VsSectionLabel('ENGLISH EXPRESSION'),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Flexible(
                child: Text(
                  detail.text,
                  key: const Key('explanation-detail.text'),
                  style: const TextStyle(
                    fontFamily: VsTokens.serif,
                    fontSize: 44,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                    color: VsTokens.ink,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const _PronunciationButton(),
            ],
          ),
          const SizedBox(height: 10),
          _PronunciationLine(pronunciation: detail.pronunciation),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: <Widget>[
              VsChip(
                key: const Key('explanation-detail.frequency-chip'),
                label: '頻度 · ${detail.frequency.labelJa}',
                tone: _frequencyTone(detail.frequency),
              ),
              VsChip(
                key: const Key('explanation-detail.sophistication-chip'),
                label: '難度 · ${detail.sophistication.labelJa}',
                outlined: true,
                color: VsTokens.inkSoft,
              ),
              VsChip(
                label: '${detail.senses.length} 義',
                tone: VsChipTone.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  VsChipTone _frequencyTone(FrequencyLevel level) {
    return switch (level) {
      FrequencyLevel.often => VsChipTone.accent,
      FrequencyLevel.sometimes => VsChipTone.neutral,
      FrequencyLevel.rarely => VsChipTone.neutral,
      FrequencyLevel.hardlyEver => VsChipTone.neutral,
    };
  }
}

class _PronunciationLine extends StatelessWidget {
  const _PronunciationLine({required this.pronunciation});
  final Pronunciation pronunciation;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: const TextStyle(
        fontFamily: VsTokens.mono,
        fontSize: 12,
        color: VsTokens.inkSoft,
        height: 1.4,
      ),
      child: Row(
        children: <Widget>[
          Text(
            pronunciation.weak,
            key: const Key('explanation-detail.pronunciation-weak'),
          ),
          const SizedBox(width: 8),
          const Text(
            '·',
            style: TextStyle(color: VsTokens.inkMute),
          ),
          const SizedBox(width: 8),
          Text(
            pronunciation.strong,
            key: const Key('explanation-detail.pronunciation-strong'),
          ),
        ],
      ),
    );
  }
}

class _PronunciationButton extends StatelessWidget {
  const _PronunciationButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: VsTokens.paperSoft,
      shape: const CircleBorder(
        side: BorderSide(color: VsTokens.inkHair, width: 0.5),
      ),
      child: InkWell(
        key: const Key('explanation-detail.pronounce'),
        customBorder: const CircleBorder(),
        onTap: () {
          final messenger = ScaffoldMessenger.maybeOf(context);
          messenger?.showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              duration: Duration(milliseconds: 900),
              content: Text('発音機能は spec 022 で実装予定です。'),
            ),
          );
        },
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Icon(Icons.mic_none, size: 16, color: VsTokens.inkSoft),
        ),
      ),
    );
  }
}

class _ImageCarousel extends StatelessWidget {
  const _ImageCarousel({
    required this.seedBase,
    required this.imageIdx,
    required this.totalImages,
    required this.senseLabel,
    required this.onSelect,
    required this.onRefresh,
  });

  final int seedBase;
  final int imageIdx;
  final int totalImages;
  final String? senseLabel;
  final ValueChanged<int> onSelect;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 220,
            child: PageView.builder(
              key: const Key('explanation-detail.image-pager'),
              controller: PageController(initialPage: imageIdx),
              itemCount: totalImages,
              onPageChanged: onSelect,
              itemBuilder: (_, index) {
                return Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(VsTokens.radiusLg),
                        border: Border.all(color: VsTokens.inkHair),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: VsIllustrationPanel(
                        seed: seedBase + index,
                        label: '視覚イメージ ${index + 1}',
                        height: 220,
                        borderRadius: VsTokens.radiusLg,
                      ),
                    ),
                    if (senseLabel != null)
                      Positioned(
                        left: 12,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: VsTokens.ink.withAlpha(210),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            senseLabel!,
                            style: const TextStyle(
                              fontFamily: VsTokens.sans,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: VsTokens.paper,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Material(
                        color: VsTokens.paper.withAlpha(220),
                        shape: const CircleBorder(
                          side:
                              BorderSide(color: VsTokens.inkHair, width: 0.5),
                        ),
                        child: InkWell(
                          key: const Key('explanation-detail.image-refresh'),
                          customBorder: const CircleBorder(),
                          onTap: onRefresh,
                          child: const SizedBox(
                            width: 32,
                            height: 32,
                            child: Icon(
                              Icons.refresh,
                              size: 16,
                              color: VsTokens.inkSoft,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              for (var i = 0; i < totalImages; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: GestureDetector(
                    onTap: () => onSelect(i),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: i == imageIdx ? 18 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == imageIdx
                            ? VsTokens.ink
                            : VsTokens.inkHair,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabLayout extends StatelessWidget {
  const _TabLayout({
    required this.senses,
    required this.activeIdx,
    required this.onSelect,
  });
  final List<Sense> senses;
  final int activeIdx;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: VsTokens.inkHair, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (var i = 0; i < senses.length; i++)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onSelect(i),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(0, 0, 18, 10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: i == activeIdx
                                  ? VsTokens.accent
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            _SenseBadge(
                              order: senses[i].order,
                              isActive: i == activeIdx,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              senses[i].label,
                              style: TextStyle(
                                fontFamily: VsTokens.sans,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: i == activeIdx
                                    ? VsTokens.ink
                                    : VsTokens.inkMute,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _SenseBody(sense: senses[activeIdx]),
        ],
      ),
    );
  }
}

class _PageLayout extends StatelessWidget {
  const _PageLayout({
    required this.senses,
    required this.activeIdx,
    required this.onSelect,
  });
  final List<Sense> senses;
  final int activeIdx;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final total = senses.length;
    final current = senses[activeIdx];
    final counter =
        'SENSE ${(activeIdx + 1).toString().padLeft(2, '0')} / ${total.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      counter,
                      style: const TextStyle(
                        fontFamily: VsTokens.mono,
                        fontSize: 10,
                        letterSpacing: 2,
                        color: VsTokens.inkMute,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      current.label,
                      style: const TextStyle(
                        fontFamily: VsTokens.serif,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: VsTokens.ink,
                      ),
                    ),
                  ],
                ),
              ),
              _PageArrow(
                icon: Icons.chevron_left,
                onTap: activeIdx == 0 ? null : () => onSelect(activeIdx - 1),
              ),
              const SizedBox(width: 8),
              _PageArrow(
                icon: Icons.chevron_right,
                onTap: activeIdx >= total - 1
                    ? null
                    : () => onSelect(activeIdx + 1),
                filled: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              for (var i = 0; i < total; i++)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onSelect(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Container(
                        height: 3,
                        color: i == activeIdx
                            ? VsTokens.ink
                            : VsTokens.inkHair,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _SenseBody(sense: current),
        ],
      ),
    );
  }
}

class _CardsLayout extends StatelessWidget {
  const _CardsLayout({
    required this.senses,
    required this.activeIdx,
    required this.onSelect,
  });
  final List<Sense> senses;
  final int activeIdx;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
            child: VsSectionLabel('SENSES · ${senses.length} 義'),
          ),
          for (var i = 0; i < senses.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SenseCard(
                sense: senses[i],
                expanded: i == activeIdx,
                onTap: () => onSelect(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _SenseCard extends StatelessWidget {
  const _SenseCard({
    required this.sense,
    required this.expanded,
    required this.onTap,
  });
  final Sense sense;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: VsTokens.paperSoft,
        border: Border.all(color: VsTokens.inkHair),
        borderRadius: BorderRadius.circular(VsTokens.radiusMd),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.fromLTRB(14, 12, 14, expanded ? 8 : 12),
              child: Row(
                children: <Widget>[
                  _SenseBadge(
                    order: sense.order,
                    isActive: expanded,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          sense.label,
                          style: const TextStyle(
                            fontFamily: VsTokens.serif,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: VsTokens.ink,
                          ),
                        ),
                        if (!expanded) ...<Widget>[
                          const SizedBox(height: 2),
                          Text(
                            sense.nuance,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: VsTokens.sans,
                              fontSize: 12,
                              color: VsTokens.inkMute,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: VsTokens.inkMute,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: _SenseBody(sense: sense),
            ),
        ],
      ),
    );
  }
}

class _SenseBody extends StatelessWidget {
  const _SenseBody({required this.sense});
  final Sense sense;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const VsSectionLabel('NUANCE'),
        const SizedBox(height: 6),
        Text(
          sense.nuance,
          key: const Key('explanation-detail.nuance'),
          style: const TextStyle(
            fontFamily: VsTokens.serif,
            fontSize: 16,
            height: 1.7,
            color: VsTokens.ink,
          ),
        ),
        const SizedBox(height: 14),
        const VsSectionLabel('SITUATION'),
        const SizedBox(height: 6),
        Text(
          sense.situation,
          key: const Key('explanation-detail.situation'),
          style: const TextStyle(
            fontFamily: VsTokens.sans,
            fontSize: 12,
            height: 1.7,
            color: VsTokens.inkSoft,
          ),
        ),
        if (sense.examples.isNotEmpty) ...<Widget>[
          const SizedBox(height: 18),
          const VsSectionLabel('EXAMPLES'),
          const SizedBox(height: 8),
          for (var i = 0; i < sense.examples.length; i++)
            _ExampleRow(
              example: sense.examples[i],
              isFirst: i == 0,
            ),
        ],
        if (sense.collocations.isNotEmpty) ...<Widget>[
          const SizedBox(height: 18),
          const VsSectionLabel('COLLOCATIONS'),
          const SizedBox(height: 8),
          for (final collocation in sense.collocations)
            _CollocationRow(collocation: collocation),
        ],
      ],
    );
  }
}

class _ExampleRow extends StatelessWidget {
  const _ExampleRow({required this.example, required this.isFirst});
  final SenseExample example;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            example.value,
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
          const SizedBox(height: 2),
          Text(
            example.meaning,
            style: const TextStyle(
              fontFamily: VsTokens.sans,
              fontSize: 12,
              height: 1.6,
              color: VsTokens.inkMute,
            ),
          ),
        ],
      ),
    );
  }
}

class _CollocationRow extends StatelessWidget {
  const _CollocationRow({required this.collocation});
  final Collocation collocation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Text(
              collocation.value,
              style: const TextStyle(
                fontFamily: VsTokens.mono,
                fontSize: 12,
                color: VsTokens.accentDeep,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              collocation.meaning,
              style: const TextStyle(
                fontFamily: VsTokens.sans,
                fontSize: 12,
                color: VsTokens.inkSoft,
              ),
            ),
          ),
        ],
      ),
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

class _DetailFooter extends StatelessWidget {
  const _DetailFooter({
    required this.similarities,
    required this.etymology,
    required this.selected,
    required this.onSelect,
  });

  final List<SimilarExpression> similarities;
  final String etymology;
  final _ProficiencyOption selected;
  final ValueChanged<_ProficiencyOption> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Divider(thickness: 0.5, height: 0.5),
          const SizedBox(height: 18),
          const VsSectionLabel('類似表現'),
          const SizedBox(height: 8),
          if (similarities.isEmpty)
            const Text(
              '類似表現は登録されていません。',
              style: TextStyle(
                fontFamily: VsTokens.sans,
                fontSize: 12,
                color: VsTokens.inkMute,
              ),
            )
          else
            for (final item in similarities)
              _SimilarExpressionRow(item: item),
          const SizedBox(height: 20),
          const VsSectionLabel('語源'),
          const SizedBox(height: 6),
          Text(
            etymology,
            key: const Key('explanation-detail.etymology'),
            style: const TextStyle(
              fontFamily: VsTokens.serif,
              fontSize: 13,
              fontStyle: FontStyle.italic,
              height: 1.6,
              color: VsTokens.inkSoft,
            ),
          ),
          const SizedBox(height: 20),
          const VsSectionLabel('習熟度'),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              for (final option in _ProficiencyOption.values)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: _ProficiencyButton(
                      option: option,
                      selected: selected == option,
                      onTap: () => onSelect(option),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SimilarExpressionRow extends StatelessWidget {
  const _SimilarExpressionRow({required this.item});
  final SimilarExpression item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: VsTokens.paperSoft,
        border: Border.all(color: VsTokens.inkHair),
        borderRadius: BorderRadius.circular(VsTokens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(
                item.value,
                key: const Key('explanation-detail.similarity-value'),
                style: const TextStyle(
                  fontFamily: VsTokens.serif,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: VsTokens.ink,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item.meaning,
                style: const TextStyle(
                  fontFamily: VsTokens.sans,
                  fontSize: 11,
                  color: VsTokens.inkMute,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            item.comparison,
            style: const TextStyle(
              fontFamily: VsTokens.sans,
              fontSize: 12,
              height: 1.6,
              color: VsTokens.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}

enum _ProficiencyOption { learning, learned, internalized, fluent }

extension on _ProficiencyOption {
  String get label {
    return switch (this) {
      _ProficiencyOption.learning => '学習中',
      _ProficiencyOption.learned => '習得',
      _ProficiencyOption.internalized => '内在化',
      _ProficiencyOption.fluent => '自在',
    };
  }

  Color get color {
    return switch (this) {
      _ProficiencyOption.learning => VsTokens.profLearning,
      _ProficiencyOption.learned => VsTokens.profLearned,
      _ProficiencyOption.internalized => VsTokens.profInternalized,
      _ProficiencyOption.fluent => VsTokens.profFluent,
    };
  }
}

class _ProficiencyButton extends StatelessWidget {
  const _ProficiencyButton({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _ProficiencyOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = option.color;
    return Material(
      color: selected ? accent : VsTokens.paperSoft,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(VsTokens.radiusMd),
        side: BorderSide(
          color: selected ? accent : VsTokens.inkHair,
          width: 0.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(VsTokens.radiusMd),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: selected ? VsTokens.paper : accent,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                option.label,
                style: TextStyle(
                  fontFamily: VsTokens.sans,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected ? VsTokens.paper : VsTokens.inkSoft,
                ),
              ),
            ],
          ),
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
