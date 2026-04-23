import '../../domain/identifier/identifier.dart';
import '../../domain/status/proficiency_level.dart';

/// Reads the learner's proficiency assignment for a VocabularyExpression.
///
/// The production binding uses `FerryLearningStateReader` which pre-loads
/// all learning states via the `learningStates` batch query and serves
/// `proficiencyFor` from cache. Test doubles live under
/// `test/support/stubs/stub_learning_state_reader.dart`.
abstract class LearningStateReader {
  ProficiencyLevel? proficiencyFor(VocabularyExpressionIdentifier identifier);
}
