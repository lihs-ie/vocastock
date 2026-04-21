import '../../domain/identifier/identifier.dart';
import '../../domain/vocabulary/vocabulary_expression_entry.dart';

/// Reads a single vocabulary expression as a status-only summary.
///
/// Screens bound to this reader (spec 013 `VocabularyExpressionDetail`) MUST
/// render state summaries only; completed explanation body and image payload
/// are reached through the dedicated detail readers (Phase 5).
abstract class VocabularyExpressionDetailReader {
  Future<VocabularyExpressionEntry?> readDetail(
    VocabularyExpressionIdentifier identifier,
  );
  Stream<VocabularyExpressionEntry?> watchDetail(
    VocabularyExpressionIdentifier identifier,
  );
}
