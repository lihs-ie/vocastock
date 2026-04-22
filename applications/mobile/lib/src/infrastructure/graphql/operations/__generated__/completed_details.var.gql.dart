// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:vocastock_mobile/src/infrastructure/graphql/__generated__/serializers.gql.dart'
    as _i1;

part 'completed_details.var.gql.g.dart';

abstract class GExplanationDetailQueryVars
    implements
        Built<GExplanationDetailQueryVars, GExplanationDetailQueryVarsBuilder> {
  GExplanationDetailQueryVars._();

  factory GExplanationDetailQueryVars(
          [void Function(GExplanationDetailQueryVarsBuilder b) updates]) =
      _$GExplanationDetailQueryVars;

  String get identifier;
  static Serializer<GExplanationDetailQueryVars> get serializer =>
      _$gExplanationDetailQueryVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GExplanationDetailQueryVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GExplanationDetailQueryVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GExplanationDetailQueryVars.serializer,
        json,
      );
}

abstract class GImageDetailQueryVars
    implements Built<GImageDetailQueryVars, GImageDetailQueryVarsBuilder> {
  GImageDetailQueryVars._();

  factory GImageDetailQueryVars(
          [void Function(GImageDetailQueryVarsBuilder b) updates]) =
      _$GImageDetailQueryVars;

  String get identifier;
  static Serializer<GImageDetailQueryVars> get serializer =>
      _$gImageDetailQueryVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GImageDetailQueryVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GImageDetailQueryVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GImageDetailQueryVars.serializer,
        json,
      );
}
