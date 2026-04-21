import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_bindings.dart';
import '../../domain/status/proficiency_level.dart';
import '../../domain/vocabulary/vocabulary_expression_entry.dart';
import '../router/router.dart';
import '../theme/vs_tokens.dart';
import '../theme/widgets/vs_chip.dart';
import '../theme/widgets/vs_wordmark.dart';

/// Proficiency dashboard mirroring `screens.jsx` `VSProficiency`.
///
/// Aggregates vocabulary entries by `LearningState.proficiency`. Spec 005
/// owns the concept; the stub `LearningStateReader` assigns a level so the
/// layout renders even before the backend reader lands.
class ProficiencyScreen extends ConsumerWidget {
  const ProficiencyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(vocabularyCatalogStreamProvider);
    final catalog = catalogAsync.value ??
        VocabularyCatalog(const <VocabularyExpressionEntry>[]);
    final learningState = ref.watch(learningStateReaderProvider);
    final theme = Theme.of(context);

    final byLevel = <ProficiencyLevel, List<VocabularyExpressionEntry>>{
      for (final level in ProficiencyLevel.values) level: <VocabularyExpressionEntry>[],
    };
    for (final entry in catalog.entries) {
      final level = learningState.proficiencyFor(entry.identifier);
      if (level == null) continue;
      byLevel[level]!.add(entry);
    }

    return Scaffold(
      backgroundColor: VsTokens.paper,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const VsWordmark(size: 13),
                  const SizedBox(height: 8),
                  Text(
                    '習熟度',
                    key: const Key('proficiency.title'),
                    style: theme.textTheme.displaySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'LearningState.proficiency を Learner ごとに集計',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: VsTokens.inkMute,
                    ),
                  ),
                ],
              ),
            ),
            _ProficiencyStackedBar(byLevel: byLevel),
            const SizedBox(height: 6),
            Expanded(
              child: catalog.entries.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'まだ習熟度は記録されていません',
                          key: const Key('proficiency.empty'),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: VsTokens.inkMute,
                          ),
                        ),
                      ),
                    )
                  : ListView(
                      key: const Key('proficiency.list'),
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
                      children: <Widget>[
                        for (final level in ProficiencyLevel.values)
                          if (byLevel[level]!.isNotEmpty)
                            _ProficiencySection(
                              level: level,
                              entries: byLevel[level]!,
                            ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProficiencyStackedBar extends StatelessWidget {
  const _ProficiencyStackedBar({required this.byLevel});
  final Map<ProficiencyLevel, List<VocabularyExpressionEntry>> byLevel;

  @override
  Widget build(BuildContext context) {
    final totals = <ProficiencyLevel, int>{
      for (final entry in byLevel.entries) entry.key: entry.value.length,
    };
    final totalCount = totals.values.fold<int>(0, (a, b) => a + b);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                border: Border.all(color: VsTokens.inkHair, width: 0.5),
                borderRadius: BorderRadius.circular(6),
                color: VsTokens.paperSoft,
              ),
              child: totalCount == 0
                  ? const SizedBox.shrink()
                  : Row(
                      children: <Widget>[
                        for (final level in ProficiencyLevel.values)
                          if (totals[level]! > 0)
                            Expanded(
                              flex: totals[level]!,
                              child: ColoredBox(color: _colorFor(level)),
                            ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: <Widget>[
              for (final level in ProficiencyLevel.values)
                _LegendChip(level: level, count: totals[level] ?? 0),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.level, required this.count});
  final ProficiencyLevel level;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _colorFor(level),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          _labelJa(level),
          style: const TextStyle(
            fontFamily: VsTokens.sans,
            fontSize: 11,
            color: VsTokens.inkSoft,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: const TextStyle(
            fontFamily: VsTokens.mono,
            fontSize: 11,
            color: VsTokens.inkMute,
          ),
        ),
      ],
    );
  }
}

class _ProficiencySection extends StatelessWidget {
  const _ProficiencySection({required this.level, required this.entries});

  final ProficiencyLevel level;
  final List<VocabularyExpressionEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 8),
            child: Row(
              children: <Widget>[
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _colorFor(level),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _initialLetter(level),
                    style: const TextStyle(
                      fontFamily: VsTokens.serif,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: VsTokens.paper,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${_labelJa(level)} · ${_labelEn(level)}',
                  style: theme.textTheme.headlineSmall,
                ),
                const Spacer(),
                Text(
                  '${entries.length}',
                  style: const TextStyle(
                    fontFamily: VsTokens.mono,
                    fontSize: 11,
                    color: VsTokens.inkMute,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (final entry in entries)
                  _ProficiencyEntryRow(entry: entry),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProficiencyEntryRow extends StatelessWidget {
  const _ProficiencyEntryRow({required this.entry});
  final VocabularyExpressionEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: VsTokens.paperSoft,
        borderRadius: BorderRadius.circular(VsTokens.radiusSm),
        child: InkWell(
          key: Key('proficiency.entry.${entry.identifier.value}'),
          borderRadius: BorderRadius.circular(VsTokens.radiusSm),
          onTap: () => context.go(
            '${AppRoutes.vocabularyPrefix}/${entry.identifier.value}',
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: VsTokens.inkHair, width: 0.5),
              borderRadius: BorderRadius.circular(VsTokens.radiusSm),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    entry.text,
                    style: const TextStyle(
                      fontFamily: VsTokens.serif,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: VsTokens.ink,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (entry.registrationStatus.name.isNotEmpty)
                  const VsChip(label: 'word'),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  size: 14,
                  color: VsTokens.inkMute,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Color _colorFor(ProficiencyLevel level) => switch (level) {
      ProficiencyLevel.learning => VsTokens.profLearning,
      ProficiencyLevel.learned => VsTokens.profLearned,
      ProficiencyLevel.internalized => VsTokens.profInternalized,
      ProficiencyLevel.fluent => VsTokens.profFluent,
    };

String _labelJa(ProficiencyLevel level) => switch (level) {
      ProficiencyLevel.learning => '学習中',
      ProficiencyLevel.learned => '習得',
      ProficiencyLevel.internalized => '定着',
      ProficiencyLevel.fluent => '自在',
    };

String _labelEn(ProficiencyLevel level) => switch (level) {
      ProficiencyLevel.learning => 'Learning',
      ProficiencyLevel.learned => 'Learned',
      ProficiencyLevel.internalized => 'Internalized',
      ProficiencyLevel.fluent => 'Fluent',
    };

String _initialLetter(ProficiencyLevel level) => _labelEn(level)[0];
