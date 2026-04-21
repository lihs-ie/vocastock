import 'package:meta/meta.dart';

/// Remaining quota per generation feature (spec 010 / 014).
///
/// Separate concept from [EntitlementBundle]; constitution §VI forbids mixing
/// allowance (how much is left) with entitlement (which features are granted).
@immutable
class UsageAllowance {
  const UsageAllowance({
    required this.remainingExplanationGenerations,
    required this.remainingImageGenerations,
  });

  final int remainingExplanationGenerations;
  final int remainingImageGenerations;

  bool get canGenerateExplanation => remainingExplanationGenerations > 0;
  bool get canGenerateImage => remainingImageGenerations > 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsageAllowance &&
          other.remainingExplanationGenerations ==
              remainingExplanationGenerations &&
          other.remainingImageGenerations == remainingImageGenerations);

  @override
  int get hashCode => Object.hash(
        remainingExplanationGenerations,
        remainingImageGenerations,
      );

  @override
  String toString() =>
      'UsageAllowance(explanation=$remainingExplanationGenerations, '
      'image=$remainingImageGenerations)';
}
