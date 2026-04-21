// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:vocastock_mobile/src/infrastructure/graphql/__generated__/schema.schema.gql.dart'
    as _i1;
import 'package:vocastock_mobile/src/infrastructure/graphql/__generated__/serializers.gql.dart'
    as _i2;

part 'commands.var.gql.g.dart';

abstract class GRegisterVocabularyExpressionMutationVars
    implements
        Built<GRegisterVocabularyExpressionMutationVars,
            GRegisterVocabularyExpressionMutationVarsBuilder> {
  GRegisterVocabularyExpressionMutationVars._();

  factory GRegisterVocabularyExpressionMutationVars(
      [void Function(GRegisterVocabularyExpressionMutationVarsBuilder b)
          updates]) = _$GRegisterVocabularyExpressionMutationVars;

  _i1.GRegisterVocabularyExpressionInput get input;
  static Serializer<GRegisterVocabularyExpressionMutationVars> get serializer =>
      _$gRegisterVocabularyExpressionMutationVarsSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GRegisterVocabularyExpressionMutationVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRegisterVocabularyExpressionMutationVars? fromJson(
          Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GRegisterVocabularyExpressionMutationVars.serializer,
        json,
      );
}

abstract class GRequestExplanationGenerationMutationVars
    implements
        Built<GRequestExplanationGenerationMutationVars,
            GRequestExplanationGenerationMutationVarsBuilder> {
  GRequestExplanationGenerationMutationVars._();

  factory GRequestExplanationGenerationMutationVars(
      [void Function(GRequestExplanationGenerationMutationVarsBuilder b)
          updates]) = _$GRequestExplanationGenerationMutationVars;

  _i1.GRequestGenerationInput get input;
  static Serializer<GRequestExplanationGenerationMutationVars> get serializer =>
      _$gRequestExplanationGenerationMutationVarsSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GRequestExplanationGenerationMutationVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRequestExplanationGenerationMutationVars? fromJson(
          Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GRequestExplanationGenerationMutationVars.serializer,
        json,
      );
}

abstract class GRequestImageGenerationMutationVars
    implements
        Built<GRequestImageGenerationMutationVars,
            GRequestImageGenerationMutationVarsBuilder> {
  GRequestImageGenerationMutationVars._();

  factory GRequestImageGenerationMutationVars(
      [void Function(GRequestImageGenerationMutationVarsBuilder b)
          updates]) = _$GRequestImageGenerationMutationVars;

  _i1.GRequestGenerationInput get input;
  static Serializer<GRequestImageGenerationMutationVars> get serializer =>
      _$gRequestImageGenerationMutationVarsSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GRequestImageGenerationMutationVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRequestImageGenerationMutationVars? fromJson(
          Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GRequestImageGenerationMutationVars.serializer,
        json,
      );
}

abstract class GRetryGenerationMutationVars
    implements
        Built<GRetryGenerationMutationVars,
            GRetryGenerationMutationVarsBuilder> {
  GRetryGenerationMutationVars._();

  factory GRetryGenerationMutationVars(
          [void Function(GRetryGenerationMutationVarsBuilder b) updates]) =
      _$GRetryGenerationMutationVars;

  _i1.GRetryGenerationInput get input;
  static Serializer<GRetryGenerationMutationVars> get serializer =>
      _$gRetryGenerationMutationVarsSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GRetryGenerationMutationVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRetryGenerationMutationVars? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GRetryGenerationMutationVars.serializer,
        json,
      );
}
