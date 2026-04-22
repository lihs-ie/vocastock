import 'package:meta/meta.dart';

import '../identifier/identifier.dart';

/// Completed visual image payload exposed to the `ImageDetail` screen
/// (spec 013 generation-result-visibility-contract).
///
/// Only the completed variant is modelled; uncompleted / failed images are
/// observed exclusively through `VocabularyExpressionDetail`.
@immutable
class CompletedImageDetail {
  const CompletedImageDetail({
    required this.identifier,
    required this.explanation,
    required this.assetReference,
    required this.description,
    this.senseIdentifier,
    this.senseLabel,
  });

  final VisualImageIdentifier identifier;
  final ExplanationIdentifier explanation;
  final String assetReference;
  final String description;

  /// Sense this image illustrates; null means "overall / head-word" image.
  final String? senseIdentifier;

  /// Short Japanese label of the associated sense (for UI overlays).
  final String? senseLabel;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompletedImageDetail &&
          other.identifier == identifier &&
          other.explanation == explanation &&
          other.assetReference == assetReference &&
          other.description == description &&
          other.senseIdentifier == senseIdentifier &&
          other.senseLabel == senseLabel);

  @override
  int get hashCode => Object.hash(
        identifier,
        explanation,
        assetReference,
        description,
        senseIdentifier,
        senseLabel,
      );
}
