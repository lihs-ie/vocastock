import '../../domain/vocabulary/vocabulary_expression_entry.dart';

/// Reads the learner's vocabulary catalog for the `VocabularyCatalog` screen
/// (spec 013 screen-source-binding-contract, spec 017 query-catalog-read).
///
/// Implementations MUST only surface completed summaries or status-only
/// placeholders; explanation body / image payload are retrieved through the
/// dedicated detail readers (Phase 5).
abstract class VocabularyCatalogReader {
  Future<VocabularyCatalog> read();
  Stream<VocabularyCatalog> watch();
  VocabularyCatalog get current;
}
