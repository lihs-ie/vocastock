// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:vocastock_mobile/src/infrastructure/graphql/__generated__/schema.schema.gql.dart'
    as _i2;
import 'package:vocastock_mobile/src/infrastructure/graphql/__generated__/serializers.gql.dart'
    as _i1;

part 'commands.data.gql.g.dart';

abstract class GRegisterVocabularyExpressionMutationData
    implements
        Built<GRegisterVocabularyExpressionMutationData,
            GRegisterVocabularyExpressionMutationDataBuilder> {
  GRegisterVocabularyExpressionMutationData._();

  factory GRegisterVocabularyExpressionMutationData(
      [void Function(GRegisterVocabularyExpressionMutationDataBuilder b)
          updates]) = _$GRegisterVocabularyExpressionMutationData;

  static void _initializeBuilder(
          GRegisterVocabularyExpressionMutationDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GRegisterVocabularyExpressionMutationData_registerVocabularyExpression
      get registerVocabularyExpression;
  static Serializer<GRegisterVocabularyExpressionMutationData> get serializer =>
      _$gRegisterVocabularyExpressionMutationDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GRegisterVocabularyExpressionMutationData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRegisterVocabularyExpressionMutationData? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GRegisterVocabularyExpressionMutationData.serializer,
        json,
      );
}

abstract class GRegisterVocabularyExpressionMutationData_registerVocabularyExpression
    implements
        Built<
            GRegisterVocabularyExpressionMutationData_registerVocabularyExpression,
            GRegisterVocabularyExpressionMutationData_registerVocabularyExpressionBuilder> {
  GRegisterVocabularyExpressionMutationData_registerVocabularyExpression._();

  factory GRegisterVocabularyExpressionMutationData_registerVocabularyExpression(
          [void Function(
                  GRegisterVocabularyExpressionMutationData_registerVocabularyExpressionBuilder
                      b)
              updates]) =
      _$GRegisterVocabularyExpressionMutationData_registerVocabularyExpression;

  static void _initializeBuilder(
          GRegisterVocabularyExpressionMutationData_registerVocabularyExpressionBuilder
              b) =>
      b..G__typename = 'CommandResponseEnvelope';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  bool get accepted;
  _i2.GAcceptanceOutcome? get outcome;
  _i2.GCommandErrorCategory? get errorCategory;
  GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message
      get message;
  static Serializer<
          GRegisterVocabularyExpressionMutationData_registerVocabularyExpression>
      get serializer =>
          _$gRegisterVocabularyExpressionMutationDataRegisterVocabularyExpressionSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GRegisterVocabularyExpressionMutationData_registerVocabularyExpression
            .serializer,
        this,
      ) as Map<String, dynamic>);

  static GRegisterVocabularyExpressionMutationData_registerVocabularyExpression?
      fromJson(Map<String, dynamic> json) => _i1.serializers.deserializeWith(
            GRegisterVocabularyExpressionMutationData_registerVocabularyExpression
                .serializer,
            json,
          );
}

abstract class GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message
    implements
        Built<
            GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message,
            GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_messageBuilder> {
  GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message._();

  factory GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message(
          [void Function(
                  GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_messageBuilder
                      b)
              updates]) =
      _$GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message;

  static void _initializeBuilder(
          GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_messageBuilder
              b) =>
      b..G__typename = 'UserFacingMessage';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get key;
  String get text;
  static Serializer<
          GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message>
      get serializer =>
          _$gRegisterVocabularyExpressionMutationDataRegisterVocabularyExpressionMessageSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message
            .serializer,
        this,
      ) as Map<String, dynamic>);

  static GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message?
      fromJson(Map<String, dynamic> json) => _i1.serializers.deserializeWith(
            GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message
                .serializer,
            json,
          );
}

abstract class GRequestExplanationGenerationMutationData
    implements
        Built<GRequestExplanationGenerationMutationData,
            GRequestExplanationGenerationMutationDataBuilder> {
  GRequestExplanationGenerationMutationData._();

  factory GRequestExplanationGenerationMutationData(
      [void Function(GRequestExplanationGenerationMutationDataBuilder b)
          updates]) = _$GRequestExplanationGenerationMutationData;

  static void _initializeBuilder(
          GRequestExplanationGenerationMutationDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GRequestExplanationGenerationMutationData_requestExplanationGeneration
      get requestExplanationGeneration;
  static Serializer<GRequestExplanationGenerationMutationData> get serializer =>
      _$gRequestExplanationGenerationMutationDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GRequestExplanationGenerationMutationData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRequestExplanationGenerationMutationData? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GRequestExplanationGenerationMutationData.serializer,
        json,
      );
}

