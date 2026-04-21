import 'package:meta/meta.dart';

import '../identifier/identifier.dart';
import 'frequency_level.dart';
import 'pronunciation.dart';
import 'sense.dart';
import 'similar_expression.dart';
import 'sophistication_level.dart';

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
    required this.text,
    required this.pronunciation,
    required this.frequency,
    required this.sophistication,
    required this.etymology,
    required this.similarities,
    required this.senses,
  });

  final ExplanationIdentifier identifier;
  final VocabularyExpressionIdentifier vocabularyExpression;

  /// Head-word the explanation describes (matches the owning
  /// `VocabularyExpression.text`; exposed here so the Detail screen can
  /// render it without an extra reader round-trip).
  final String text;

  final Pronunciation pronunciation;
  final FrequencyLevel frequency;
  final SophisticationLevel sophistication;
  final String etymology;
  final List<SimilarExpression> similarities;
  final List<Sense> senses;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompletedExplanationDetail &&
          other.identifier == identifier &&
          other.vocabularyExpression == vocabularyExpression &&
          other.text == text &&
          other.pronunciation == pronunciation &&
          other.frequency == frequency &&
          other.sophistication == sophistication &&
          other.etymology == etymology &&
          _listEquals(other.similarities, similarities) &&
          _listEquals(other.senses, senses));

  @override
  int get hashCode => Object.hash(
        identifier,
        vocabularyExpression,
        text,
        pronunciation,
        frequency,
        sophistication,
        etymology,
        Object.hashAll(similarities),
        Object.hashAll(senses),
      );

  static bool _listEquals(List<Object?> a, List<Object?> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
