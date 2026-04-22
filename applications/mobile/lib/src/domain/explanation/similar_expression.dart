import 'package:meta/meta.dart';

/// A related expression compared against the primary entry, surfaced in
/// the Detail footer (`類似表現`).
@immutable
class SimilarExpression {
  const SimilarExpression({
    required this.value,
    required this.meaning,
    required this.comparison,
  });

  final String value;
  final String meaning;
  final String comparison;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SimilarExpression &&
          other.value == value &&
          other.meaning == meaning &&
          other.comparison == comparison);

  @override
  int get hashCode => Object.hash(value, meaning, comparison);
}