abstract class GRequestExplanationGenerationMutationData_requestExplanationGeneration
    implements
        Built<
            GRequestExplanationGenerationMutationData_requestExplanationGeneration,
            GRequestExplanationGenerationMutationData_requestExplanationGenerationBuilder> {
  GRequestExplanationGenerationMutationData_requestExplanationGeneration._();

  factory GRequestExplanationGenerationMutationData_requestExplanationGeneration(
          [void Function(
                  GRequestExplanationGenerationMutationData_requestExplanationGenerationBuilder
                      b)
              updates]) =
      _$GRequestExplanationGenerationMutationData_requestExplanationGeneration;

  static void _initializeBuilder(
          GRequestExplanationGenerationMutationData_requestExplanationGenerationBuilder
              b) =>
      b..G__typename = 'CommandResponseEnvelope';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  bool get accepted;
  _i2.GAcceptanceOutcome? get outcome;
  _i2.GCommandErrorCategory? get errorCategory;
  GRequestExplanationGenerationMutationData_requestExplanationGeneration_message
      get message;
  static Serializer<
          GRequestExplanationGenerationMutationData_requestExplanationGeneration>
      get serializer =>
          _$gRequestExplanationGenerationMutationDataRequestExplanationGenerationSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GRequestExplanationGenerationMutationData_requestExplanationGeneration
            .serializer,
        this,
      ) as Map<String, dynamic>);

  static GRequestExplanationGenerationMutationData_requestExplanationGeneration?
      fromJson(Map<String, dynamic> json) => _i1.serializers.deserializeWith(
            GRequestExplanationGenerationMutationData_requestExplanationGeneration
                .serializer,
            json,
          );
}

abstract class GRequestExplanationGenerationMutationData_requestExplanationGeneration_message
    implements
        Built<
            GRequestExplanationGenerationMutationData_requestExplanationGeneration_message,
            GRequestExplanationGenerationMutationData_requestExplanationGeneration_messageBuilder> {
  GRequestExplanationGenerationMutationData_requestExplanationGeneration_message._();

  factory GRequestExplanationGenerationMutationData_requestExplanationGeneration_message(
          [void Function(
                  GRequestExplanationGenerationMutationData_requestExplanationGeneration_messageBuilder
                      b)
              updates]) =
      _$GRequestExplanationGenerationMutationData_requestExplanationGeneration_message;

  static void _initializeBuilder(
          GRequestExplanationGenerationMutationData_requestExplanationGeneration_messageBuilder
              b) =>
      b..G__typename = 'UserFacingMessage';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get key;
  String get text;
  static Serializer<
          GRequestExplanationGenerationMutationData_requestExplanationGeneration_message>
      get serializer =>
          _$gRequestExplanationGenerationMutationDataRequestExplanationGenerationMessageSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GRequestExplanationGenerationMutationData_requestExplanationGeneration_message
            .serializer,
        this,
      ) as Map<String, dynamic>);

  static GRequestExplanationGenerationMutationData_requestExplanationGeneration_message?
      fromJson(Map<String, dynamic> json) => _i1.serializers.deserializeWith(
            GRequestExplanationGenerationMutationData_requestExplanationGeneration_message
                .serializer,
            json,
          );
}

abstract class GRequestImageGenerationMutationData
    implements
        Built<GRequestImageGenerationMutationData,
            GRequestImageGenerationMutationDataBuilder> {
  GRequestImageGenerationMutationData._();

  factory GRequestImageGenerationMutationData(
      [void Function(GRequestImageGenerationMutationDataBuilder b)
          updates]) = _$GRequestImageGenerationMutationData;

  static void _initializeBuilder(
          GRequestImageGenerationMutationDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GRequestImageGenerationMutationData_requestImageGeneration
      get requestImageGeneration;
  static Serializer<GRequestImageGenerationMutationData> get serializer =>
      _$gRequestImageGenerationMutationDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GRequestImageGenerationMutationData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRequestImageGenerationMutationData? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GRequestImageGenerationMutationData.serializer,
        json,
      );
}

abstract class GRequestImageGenerationMutationData_requestImageGeneration
    implements
        Built<GRequestImageGenerationMutationData_requestImageGeneration,
            GRequestImageGenerationMutationData_requestImageGenerationBuilder> {
  GRequestImageGenerationMutationData_requestImageGeneration._();

  factory GRequestImageGenerationMutationData_requestImageGeneration(
      [void Function(
              GRequestImageGenerationMutationData_requestImageGenerationBuilder
                  b)
          updates]) = _$GRequestImageGenerationMutationData_requestImageGeneration;

  static void _initializeBuilder(
          GRequestImageGenerationMutationData_requestImageGenerationBuilder
              b) =>
      b..G__typename = 'CommandResponseEnvelope';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  bool get accepted;
  _i2.GAcceptanceOutcome? get outcome;
  _i2.GCommandErrorCategory? get errorCategory;
  GRequestImageGenerationMutationData_requestImageGeneration_message
      get message;
  static Serializer<GRequestImageGenerationMutationData_requestImageGeneration>
      get serializer =>
          _$gRequestImageGenerationMutationDataRequestImageGenerationSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GRequestImageGenerationMutationData_requestImageGeneration.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRequestImageGenerationMutationData_requestImageGeneration? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GRequestImageGenerationMutationData_requestImageGeneration.serializer,
        json,
      );
}

