import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_bindings.dart';
import '../../domain/status/explanation_generation_status.dart';
import '../../domain/status/image_generation_status.dart';
import '../../domain/vocabulary/vocabulary_expression_entry.dart';
import '../router/router.dart';
import '../theme/vs_tokens.dart';
import '../theme/widgets/vs_chip.dart';
import '../theme/widgets/vs_icon_circle.dart';
import '../theme/widgets/vs_illustration_panel.dart';
import '../theme/widgets/vs_pill_tabs.dart';
import '../theme/widgets/vs_spinner.dart';
import '../theme/widgets/vs_wordmark.dart';

/// Spec 013 canonical `VocabularyCatalog` screen.
///
/// Visual reference: `screens.jsx` `VSHome`. Wordmark header + search icon,
/// Mincho 30 title, learner sub-line, pill filter tabs, and paper-toned
/// entry cards with illustration thumbs and status chips. Completed
/// explanation / image bodies remain navigable via
/// `VocabularyExpressionDetail` (spec 013 source binding).
class VocabularyCatalogScreen extends ConsumerStatefulWidget {
  const VocabularyCatalogScreen({super.key});

  @override
  ConsumerState<VocabularyCatalogScreen> createState() =>
      _VocabularyCatalogScreenState();
}

enum _CatalogFilter { all, active, running, failed }

