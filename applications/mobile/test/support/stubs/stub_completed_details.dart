import 'package:vocastock_mobile/src/application/reader/completed_detail_readers.dart';
import 'package:vocastock_mobile/src/domain/explanation/explanation_detail.dart';
import 'package:vocastock_mobile/src/domain/explanation/frequency_level.dart';
import 'package:vocastock_mobile/src/domain/explanation/pronunciation.dart';
import 'package:vocastock_mobile/src/domain/explanation/sense.dart';
import 'package:vocastock_mobile/src/domain/explanation/similar_expression.dart';
import 'package:vocastock_mobile/src/domain/explanation/sophistication_level.dart';
import 'package:vocastock_mobile/src/domain/identifier/identifier.dart';
import 'package:vocastock_mobile/src/domain/status/explanation_generation_status.dart';
import 'package:vocastock_mobile/src/domain/status/image_generation_status.dart';
import 'package:vocastock_mobile/src/domain/visual/visual_image_detail.dart';
import 'stub_vocabulary_catalog.dart';

/// Reads completed explanation / image payloads from a [StubVocabularyCatalog].
///
/// Returns `null` whenever the underlying catalog entry does not report a
/// succeeded generation status; the corresponding screen then routes the
/// user back to `VocabularyExpressionDetail` rather than rendering a
/// provisional payload (spec 013 generation-result-visibility-contract).
///
/// Synthesises a rich payload that mirrors data.jsx's `run` entry so the
/// Detail screen can exercise all UI variants (senses, chips,
/// similarities, image gallery) before the real backend reader lands.
class StubCompletedDetails
    implements ExplanationDetailReader, VisualImageDetailReader {
  StubCompletedDetails(this._catalog);

  final StubVocabularyCatalog _catalog;

  @override
  Future<CompletedExplanationDetail?> readExplanation(
    ExplanationIdentifier identifier,
  ) async {
    for (final entry in _catalog.current.entries) {
      if (entry.currentExplanation == identifier &&
          entry.explanationStatus ==
              ExplanationGenerationStatus.succeeded) {
        return _buildExplanation(identifier, entry.identifier, entry.text);
      }
    }
    return null;
  }

  @override
  Future<CompletedImageDetail?> readImage(
    VisualImageIdentifier identifier,
  ) async {
    for (final entry in _catalog.current.entries) {
      if (entry.currentImage == identifier &&
          entry.imageStatus == ImageGenerationStatus.succeeded &&
          entry.currentExplanation != null) {
        return CompletedImageDetail(
          identifier: identifier,
          explanation: entry.currentExplanation!,
          assetReference: 'stub://image/${identifier.value}',
          description: '「${entry.text}」を視覚化したイラスト',
          senseIdentifier: 's1',
          senseLabel: _defaultSenseLabel(entry.text),
        );
      }
    }
    return null;
  }

  CompletedExplanationDetail _buildExplanation(
    ExplanationIdentifier identifier,
    VocabularyExpressionIdentifier vocabularyExpression,
    String text,
  ) {
    return CompletedExplanationDetail(
      identifier: identifier,
      vocabularyExpression: vocabularyExpression,
      text: text,
      pronunciation: _pronunciationFor(text),
      frequency: FrequencyLevel.often,
      sophistication: SophisticationLevel.veryBasic,
      etymology: _etymologyFor(text),
      similarities: _similaritiesFor(text),
      senses: _sensesFor(text),
    );
  }

  Pronunciation _pronunciationFor(String text) {
    return Pronunciation(
      weak: '/${text.toLowerCase()}/',
      strong: '/${text.toUpperCase()}/',
    );
  }

  String _etymologyFor(String text) {
    return '古英語 $text に由来する。語源情報はサーバーから供給される予定です。';
  }

  List<SimilarExpression> _similaritiesFor(String text) {
    return <SimilarExpression>[
      SimilarExpression(
        value: '$text alternative',
        meaning: '同義の表現',
        comparison: '$text よりフォーマルな場面で使われる。',
      ),
      SimilarExpression(
        value: '$text variant',
        meaning: 'カジュアルな表現',
        comparison: '口語で $text の代わりに使われる。',
      ),
    ];
  }

  String _defaultSenseLabel(String text) {
    if (text.toLowerCase() == 'run') return '走る';
    return '概要';
  }

  List<Sense> _sensesFor(String text) {
    if (text.toLowerCase() == 'run') {
      return const <Sense>[
        Sense(
          identifier: 's1',
          order: 1,
          label: '走る',
          situation: 'スポーツ・日常の移動・体育の授業など物理的な移動場面。',
          nuance: '歩くより速い速度で足を交互に動かす、最も中核的な意味。',
          examples: <SenseExample>[
            SenseExample(
              value: 'I run every morning before work.',
              meaning: '毎朝、仕事の前に走っています。',
            ),
            SenseExample(
              value: 'She ran to catch the train.',
              meaning: '彼女は電車に間に合うように走った。',
            ),
          ],
          collocations: <Collocation>[
            Collocation(value: 'run fast', meaning: '速く走る'),
            Collocation(value: 'run a marathon', meaning: 'マラソンを走る'),
          ],
        ),
        Sense(
          identifier: 's2',
          order: 2,
          label: '経営する',
          situation: 'ビジネス、会社、組織、プロジェクトの運営について話す場面。',
          nuance: '責任を持って継続的に物事を動かしていくイメージ。operate より口語的。',
          examples: <SenseExample>[
            SenseExample(
              value: 'He runs a small bakery in Kyoto.',
              meaning: '彼は京都で小さなパン屋を経営しています。',
            ),
            SenseExample(
              value: 'Who runs this project?',
              meaning: 'このプロジェクトは誰が仕切っていますか？',
            ),
          ],
          collocations: <Collocation>[
            Collocation(value: 'run a business', meaning: '事業を営む'),
            Collocation(value: 'run a meeting', meaning: '会議を取り仕切る'),
          ],
        ),
        Sense(
          identifier: 's3',
          order: 3,
          label: '（機械・プログラムが）動作する',
          situation: 'ソフトウェア、エンジン、機械の稼働状態を述べる場面。',
          nuance: 'work より「動いている最中」に焦点。IT 文脈では必須の語義。',
          examples: <SenseExample>[
            SenseExample(
              value: 'The app runs on both iOS and Android.',
              meaning: 'そのアプリは iOS でも Android でも動きます。',
            ),
          ],
          collocations: <Collocation>[
            Collocation(value: 'run smoothly', meaning: 'スムーズに動く'),
            Collocation(
              value: 'run in the background',
              meaning: 'バックグラウンドで動作する',
            ),
          ],
        ),
        Sense(
          identifier: 's4',
          order: 4,
          label: '（液体が）流れる',
          situation: '水・涙・インクなど液体の動きを描写する場面。',
          nuance: 'flow よりやや口語的で、方向性のある流れを示す。',
          examples: <SenseExample>[
            SenseExample(
              value: 'Tears ran down her cheeks.',
              meaning: '涙が彼女の頬を伝って流れた。',
            ),
          ],
          collocations: <Collocation>[
            Collocation(value: 'run dry', meaning: '枯渇する'),
          ],
        ),
      ];
    }
    return <Sense>[
      Sense(
        identifier: 's1',
        order: 1,
        label: '概要',
        situation: '$text の一般的な使用場面。',
        nuance: '$text の中核的な意味。',
        examples: <SenseExample>[
          SenseExample(
            value: 'This is an example sentence using $text.',
            meaning: 'これは $text を使った例文です。',
          ),
          SenseExample(
            value: 'Another example sentence with $text.',
            meaning: 'もう一つの $text を使った例文です。',
          ),
        ],
        collocations: <Collocation>[
          Collocation(value: 'use $text', meaning: '$text を使う'),
        ],
      ),
    ];
  }
}
