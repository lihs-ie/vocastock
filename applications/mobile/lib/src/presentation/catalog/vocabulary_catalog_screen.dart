import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_bindings.dart';
import '../../domain/status/explanation_generation_status.dart';
import '../../domain/vocabulary/vocabulary_expression_entry.dart';
import '../router/router.dart';

/// Spec 013 canonical `VocabularyCatalog` screen.
///
/// Renders summary-only entries; completed explanation / image bodies are
/// navigated to via `VocabularyExpressionDetail` (Phase 4).
class VocabularyCatalogScreen extends ConsumerWidget {
  const VocabularyCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(vocabularyCatalogStreamProvider);
    final catalog = catalogAsync.value ?? VocabularyCatalog(const []);

    return Scaffold(
      appBar: AppBar(title: const Text('語彙カタログ')),
      floatingActionButton: FloatingActionButton(
        key: const Key('catalog.add'),
        onPressed: () => context.go(AppRoutes.registration),
        child: const Icon(Icons.add),
      ),
      body: catalog.isEmpty
          ? const Center(
              child: Text(
                '語彙がまだ登録されていません',
                key: Key('catalog.empty-placeholder'),
              ),
            )
          : ListView.builder(
              key: const Key('catalog.list'),
              itemCount: catalog.entries.length,
              itemBuilder: (context, index) {
                final entry = catalog.entries[index];
                return _CatalogEntryTile(entry: entry);
              },
            ),
    );
  }
}

class _CatalogEntryTile extends StatelessWidget {
  const _CatalogEntryTile({required this.entry});

  final VocabularyExpressionEntry entry;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: Key('catalog.entry.${entry.identifier.value}'),
      title: Text(entry.text),
      subtitle: Text(_statusLabel(entry.explanationStatus)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go(
        '${AppRoutes.vocabularyPrefix}/${entry.identifier.value}',
      ),
    );
  }

  String _statusLabel(ExplanationGenerationStatus status) {
    return switch (status) {
      ExplanationGenerationStatus.pending => '解説を準備しています',
      ExplanationGenerationStatus.running => '解説を生成しています',
      ExplanationGenerationStatus.retryScheduled => '再試行を待機しています',
      ExplanationGenerationStatus.timedOut => 'タイムアウトしました',
      ExplanationGenerationStatus.succeeded => '解説があります',
      ExplanationGenerationStatus.failedFinal => '解説を生成できませんでした',
      ExplanationGenerationStatus.deadLettered => '解説を生成できませんでした',
    };
  }
}
