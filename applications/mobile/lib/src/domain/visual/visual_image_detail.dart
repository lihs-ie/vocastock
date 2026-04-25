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
    this.previousImage,
  });

  final VisualImageIdentifier identifier;
  final ExplanationIdentifier explanation;
  final String assetReference;
  final String description;

  /// Sense this image illustrates; null means "overall / head-word" image.
  final String? senseIdentifier;

  /// Short Japanese label of the associated sense (for UI overlays).
  final String? senseLabel;

  /// Predecessor image in the same explanation lineage; null on first
  /// generation. Wired through from the worker's
  /// `actors/{actor}/images/{id}.previousImage` field per
  /// `docs/internal/domain/visual.md:46`.
  final VisualImageIdentifier? previousImage;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompletedImageDetail &&
          other.identifier == identifier &&
          other.explanation == explanation &&
          other.assetReference == assetReference &&
          other.description == description &&
          other.senseIdentifier == senseIdentifier &&
          other.senseLabel == senseLabel &&
          other.previousImage == previousImage);

  @override
  int get hashCode => Object.hash(
        identifier,
        explanation,
        assetReference,
        description,
        senseIdentifier,
        senseLabel,
        previousImage,
      );
}
