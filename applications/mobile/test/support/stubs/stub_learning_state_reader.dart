import 'package:vocastock_mobile/src/application/reader/learning_state_reader.dart';
import 'package:vocastock_mobile/src/domain/identifier/identifier.dart';
import 'package:vocastock_mobile/src/domain/status/proficiency_level.dart';

/// Deterministically derives a proficiency level from the identifier so
/// feature / widget tests can exercise the full Proficiency screen
/// without depending on the (not-yet-exposed) spec 005 backend reader.
/// Never referenced from `lib/src/`.
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
