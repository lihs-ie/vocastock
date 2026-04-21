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
import '../theme/widgets/vs_screen_scaffold.dart';
import '../theme/widgets/vs_spinner.dart';

/// Spec 013 canonical `VocabularyCatalog` screen.
///
/// Renders summary-only entries; completed explanation / image bodies are
/// navigated to via `VocabularyExpressionDetail` (Phase 4).
class VocabularyCatalogScreen extends ConsumerWidget {
  const VocabularyCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(vocabularyCatalogStreamProvider);
    final catalog = catalogAsync.value ??
        VocabularyCatalog(const <VocabularyExpressionEntry>[]);
    final theme = Theme.of(context);

    return VsScreenScaffold(
      eyebrow: 'VOCABULARY',
      title: '単語帳',
      caption: catalog.entries.isEmpty
          ? 'まだ登録されていません'
          : '登録 ${catalog.entries.length} 件',
      floatingActionButton: FloatingActionButton(
        key: const Key('catalog.add'),
        onPressed: () => context.go(AppRoutes.registration),
        child: const Icon(Icons.add),
      ),
      body: catalog.isEmpty
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              itemCount: catalog.entries.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final entry = catalog.entries[index];
                return _CatalogEntryCard(entry: entry);
              },
            ),
    );
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
    Widget child;
    if (entry.hasCompletedImage) {
      child = Center(
        child: Text(
          entry.text.length >= 2
              ? entry.text.substring(0, 2)
              : entry.text,
          style: const TextStyle(
            fontFamily: VsTokens.serif,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: VsTokens.accentDeep,
          ),
        ),
      );
    } else if (entry.imageStatus == ImageGenerationStatus.running ||
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
      width: VsTokens.thumbnailSize,
      height: VsTokens.thumbnailSize,
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
