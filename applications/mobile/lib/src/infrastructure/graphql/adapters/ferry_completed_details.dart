import 'package:ferry/ferry.dart';

import '../../../application/reader/completed_detail_readers.dart';
import '../../../domain/explanation/explanation_detail.dart';
import '../../../domain/explanation/frequency_level.dart';
import '../../../domain/explanation/pronunciation.dart';
import '../../../domain/explanation/sense.dart';
import '../../../domain/explanation/similar_expression.dart';
import '../../../domain/explanation/sophistication_level.dart';
import '../../../domain/identifier/identifier.dart';
import '../../../domain/visual/visual_image_detail.dart';
import '../__generated__/schema.schema.gql.dart' as schema;
import '../operations/__generated__/completed_details.req.gql.dart';

/// Ferry-backed implementation of the completed-explanation and
/// completed-image readers. Both queries are only safe to call once the
/// owning `VocabularyExpression` has transitioned to a visibility-allowed
/// state (spec 013 `allowsCompletedPayload`); a null return signals the
/// back end saw a stale or not-yet-visible payload.
class FerryCompletedDetails
    implements ExplanationDetailReader, VisualImageDetailReader {
  const FerryCompletedDetails({required Client client}) : _client = client;

  final Client _client;

  @override
  Future<CompletedExplanationDetail?> readExplanation(
    ExplanationIdentifier identifier,
  ) async {
    final request = GExplanationDetailQueryReq(
      (b) => b
        ..vars.identifier = identifier.value
        ..fetchPolicy = FetchPolicy.NetworkOnly,
    );
    final response = await _client.request(request).first;
    final data = response.data?.explanationDetail;
    if (data == null) return null;
    return CompletedExplanationDetail(
      identifier: ExplanationIdentifier(data.identifier),
      vocabularyExpression:
          VocabularyExpressionIdentifier(data.vocabularyExpression),
      text: data.text,
      pronunciation: Pronunciation(
        weak: data.pronunciation.weak,
        strong: data.pronunciation.strong,
      ),
      frequency: _frequency(data.frequency),
      sophistication: _sophistication(data.sophistication),
      etymology: data.etymology,
      similarities: data.similarities
          .map(
            (raw) => SimilarExpression(
              value: raw.value,
              meaning: raw.meaning,
              comparison: raw.comparison,
            ),
          )
          .toList(growable: false),
      senses: data.senses
          .map(
            (raw) => Sense(
              identifier: raw.identifier,
              order: raw.order,
              label: raw.label,
              situation: raw.situation,
              nuance: raw.nuance,
              examples: raw.examples
                  .map(
                    (example) => SenseExample(
                      value: example.value,
                      meaning: example.meaning,
                      pronunciation: example.pronunciation,
                    ),
                  )
                  .toList(growable: false),
              collocations: raw.collocations
                  .map(
                    (collocation) => Collocation(
                      value: collocation.value,
                      meaning: collocation.meaning,
                    ),
                  )
                  .toList(growable: false),
            ),
          )
          .toList(growable: false),
    );
  }

  @override
  Future<CompletedImageDetail?> readImage(
    VisualImageIdentifier identifier,
  ) async {
    final request = GImageDetailQueryReq(
      (b) => b
        ..vars.identifier = identifier.value
        ..fetchPolicy = FetchPolicy.NetworkOnly,
    );
    final response = await _client.request(request).first;
    final data = response.data?.imageDetail;
    if (data == null) return null;
    return CompletedImageDetail(
      identifier: VisualImageIdentifier(data.identifier),
      explanation: ExplanationIdentifier(data.explanation),
      assetReference: data.assetReference,
      description: data.description,
      senseIdentifier: data.senseIdentifier,
      senseLabel: data.senseLabel,
    );
  }

  FrequencyLevel _frequency(schema.GFrequencyLevel value) {
    return switch (value) {
      schema.GFrequencyLevel.OFTEN => FrequencyLevel.often,
      schema.GFrequencyLevel.SOMETIMES => FrequencyLevel.sometimes,
      schema.GFrequencyLevel.RARELY => FrequencyLevel.rarely,
      schema.GFrequencyLevel.HARDLY_EVER => FrequencyLevel.hardlyEver,
      _ => FrequencyLevel.sometimes,
    };
  }

  SophisticationLevel _sophistication(schema.GSophisticationLevel value) {
    return switch (value) {
      schema.GSophisticationLevel.VERY_BASIC => SophisticationLevel.veryBasic,
      schema.GSophisticationLevel.BASIC => SophisticationLevel.basic,
      schema.GSophisticationLevel.INTERMEDIATE =>
        SophisticationLevel.intermediate,
      schema.GSophisticationLevel.ADVANCED => SophisticationLevel.advanced,
      _ => SophisticationLevel.basic,
    };
  }
}
