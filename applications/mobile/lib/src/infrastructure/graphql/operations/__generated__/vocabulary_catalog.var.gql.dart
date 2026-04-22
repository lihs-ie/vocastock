// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:vocastock_mobile/src/infrastructure/graphql/__generated__/serializers.gql.dart'
    as _i1;

part 'vocabulary_catalog.var.gql.g.dart';

abstract class GVocabularyCatalogQueryVars
    implements
        Built<GVocabularyCatalogQueryVars, GVocabularyCatalogQueryVarsBuilder> {
  GVocabularyCatalogQueryVars._();

  factory GVocabularyCatalogQueryVars(
          [void Function(GVocabularyCatalogQueryVarsBuilder b) updates]) =
      _$GVocabularyCatalogQueryVars;

  static Serializer<GVocabularyCatalogQueryVars> get serializer =>
      _$gVocabularyCatalogQueryVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GVocabularyCatalogQueryVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GVocabularyCatalogQueryVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GVocabularyCatalogQueryVars.serializer,
        json,
      );
}

abstract class GVocabularyExpressionDetailQueryVars
    implements
        Built<GVocabularyExpressionDetailQueryVars,
            GVocabularyExpressionDetailQueryVarsBuilder> {
  GVocabularyExpressionDetailQueryVars._();

  factory GVocabularyExpressionDetailQueryVars(
      [void Function(GVocabularyExpressionDetailQueryVarsBuilder b)
          updates]) = _$GVocabularyExpressionDetailQueryVars;

  String get identifier;
  static Serializer<GVocabularyExpressionDetailQueryVars> get serializer =>
      _$gVocabularyExpressionDetailQueryVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GVocabularyExpressionDetailQueryVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GVocabularyExpressionDetailQueryVars? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GVocabularyExpressionDetailQueryVars.serializer,
        json,
      );
}
