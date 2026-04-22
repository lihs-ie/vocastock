// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:vocastock_mobile/src/infrastructure/graphql/__generated__/schema.schema.gql.dart'
    as _i2;
import 'package:vocastock_mobile/src/infrastructure/graphql/__generated__/serializers.gql.dart'
    as _i1;

part 'completed_details.data.gql.g.dart';

abstract class GExplanationDetailQueryData
    implements
        Built<GExplanationDetailQueryData, GExplanationDetailQueryDataBuilder> {
  GExplanationDetailQueryData._();

  factory GExplanationDetailQueryData(
          [void Function(GExplanationDetailQueryDataBuilder b) updates]) =
      _$GExplanationDetailQueryData;

  static void _initializeBuilder(GExplanationDetailQueryDataBuilder b) =>
      b..G__typename = 'Query';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GExplanationDetailQueryData_explanationDetail? get explanationDetail;
  static Serializer<GExplanationDetailQueryData> get serializer =>
      _$gExplanationDetailQueryDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GExplanationDetailQueryData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GExplanationDetailQueryData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GExplanationDetailQueryData.serializer,
        json,
      );
}

abstract class GExplanationDetailQueryData_explanationDetail
    implements
        Built<GExplanationDetailQueryData_explanationDetail,
            GExplanationDetailQueryData_explanationDetailBuilder> {
  GExplanationDetailQueryData_explanationDetail._();

  factory GExplanationDetailQueryData_explanationDetail(
      [void Function(GExplanationDetailQueryData_explanationDetailBuilder b)
          updates]) = _$GExplanationDetailQueryData_explanationDetail;

  static void _initializeBuilder(
          GExplanationDetailQueryData_explanationDetailBuilder b) =>
      b..G__typename = 'CompletedExplanationDetail';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get identifier;
  String get vocabularyExpression;
  String get text;
  GExplanationDetailQueryData_explanationDetail_pronunciation get pronunciation;
  _i2.GFrequencyLevel get frequency;
  _i2.GSophisticationLevel get sophistication;
  String get etymology;
  BuiltList<GExplanationDetailQueryData_explanationDetail_similarities>
      get similarities;
  BuiltList<GExplanationDetailQueryData_explanationDetail_senses> get senses;
  static Serializer<GExplanationDetailQueryData_explanationDetail>
      get serializer =>
          _$gExplanationDetailQueryDataExplanationDetailSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GExplanationDetailQueryData_explanationDetail.serializer,
        this,
      ) as Map<String, dynamic>);

  static GExplanationDetailQueryData_explanationDetail? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GExplanationDetailQueryData_explanationDetail.serializer,
        json,
      );
}

abstract class GExplanationDetailQueryData_explanationDetail_pronunciation
    implements
        Built<GExplanationDetailQueryData_explanationDetail_pronunciation,
            GExplanationDetailQueryData_explanationDetail_pronunciationBuilder> {
  GExplanationDetailQueryData_explanationDetail_pronunciation._();

  factory GExplanationDetailQueryData_explanationDetail_pronunciation(
      [void Function(
              GExplanationDetailQueryData_explanationDetail_pronunciationBuilder
                  b)
          updates]) = _$GExplanationDetailQueryData_explanationDetail_pronunciation;

  static void _initializeBuilder(
          GExplanationDetailQueryData_explanationDetail_pronunciationBuilder
              b) =>
      b..G__typename = 'Pronunciation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get weak;
  String get strong;
  static Serializer<GExplanationDetailQueryData_explanationDetail_pronunciation>
      get serializer =>
          _$gExplanationDetailQueryDataExplanationDetailPronunciationSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GExplanationDetailQueryData_explanationDetail_pronunciation.serializer,
        this,
      ) as Map<String, dynamic>);

  static GExplanationDetailQueryData_explanationDetail_pronunciation? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GExplanationDetailQueryData_explanationDetail_pronunciation.serializer,
        json,
      );
}

abstract class GExplanationDetailQueryData_explanationDetail_similarities
    implements
        Built<GExplanationDetailQueryData_explanationDetail_similarities,
            GExplanationDetailQueryData_explanationDetail_similaritiesBuilder> {
  GExplanationDetailQueryData_explanationDetail_similarities._();

  factory GExplanationDetailQueryData_explanationDetail_similarities(
      [void Function(
              GExplanationDetailQueryData_explanationDetail_similaritiesBuilder
                  b)
          updates]) = _$GExplanationDetailQueryData_explanationDetail_similarities;

  static void _initializeBuilder(
          GExplanationDetailQueryData_explanationDetail_similaritiesBuilder
              b) =>
      b..G__typename = 'SimilarExpression';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get value;
  String get meaning;
  String get comparison;
  static Serializer<GExplanationDetailQueryData_explanationDetail_similarities>
      get serializer =>
          _$gExplanationDetailQueryDataExplanationDetailSimilaritiesSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GExplanationDetailQueryData_explanationDetail_similarities.serializer,
        this,
      ) as Map<String, dynamic>);

  static GExplanationDetailQueryData_explanationDetail_similarities? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GExplanationDetailQueryData_explanationDetail_similarities.serializer,
        json,
      );
}

