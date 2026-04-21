import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/domain/explanation/explanation_detail.dart';
import 'package:vocastock_mobile/src/domain/explanation/frequency_level.dart';
import 'package:vocastock_mobile/src/domain/explanation/pronunciation.dart';
import 'package:vocastock_mobile/src/domain/explanation/sense.dart';
import 'package:vocastock_mobile/src/domain/explanation/similar_expression.dart';
import 'package:vocastock_mobile/src/domain/explanation/sophistication_level.dart';
import 'package:vocastock_mobile/src/domain/identifier/identifier.dart';

CompletedExplanationDetail _detail({
  String text = 'run',
  FrequencyLevel frequency = FrequencyLevel.often,
  SophisticationLevel sophistication = SophisticationLevel.veryBasic,
  String etymology = 'etymology',
  List<SimilarExpression>? similarities,
  List<Sense>? senses,
}) {
  return CompletedExplanationDetail(
    identifier: ExplanationIdentifier('e'),
    vocabularyExpression: VocabularyExpressionIdentifier('v'),
    text: text,
    pronunciation: const Pronunciation(weak: '/run/', strong: '/RUN/'),
    frequency: frequency,
    sophistication: sophistication,
    etymology: etymology,
    similarities: similarities ??
        const <SimilarExpression>[
          SimilarExpression(
            value: 'jog',
            meaning: '軽く走る',
            comparison: 'run よりゆっくり。',
          ),
        ],
    senses: senses ??
        const <Sense>[
          Sense(
            identifier: 's1',
            order: 1,
            label: '走る',
            situation: 'スポーツや移動場面',
            nuance: '歩くより速く足を動かす',
            examples: <SenseExample>[
              SenseExample(value: 'I run.', meaning: '走る。'),
            ],
            collocations: <Collocation>[
              Collocation(value: 'run fast', meaning: '速く走る'),
            ],
          ),
        ],
  );
}

void main() {
  group('CompletedExplanationDetail', () {
    test('is value-equal when all fields match', () {
      expect(_detail(), equals(_detail()));
      expect(_detail().hashCode, equals(_detail().hashCode));
    });

    test('differs when text changes', () {
      expect(_detail(), isNot(equals(_detail(text: 'other'))));
    });

    test('differs when frequency changes', () {
      expect(
        _detail(),
        isNot(equals(_detail(frequency: FrequencyLevel.rarely))),
      );
    });

    test('differs when sophistication changes', () {
      expect(
        _detail(),
        isNot(equals(_detail(sophistication: SophisticationLevel.advanced))),
      );
    });

    test('differs when etymology changes', () {
      expect(
        _detail(),
        isNot(equals(_detail(etymology: 'other etymology'))),
      );
    });

    test('differs when similarities change', () {
      expect(
        _detail(),
        isNot(
          equals(
            _detail(
              similarities: const <SimilarExpression>[
                SimilarExpression(
                  value: 'sprint',
                  meaning: '全力で走る',
                  comparison: '短距離で最大速度。',
                ),
              ],
            ),
          ),
        ),
      );
    });

    test('differs when senses change', () {
      expect(
        _detail(),
        isNot(
          equals(
            _detail(
              senses: const <Sense>[
                Sense(
                  identifier: 's-other',
                  order: 1,
                  label: 'その他',
                  situation: '別の場面',
                  nuance: '別のニュアンス',
                  examples: <SenseExample>[],
                  collocations: <Collocation>[],
                ),
              ],
            ),
          ),
        ),
      );
    });
  });
}
