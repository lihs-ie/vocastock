import 'package:meta/meta.dart';

import '../identifier/identifier.dart';

/// Completed explanation payload exposed to the `ExplanationDetail` screen
/// (spec 013 generation-result-visibility-contract).
///
/// This type is deliberately *only* the completed variant. Uncompleted
/// explanations are never exposed through any reader that returns this type;
/// status surveillance happens on `VocabularyExpressionDetail` (spec 013).
@immutable
class CompletedExplanationDetail {
  const CompletedExplanationDetail({
    required this.identifier,
    required this.vocabularyExpression,
    required this.body,
    required this.exampleSentences,
  });

  final ExplanationIdentifier identifier;
  final VocabularyExpressionIdentifier vocabularyExpression;
  final String body;
  final List<String> exampleSentences;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompletedExplanationDetail &&
          other.identifier == identifier &&
          other.vocabularyExpression == vocabularyExpression &&
          other.body == body &&
          _listEquals(other.exampleSentences, exampleSentences));

  @override
  int get hashCode => Object.hash(
        identifier,
        vocabularyExpression,
        body,
        Object.hashAll(exampleSentences),
      );

  static bool _listEquals(List<Object?> a, List<Object?> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
