// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:vocastock_mobile/src/infrastructure/graphql/__generated__/serializers.gql.dart'
    as _i1;

part 'actor_handoff.var.gql.g.dart';

abstract class GActorHandoffStatusQueryVars
    implements
        Built<GActorHandoffStatusQueryVars,
            GActorHandoffStatusQueryVarsBuilder> {
  GActorHandoffStatusQueryVars._();

  factory GActorHandoffStatusQueryVars(
          [void Function(GActorHandoffStatusQueryVarsBuilder b) updates]) =
      _$GActorHandoffStatusQueryVars;

  static Serializer<GActorHandoffStatusQueryVars> get serializer =>
      _$gActorHandoffStatusQueryVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GActorHandoffStatusQueryVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GActorHandoffStatusQueryVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GActorHandoffStatusQueryVars.serializer,
        json,
      );
}

abstract class GLearningStateQueryVars
    implements Built<GLearningStateQueryVars, GLearningStateQueryVarsBuilder> {
  GLearningStateQueryVars._();

  factory GLearningStateQueryVars(
          [void Function(GLearningStateQueryVarsBuilder b) updates]) =
      _$GLearningStateQueryVars;

  String get identifier;
  static Serializer<GLearningStateQueryVars> get serializer =>
      _$gLearningStateQueryVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GLearningStateQueryVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GLearningStateQueryVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GLearningStateQueryVars.serializer,
        json,
      );
}
