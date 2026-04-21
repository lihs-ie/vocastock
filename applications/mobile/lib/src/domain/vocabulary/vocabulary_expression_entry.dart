import 'package:meta/meta.dart';

import '../identifier/identifier.dart';
import '../status/explanation_generation_status.dart';
import '../status/image_generation_status.dart';
import '../status/registration_status.dart';

/// Summary-only projection of a VocabularyExpression aggregate exposed to the
/// `VocabularyCatalog` screen (spec 017 query-catalog-read).
///
/// Must never carry explanation body or image payload; the `currentExplanation`
/// / `currentImage` references are opaque identifiers that the UI uses to
/// navigate into the completed-only detail screens.
@immutable
class VocabularyExpressionEntry {
  const VocabularyExpressionEntry({
    required this.identifier,
    required this.text,
    required this.registrationStatus,
    required this.explanationStatus,
    required this.imageStatus,
    this.currentExplanation,
    this.currentImage,
  });

  final VocabularyExpressionIdentifier identifier;
  final String text;
  final RegistrationStatus registrationStatus;
  final ExplanationGenerationStatus explanationStatus;
  final ImageGenerationStatus imageStatus;
  final ExplanationIdentifier? currentExplanation;
  final VisualImageIdentifier? currentImage;

  bool get hasCompletedExplanation => currentExplanation != null;
  bool get hasCompletedImage => currentImage != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VocabularyExpressionEntry &&
          other.identifier == identifier &&
          other.text == text &&
          other.registrationStatus == registrationStatus &&
          other.explanationStatus == explanationStatus &&
          other.imageStatus == imageStatus &&
          other.currentExplanation == currentExplanation &&
          other.currentImage == currentImage);

  @override
  int get hashCode => Object.hash(
        identifier,
        text,
        registrationStatus,
        explanationStatus,
        imageStatus,
        currentExplanation,
        currentImage,
      );
}

/// Backend projection snapshot (spec 017). Carries only summary / status
/// information; completed payload access is per-screen (spec 013
/// generation-result-visibility-contract).
@immutable
class VocabularyCatalog {
  VocabularyCatalog(Iterable<VocabularyExpressionEntry> entries)
      : entries = List<VocabularyExpressionEntry>.unmodifiable(entries);

  final List<VocabularyExpressionEntry> entries;

  bool get isEmpty => entries.isEmpty;

  VocabularyExpressionEntry? findByText(String text) {
    for (final entry in entries) {
      if (entry.text == text) return entry;
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VocabularyCatalog &&
          other.entries.length == entries.length &&
          _listEquals(other.entries, entries));

  @override
  int get hashCode => Object.hashAll(entries);

  static bool _listEquals(List<Object?> a, List<Object?> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
