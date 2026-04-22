import '../../domain/identifier/identifier.dart';
import '../../domain/status/proficiency_level.dart';

/// Reads the learner's proficiency assignment for a VocabularyExpression.
///
/// Real implementation depends on spec 005 LearningState aggregate once it
/// is exposed through the GraphQL gateway. Until then the production
/// binding returns [NullLearningStateReader], which reports no proficiency
/// for every entry so the Proficiency screen renders an empty bucket
/// instead of fabricated categories.
abstract class LearningStateReader {
  ProficiencyLevel? proficiencyFor(VocabularyExpressionIdentifier identifier);
}

class NullLearningStateReader implements LearningStateReader {
  const NullLearningStateReader();

  @override
  ProficiencyLevel? proficiencyFor(
    VocabularyExpressionIdentifier identifier,
  ) =>
      null;
}