abstract class GExplanationDetailQueryData_explanationDetail_senses
    implements
        Built<GExplanationDetailQueryData_explanationDetail_senses,
            GExplanationDetailQueryData_explanationDetail_sensesBuilder> {
  GExplanationDetailQueryData_explanationDetail_senses._();

  factory GExplanationDetailQueryData_explanationDetail_senses(
      [void Function(
              GExplanationDetailQueryData_explanationDetail_sensesBuilder b)
          updates]) = _$GExplanationDetailQueryData_explanationDetail_senses;

  static void _initializeBuilder(
          GExplanationDetailQueryData_explanationDetail_sensesBuilder b) =>
      b..G__typename = 'Sense';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get identifier;
  int get order;
  String get label;
  String get situation;
  String get nuance;
  BuiltList<GExplanationDetailQueryData_explanationDetail_senses_examples>
      get examples;
  BuiltList<GExplanationDetailQueryData_explanationDetail_senses_collocations>
      get collocations;
  static Serializer<GExplanationDetailQueryData_explanationDetail_senses>
      get serializer =>
          _$gExplanationDetailQueryDataExplanationDetailSensesSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GExplanationDetailQueryData_explanationDetail_senses.serializer,
        this,
      ) as Map<String, dynamic>);

  static GExplanationDetailQueryData_explanationDetail_senses? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GExplanationDetailQueryData_explanationDetail_senses.serializer,
        json,
      );
}

abstract class GExplanationDetailQueryData_explanationDetail_senses_examples
    implements
        Built<GExplanationDetailQueryData_explanationDetail_senses_examples,
            GExplanationDetailQueryData_explanationDetail_senses_examplesBuilder> {
  GExplanationDetailQueryData_explanationDetail_senses_examples._();

  factory GExplanationDetailQueryData_explanationDetail_senses_examples(
          [void Function(
                  GExplanationDetailQueryData_explanationDetail_senses_examplesBuilder
                      b)
              updates]) =
      _$GExplanationDetailQueryData_explanationDetail_senses_examples;

  static void _initializeBuilder(
          GExplanationDetailQueryData_explanationDetail_senses_examplesBuilder
              b) =>
      b..G__typename = 'SenseExample';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get value;
  String get meaning;
  String? get pronunciation;
  static Serializer<
          GExplanationDetailQueryData_explanationDetail_senses_examples>
      get serializer =>
          _$gExplanationDetailQueryDataExplanationDetailSensesExamplesSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GExplanationDetailQueryData_explanationDetail_senses_examples
            .serializer,
        this,
      ) as Map<String, dynamic>);

  static GExplanationDetailQueryData_explanationDetail_senses_examples?
      fromJson(Map<String, dynamic> json) => _i1.serializers.deserializeWith(
            GExplanationDetailQueryData_explanationDetail_senses_examples
                .serializer,
            json,
          );
}

abstract class GExplanationDetailQueryData_explanationDetail_senses_collocations
    implements
        Built<GExplanationDetailQueryData_explanationDetail_senses_collocations,
            GExplanationDetailQueryData_explanationDetail_senses_collocationsBuilder> {
  GExplanationDetailQueryData_explanationDetail_senses_collocations._();

  factory GExplanationDetailQueryData_explanationDetail_senses_collocations(
          [void Function(
                  GExplanationDetailQueryData_explanationDetail_senses_collocationsBuilder
                      b)
              updates]) =
      _$GExplanationDetailQueryData_explanationDetail_senses_collocations;

  static void _initializeBuilder(
          GExplanationDetailQueryData_explanationDetail_senses_collocationsBuilder
              b) =>
      b..G__typename = 'Collocation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get value;
  String get meaning;
  static Serializer<
          GExplanationDetailQueryData_explanationDetail_senses_collocations>
      get serializer =>
          _$gExplanationDetailQueryDataExplanationDetailSensesCollocationsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GExplanationDetailQueryData_explanationDetail_senses_collocations
            .serializer,
        this,
      ) as Map<String, dynamic>);

  static GExplanationDetailQueryData_explanationDetail_senses_collocations?
      fromJson(Map<String, dynamic> json) => _i1.serializers.deserializeWith(
            GExplanationDetailQueryData_explanationDetail_senses_collocations
                .serializer,
            json,
          );
}

abstract class GImageDetailQueryData
    implements Built<GImageDetailQueryData, GImageDetailQueryDataBuilder> {
  GImageDetailQueryData._();

  factory GImageDetailQueryData(
          [void Function(GImageDetailQueryDataBuilder b) updates]) =
      _$GImageDetailQueryData;

  static void _initializeBuilder(GImageDetailQueryDataBuilder b) =>
      b..G__typename = 'Query';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GImageDetailQueryData_imageDetail? get imageDetail;
  static Serializer<GImageDetailQueryData> get serializer =>
      _$gImageDetailQueryDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GImageDetailQueryData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GImageDetailQueryData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GImageDetailQueryData.serializer,
        json,
      );
}

abstract class GImageDetailQueryData_imageDetail
    implements
        Built<GImageDetailQueryData_imageDetail,
            GImageDetailQueryData_imageDetailBuilder> {
  GImageDetailQueryData_imageDetail._();

  factory GImageDetailQueryData_imageDetail(
          [void Function(GImageDetailQueryData_imageDetailBuilder b) updates]) =
      _$GImageDetailQueryData_imageDetail;

  static void _initializeBuilder(GImageDetailQueryData_imageDetailBuilder b) =>
      b..G__typename = 'CompletedImageDetail';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get identifier;
  String get explanation;
  String get assetReference;
  String get description;
  String? get senseIdentifier;
  String? get senseLabel;
  static Serializer<GImageDetailQueryData_imageDetail> get serializer =>
      _$gImageDetailQueryDataImageDetailSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GImageDetailQueryData_imageDetail.serializer,
        this,
      ) as Map<String, dynamic>);

  static GImageDetailQueryData_imageDetail? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GImageDetailQueryData_imageDetail.serializer,
        json,
      );
}
