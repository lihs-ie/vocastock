import '../../domain/identifier/identifier.dart';
import '../../domain/status/proficiency_level.dart';

/// Reads the learner's proficiency assignment for a VocabularyExpression.
///
/// Real implementation depends on spec 005 LearningState aggregate; until
/// that reader lands, a stub derives the level deterministically from the
/// entry identifier so the Proficiency screen has something to render.
abstract class LearningStateReader {
  ProficiencyLevel? proficiencyFor(VocabularyExpressionIdentifier identifier);
}

class StubLearningStateReader implements LearningStateReader {
  const StubLearningStateReader();

  static const List<ProficiencyLevel> _levels = <ProficiencyLevel>[
    ProficiencyLevel.learning,
    ProficiencyLevel.learned,
    ProficiencyLevel.internalized,
    ProficiencyLevel.fluent,
  ];

  @override
  ProficiencyLevel? proficiencyFor(
    VocabularyExpressionIdentifier identifier,
  ) {
    final hash = identifier.value.codeUnits.fold<int>(
      0,
      (acc, unit) => (acc + unit) & 0xff,
    );
    return _levels[hash % _levels.length];
  }
}
