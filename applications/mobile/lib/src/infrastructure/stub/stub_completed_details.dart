import '../../application/reader/completed_detail_readers.dart';
import '../../domain/explanation/explanation_detail.dart';
import '../../domain/identifier/identifier.dart';
import '../../domain/status/explanation_generation_status.dart';
import '../../domain/status/image_generation_status.dart';
import '../../domain/visual/visual_image_detail.dart';
import 'stub_vocabulary_catalog.dart';

/// Reads completed explanation / image payloads from a [StubVocabularyCatalog].
///
/// Returns `null` whenever the underlying catalog entry does not report a
/// succeeded generation status; the corresponding screen then routes the
/// user back to `VocabularyExpressionDetail` rather than rendering a
/// provisional payload (spec 013 generation-result-visibility-contract).
class StubCompletedDetails
    implements ExplanationDetailReader, VisualImageDetailReader {
  StubCompletedDetails(this._catalog);

  final StubVocabularyCatalog _catalog;

  @override
  Future<CompletedExplanationDetail?> readExplanation(
    ExplanationIdentifier identifier,
  ) async {
    for (final entry in _catalog.current.entries) {
      if (entry.currentExplanation == identifier &&
          entry.explanationStatus ==
              ExplanationGenerationStatus.succeeded) {
        return CompletedExplanationDetail(
          identifier: identifier,
          vocabularyExpression: entry.identifier,
          body: 'Stub explanation for "${entry.text}"',
          exampleSentences: [
            'This is an example sentence using ${entry.text}.',
            'Another example sentence with ${entry.text}.',
          ],
        );
      }
    }
    return null;
  }

  @override
  Future<CompletedImageDetail?> readImage(
    VisualImageIdentifier identifier,
  ) async {
    for (final entry in _catalog.current.entries) {
      if (entry.currentImage == identifier &&
          entry.imageStatus == ImageGenerationStatus.succeeded &&
          entry.currentExplanation != null) {
        return CompletedImageDetail(
          identifier: identifier,
          explanation: entry.currentExplanation!,
          assetReference: 'stub://image/${identifier.value}',
          description: 'Illustration for "${entry.text}"',
        );
      }
    }
    return null;
  }
}
