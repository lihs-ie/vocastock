import '../../domain/explanation/explanation_detail.dart';
import '../../domain/identifier/identifier.dart';
import '../../domain/visual/visual_image_detail.dart';

/// Returns a completed explanation payload, or null if the id does not
/// correspond to a completed explanation (spec 013 — uncompleted status is
/// observed exclusively from `VocabularyExpressionDetail`).
abstract class ExplanationDetailReader {
  Future<CompletedExplanationDetail?> readExplanation(
    ExplanationIdentifier identifier,
  );
}

abstract class VisualImageDetailReader {
  Future<CompletedImageDetail?> readImage(VisualImageIdentifier identifier);
}
