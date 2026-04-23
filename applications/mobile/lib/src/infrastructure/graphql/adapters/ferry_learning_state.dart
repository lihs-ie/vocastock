import 'package:ferry/ferry.dart';

import '../../../application/reader/learning_state_reader.dart';
import '../../../domain/identifier/identifier.dart';
import '../../../domain/status/proficiency_level.dart';
import '../__generated__/schema.schema.gql.dart' as schema;
import '../operations/__generated__/learning_state.req.gql.dart';

/// Ferry-backed [LearningStateReader] that pre-loads all learning
/// states for the authenticated actor via the `learningStates` batch
/// query and serves [proficiencyFor] from an in-process cache.
///
/// Call [load] once after login so the cache is populated before the
/// Proficiency screen iterates synchronously over catalog entries.
class FerryLearningStateReader implements LearningStateReader {
  FerryLearningStateReader({required Client client}) : _client = client;

  final Client _client;
  final Map<String, ProficiencyLevel> _cache = {};

  Future<void> load() async {
    _cache.clear();
    final request = GLearningStatesQueryReq();
    try {
      final result = await _client.request(request).first;
      final data = result.data;
      if (data == null) return;
      for (final entry in data.learningStates) {
        final level = _mapProficiency(entry.proficiency);
        if (level != null) {
          _cache[entry.vocabularyExpression] = level;
        }
      }
    } on Object {
      // Network errors are swallowed so the Proficiency screen
      // degrades gracefully to "no proficiency data" rather than
      // crashing the app.
    }
  }

  @override
  ProficiencyLevel? proficiencyFor(VocabularyExpressionIdentifier identifier) {
    return _cache[identifier.value];
  }

  static ProficiencyLevel? _mapProficiency(schema.GProficiencyLevel level) {
    if (level == schema.GProficiencyLevel.LEARNING) {
      return ProficiencyLevel.learning;
    }
    if (level == schema.GProficiencyLevel.LEARNED) {
      return ProficiencyLevel.learned;
    }
    if (level == schema.GProficiencyLevel.INTERNALIZED) {
      return ProficiencyLevel.internalized;
    }
    if (level == schema.GProficiencyLevel.FLUENT) {
      return ProficiencyLevel.fluent;
    }
    return null;
  }
}
