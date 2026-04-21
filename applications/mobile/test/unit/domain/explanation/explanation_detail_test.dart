import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/domain/explanation/explanation_detail.dart';
import 'package:vocastock_mobile/src/domain/identifier/identifier.dart';

CompletedExplanationDetail _detail({
  String body = 'body',
  List<String> examples = const ['a'],
}) {
  return CompletedExplanationDetail(
    identifier: ExplanationIdentifier('e'),
    vocabularyExpression: VocabularyExpressionIdentifier('v'),
    body: body,
    exampleSentences: examples,
  );
}

void main() {
  group('CompletedExplanationDetail', () {
    test('is value-equal when all fields match', () {
      expect(_detail(), equals(_detail()));
      expect(_detail().hashCode, equals(_detail().hashCode));
    });

    test('differs when body changes', () {
      expect(_detail(), isNot(equals(_detail(body: 'other'))));
    });

    test('differs when example sentences change', () {
      expect(_detail(), isNot(equals(_detail(examples: const ['b']))));
    });
  });
}