class _VocabularyCatalogScreenState
    extends ConsumerState<VocabularyCatalogScreen> {
  _CatalogFilter _filter = _CatalogFilter.all;

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(vocabularyCatalogStreamProvider);
    final catalog = catalogAsync.value ??
        VocabularyCatalog(const <VocabularyExpressionEntry>[]);
    final theme = Theme.of(context);

    final counts = _deriveCounts(catalog.entries);
    final shown = _applyFilter(catalog.entries, _filter);

    return Scaffold(
      backgroundColor: VsTokens.paper,
      floatingActionButton: FloatingActionButton(
        key: const Key('catalog.add'),
        onPressed: () => context.go(AppRoutes.registration),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const VsWordmark(size: 15),
                      VsIconCircle(
                        key: const Key('catalog.search'),
                        icon: Icons.search,
                        onTap: () => _showDeferredSearch(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text('単語帳', style: theme.textTheme.displaySmall),
                  const SizedBox(height: 4),
                  Text(
                    '登録 ${catalog.entries.length} 件',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: VsTokens.inkMute,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 0.5, height: 0.5),
            const SizedBox(height: 12),
            VsPillTabs<_CatalogFilter>(
              selected: _filter,
              onChanged: (value) => setState(() => _filter = value),
              tabs: <VsPillTab<_CatalogFilter>>[
                VsPillTab<_CatalogFilter>(
                  value: _CatalogFilter.all,
                  label: 'すべて',
                  count: counts[_CatalogFilter.all],
                ),
                VsPillTab<_CatalogFilter>(
                  value: _CatalogFilter.active,
                  label: '完了',
                  count: counts[_CatalogFilter.active],
                ),
                VsPillTab<_CatalogFilter>(
                  value: _CatalogFilter.running,
                  label: '生成中',
                  count: counts[_CatalogFilter.running],
                ),
                VsPillTab<_CatalogFilter>(
                  value: _CatalogFilter.failed,
                  label: '失敗',
                  count: counts[_CatalogFilter.failed],
                ),
              ],
            ),
            Expanded(
              child: catalog.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          '語彙がまだ登録されていません',
                          key: const Key('catalog.empty-placeholder'),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: VsTokens.inkMute,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      key: const Key('catalog.list'),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                      itemCount: shown.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (_, index) {
                        final entry = shown[index];
                        return _CatalogEntryCard(entry: entry);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeferredSearch(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        key: Key('catalog.search.deferred-notice'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 1400),
        content: Text('検索機能は今後のアップデートで提供予定です。'),
      ),
    );
  }

  static Map<_CatalogFilter, int> _deriveCounts(
    List<VocabularyExpressionEntry> entries,
  ) {
    var active = 0;
    var running = 0;
    var failed = 0;
    for (final entry in entries) {
      switch (entry.explanationStatus) {
        case ExplanationGenerationStatus.succeeded:
          active += 1;
        case ExplanationGenerationStatus.pending:
        case ExplanationGenerationStatus.running:
        case ExplanationGenerationStatus.retryScheduled:
          running += 1;
        case ExplanationGenerationStatus.timedOut:
        case ExplanationGenerationStatus.failedFinal:
        case ExplanationGenerationStatus.deadLettered:
          failed += 1;
      }
    }
    return <_CatalogFilter, int>{
      _CatalogFilter.all: entries.length,
      _CatalogFilter.active: active,
      _CatalogFilter.running: running,
      _CatalogFilter.failed: failed,
    };
  }

  static List<VocabularyExpressionEntry> _applyFilter(
    List<VocabularyExpressionEntry> entries,
    _CatalogFilter filter,
  ) {
    return switch (filter) {
      _CatalogFilter.all => entries,
      _CatalogFilter.active => entries
          .where(
            (e) => e.explanationStatus == ExplanationGenerationStatus.succeeded,
          )
          .toList(growable: false),
      _CatalogFilter.running => entries
          .where(
            (e) =>
                e.explanationStatus == ExplanationGenerationStatus.pending ||
                e.explanationStatus == ExplanationGenerationStatus.running ||
                e.explanationStatus ==
                    ExplanationGenerationStatus.retryScheduled,
          )
          .toList(growable: false),
      _CatalogFilter.failed => entries
          .where(
            (e) =>
                e.explanationStatus == ExplanationGenerationStatus.timedOut ||
                e.explanationStatus ==
                    ExplanationGenerationStatus.failedFinal ||
                e.explanationStatus == ExplanationGenerationStatus.deadLettered,
          )
          .toList(growable: false),
    };
  }
}

class _CatalogEntryCard extends StatelessWidget {
  const _CatalogEntryCard({required this.entry});

  final VocabularyExpressionEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = _deriveStatus(entry);
    return Material(
      color: VsTokens.paperSoft,
      borderRadius: BorderRadius.circular(VsTokens.radiusMd),
      child: InkWell(
        key: Key('catalog.entry.${entry.identifier.value}'),
        borderRadius: BorderRadius.circular(VsTokens.radiusMd),
        onTap: () => context.go(
          '${AppRoutes.vocabularyPrefix}/${entry.identifier.value}',
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(VsTokens.radiusMd),
            border: Border.all(color: VsTokens.inkHair),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _Thumbnail(entry: entry),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      entry.text,
                      style: theme.textTheme.headlineMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: <Widget>[
                        if (status.showSpinner) ...<Widget>[
                          const VsSpinner(size: 10),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            status.label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: status.isFailure
                                  ? VsTokens.err
                                  : VsTokens.inkMute,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: <Widget>[
                        VsChip(
                          label: _explanationLabel(entry.explanationStatus),
                          tone: _toneFor(entry.explanationStatus),
                        ),
                        if (entry.hasCompletedImage)
                          const VsChip(
                            label: '画像あり',
                            tone: VsChipTone.accent,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: VsTokens.inkMute,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.entry});
  final VocabularyExpressionEntry entry;

  @override
  Widget build(BuildContext context) {
    const size = VsTokens.thumbnailSize;
    if (entry.hasCompletedImage) {
      return SizedBox(
        width: size,
        height: size,
        child: VsIllustrationPanel(
          seed: entry.identifier.value.length,
          label: entry.text.length >= 2
              ? entry.text.substring(0, 2)
              : entry.text,
          height: size,
        ),
      );
    }

    Widget child;
    if (entry.imageStatus == ImageGenerationStatus.running ||
        entry.imageStatus == ImageGenerationStatus.retryScheduled) {
      child = const Center(child: VsSpinner(size: 14));
    } else if (entry.imageStatus == ImageGenerationStatus.failedFinal ||
        entry.imageStatus == ImageGenerationStatus.deadLettered) {
      child = const Center(
        child: Icon(Icons.close, size: 14, color: VsTokens.err),
      );
    } else {
      child = const Center(
        child: Icon(Icons.image_outlined, size: 18, color: VsTokens.inkMute),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: VsTokens.paperDeep,
        borderRadius: BorderRadius.circular(VsTokens.radiusSm),
      ),
      child: child,
    );
  }
}

class _EntryStatus {
  const _EntryStatus({
    required this.label,
    this.showSpinner = false,
    this.isFailure = false,
  });

  final String label;
  final bool showSpinner;
  final bool isFailure;
}

_EntryStatus _deriveStatus(VocabularyExpressionEntry entry) {
  switch (entry.explanationStatus) {
    case ExplanationGenerationStatus.pending:
      return const _EntryStatus(label: '解説を準備しています');
    case ExplanationGenerationStatus.running:
      return const _EntryStatus(
        label: '解説を生成しています',
        showSpinner: true,
      );
    case ExplanationGenerationStatus.retryScheduled:
      return const _EntryStatus(
        label: '再試行を待機しています',
        showSpinner: true,
      );
    case ExplanationGenerationStatus.timedOut:
      return const _EntryStatus(
        label: 'タイムアウトしました',
        isFailure: true,
      );
    case ExplanationGenerationStatus.succeeded:
      return const _EntryStatus(label: '解説があります');
    case ExplanationGenerationStatus.failedFinal:
    case ExplanationGenerationStatus.deadLettered:
      return const _EntryStatus(
        label: '生成に失敗しました · 再試行できます',
        isFailure: true,
      );
  }
}

String _explanationLabel(ExplanationGenerationStatus status) {
  return switch (status) {
    ExplanationGenerationStatus.pending => '待機',
    ExplanationGenerationStatus.running => '生成中',
    ExplanationGenerationStatus.retryScheduled => '再試行',
    ExplanationGenerationStatus.timedOut => 'タイムアウト',
    ExplanationGenerationStatus.succeeded => '完了',
    ExplanationGenerationStatus.failedFinal => '失敗',
    ExplanationGenerationStatus.deadLettered => '失敗',
  };
}

VsChipTone _toneFor(ExplanationGenerationStatus status) {
  return switch (status) {
    ExplanationGenerationStatus.succeeded => VsChipTone.ok,
    ExplanationGenerationStatus.running ||
    ExplanationGenerationStatus.retryScheduled ||
    ExplanationGenerationStatus.pending =>
      VsChipTone.accent,
    ExplanationGenerationStatus.failedFinal ||
    ExplanationGenerationStatus.deadLettered ||
    ExplanationGenerationStatus.timedOut =>
      VsChipTone.err,
  };
}