abstract class GRequestImageGenerationMutationData_requestImageGeneration_message
    implements
        Built<
            GRequestImageGenerationMutationData_requestImageGeneration_message,
            GRequestImageGenerationMutationData_requestImageGeneration_messageBuilder> {
  GRequestImageGenerationMutationData_requestImageGeneration_message._();

  factory GRequestImageGenerationMutationData_requestImageGeneration_message(
          [void Function(
                  GRequestImageGenerationMutationData_requestImageGeneration_messageBuilder
                      b)
              updates]) =
      _$GRequestImageGenerationMutationData_requestImageGeneration_message;

  static void _initializeBuilder(
          GRequestImageGenerationMutationData_requestImageGeneration_messageBuilder
              b) =>
      b..G__typename = 'UserFacingMessage';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get key;
  String get text;
  static Serializer<
          GRequestImageGenerationMutationData_requestImageGeneration_message>
      get serializer =>
          _$gRequestImageGenerationMutationDataRequestImageGenerationMessageSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GRequestImageGenerationMutationData_requestImageGeneration_message
            .serializer,
        this,
      ) as Map<String, dynamic>);

  static GRequestImageGenerationMutationData_requestImageGeneration_message?
      fromJson(Map<String, dynamic> json) => _i1.serializers.deserializeWith(
            GRequestImageGenerationMutationData_requestImageGeneration_message
                .serializer,
            json,
          );
}

abstract class GRetryGenerationMutationData
    implements
        Built<GRetryGenerationMutationData,
            GRetryGenerationMutationDataBuilder> {
  GRetryGenerationMutationData._();

  factory GRetryGenerationMutationData(
          [void Function(GRetryGenerationMutationDataBuilder b) updates]) =
      _$GRetryGenerationMutationData;

  static void _initializeBuilder(GRetryGenerationMutationDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GRetryGenerationMutationData_retryGeneration get retryGeneration;
  static Serializer<GRetryGenerationMutationData> get serializer =>
      _$gRetryGenerationMutationDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GRetryGenerationMutationData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRetryGenerationMutationData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GRetryGenerationMutationData.serializer,
        json,
      );
}

abstract class GRetryGenerationMutationData_retryGeneration
    implements
        Built<GRetryGenerationMutationData_retryGeneration,
            GRetryGenerationMutationData_retryGenerationBuilder> {
  GRetryGenerationMutationData_retryGeneration._();

  factory GRetryGenerationMutationData_retryGeneration(
      [void Function(GRetryGenerationMutationData_retryGenerationBuilder b)
          updates]) = _$GRetryGenerationMutationData_retryGeneration;

  static void _initializeBuilder(
          GRetryGenerationMutationData_retryGenerationBuilder b) =>
      b..G__typename = 'CommandResponseEnvelope';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  bool get accepted;
  _i2.GAcceptanceOutcome? get outcome;
  _i2.GCommandErrorCategory? get errorCategory;
  GRetryGenerationMutationData_retryGeneration_message get message;
  static Serializer<GRetryGenerationMutationData_retryGeneration>
      get serializer => _$gRetryGenerationMutationDataRetryGenerationSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GRetryGenerationMutationData_retryGeneration.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRetryGenerationMutationData_retryGeneration? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GRetryGenerationMutationData_retryGeneration.serializer,
        json,
      );
}

abstract class GRetryGenerationMutationData_retryGeneration_message
    implements
        Built<GRetryGenerationMutationData_retryGeneration_message,
            GRetryGenerationMutationData_retryGeneration_messageBuilder> {
  GRetryGenerationMutationData_retryGeneration_message._();

  factory GRetryGenerationMutationData_retryGeneration_message(
      [void Function(
              GRetryGenerationMutationData_retryGeneration_messageBuilder b)
          updates]) = _$GRetryGenerationMutationData_retryGeneration_message;

  static void _initializeBuilder(
          GRetryGenerationMutationData_retryGeneration_messageBuilder b) =>
      b..G__typename = 'UserFacingMessage';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get key;
  String get text;
  static Serializer<GRetryGenerationMutationData_retryGeneration_message>
      get serializer =>
          _$gRetryGenerationMutationDataRetryGenerationMessageSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GRetryGenerationMutationData_retryGeneration_message.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRetryGenerationMutationData_retryGeneration_message? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GRetryGenerationMutationData_retryGeneration_message.serializer,
        json,
      );
}
