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

part 'vocabulary_catalog.data.gql.g.dart';

abstract class GVocabularyCatalogQueryData
    implements
        Built<GVocabularyCatalogQueryData, GVocabularyCatalogQueryDataBuilder> {
  GVocabularyCatalogQueryData._();

  factory GVocabularyCatalogQueryData(
          [void Function(GVocabularyCatalogQueryDataBuilder b) updates]) =
      _$GVocabularyCatalogQueryData;

  static void _initializeBuilder(GVocabularyCatalogQueryDataBuilder b) =>
      b..G__typename = 'Query';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GVocabularyCatalogQueryData_vocabularyCatalog get vocabularyCatalog;
  static Serializer<GVocabularyCatalogQueryData> get serializer =>
      _$gVocabularyCatalogQueryDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GVocabularyCatalogQueryData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GVocabularyCatalogQueryData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GVocabularyCatalogQueryData.serializer,
        json,
      );
}

abstract class GVocabularyCatalogQueryData_vocabularyCatalog
    implements
        Built<GVocabularyCatalogQueryData_vocabularyCatalog,
            GVocabularyCatalogQueryData_vocabularyCatalogBuilder> {
  GVocabularyCatalogQueryData_vocabularyCatalog._();

  factory GVocabularyCatalogQueryData_vocabularyCatalog(
      [void Function(GVocabularyCatalogQueryData_vocabularyCatalogBuilder b)
          updates]) = _$GVocabularyCatalogQueryData_vocabularyCatalog;

  static void _initializeBuilder(
          GVocabularyCatalogQueryData_vocabularyCatalogBuilder b) =>
      b..G__typename = 'VocabularyCatalog';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  BuiltList<GVocabularyCatalogQueryData_vocabularyCatalog_entries> get entries;
  static Serializer<GVocabularyCatalogQueryData_vocabularyCatalog>
      get serializer =>
          _$gVocabularyCatalogQueryDataVocabularyCatalogSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GVocabularyCatalogQueryData_vocabularyCatalog.serializer,
        this,
      ) as Map<String, dynamic>);

  static GVocabularyCatalogQueryData_vocabularyCatalog? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GVocabularyCatalogQueryData_vocabularyCatalog.serializer,
        json,
      );
}

abstract class GVocabularyCatalogQueryData_vocabularyCatalog_entries
    implements
        Built<GVocabularyCatalogQueryData_vocabularyCatalog_entries,
            GVocabularyCatalogQueryData_vocabularyCatalog_entriesBuilder> {
  GVocabularyCatalogQueryData_vocabularyCatalog_entries._();

  factory GVocabularyCatalogQueryData_vocabularyCatalog_entries(
      [void Function(
              GVocabularyCatalogQueryData_vocabularyCatalog_entriesBuilder b)
          updates]) = _$GVocabularyCatalogQueryData_vocabularyCatalog_entries;

  static void _initializeBuilder(
          GVocabularyCatalogQueryData_vocabularyCatalog_entriesBuilder b) =>
      b..G__typename = 'VocabularyExpressionEntry';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get identifier;
  String get text;
  _i2.GRegistrationStatus get registrationStatus;
  _i2.GExplanationGenerationStatus get explanationStatus;
  _i2.GImageGenerationStatus get imageStatus;
  String? get currentExplanation;
  String? get currentImage;
  _i2.GDateTime get registeredAt;
  static Serializer<GVocabularyCatalogQueryData_vocabularyCatalog_entries>
      get serializer =>
          _$gVocabularyCatalogQueryDataVocabularyCatalogEntriesSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GVocabularyCatalogQueryData_vocabularyCatalog_entries.serializer,
        this,
      ) as Map<String, dynamic>);

  static GVocabularyCatalogQueryData_vocabularyCatalog_entries? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GVocabularyCatalogQueryData_vocabularyCatalog_entries.serializer,
        json,
      );
}

abstract class GVocabularyExpressionDetailQueryData
    implements
        Built<GVocabularyExpressionDetailQueryData,
            GVocabularyExpressionDetailQueryDataBuilder> {
  GVocabularyExpressionDetailQueryData._();

  factory GVocabularyExpressionDetailQueryData(
      [void Function(GVocabularyExpressionDetailQueryDataBuilder b)
          updates]) = _$GVocabularyExpressionDetailQueryData;

  static void _initializeBuilder(
          GVocabularyExpressionDetailQueryDataBuilder b) =>
      b..G__typename = 'Query';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail?
      get vocabularyExpressionDetail;
  static Serializer<GVocabularyExpressionDetailQueryData> get serializer =>
      _$gVocabularyExpressionDetailQueryDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GVocabularyExpressionDetailQueryData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GVocabularyExpressionDetailQueryData? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GVocabularyExpressionDetailQueryData.serializer,
        json,
      );
}

abstract class GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail
    implements
        Built<GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail,
            GVocabularyExpressionDetailQueryData_vocabularyExpressionDetailBuilder> {
  GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail._();

  factory GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail(
          [void Function(
                  GVocabularyExpressionDetailQueryData_vocabularyExpressionDetailBuilder
                      b)
              updates]) =
      _$GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail;

  static void _initializeBuilder(
          GVocabularyExpressionDetailQueryData_vocabularyExpressionDetailBuilder
              b) =>
      b..G__typename = 'VocabularyExpressionEntry';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get identifier;
  String get text;
  _i2.GRegistrationStatus get registrationStatus;
  _i2.GExplanationGenerationStatus get explanationStatus;
  _i2.GImageGenerationStatus get imageStatus;
  String? get currentExplanation;
  String? get currentImage;
  _i2.GDateTime get registeredAt;
  static Serializer<
          GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail>
      get serializer =>
          _$gVocabularyExpressionDetailQueryDataVocabularyExpressionDetailSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail
            .serializer,
        this,
      ) as Map<String, dynamic>);

  static GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail?
      fromJson(Map<String, dynamic> json) => _i1.serializers.deserializeWith(
            GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail
                .serializer,
            json,
          );
}
