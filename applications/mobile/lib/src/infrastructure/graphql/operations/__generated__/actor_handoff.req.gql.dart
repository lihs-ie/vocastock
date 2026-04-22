// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:vocastock_mobile/src/infrastructure/graphql/__generated__/serializers.gql.dart'
    as _i6;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/actor_handoff.ast.gql.dart'
    as _i5;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/actor_handoff.data.gql.dart'
    as _i2;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/actor_handoff.var.gql.dart'
    as _i3;

part 'actor_handoff.req.gql.g.dart';

abstract class GActorHandoffStatusQueryReq
    implements
        Built<GActorHandoffStatusQueryReq, GActorHandoffStatusQueryReqBuilder>,
        _i1.OperationRequest<_i2.GActorHandoffStatusQueryData,
            _i3.GActorHandoffStatusQueryVars> {
  GActorHandoffStatusQueryReq._();

  factory GActorHandoffStatusQueryReq(
          [void Function(GActorHandoffStatusQueryReqBuilder b) updates]) =
      _$GActorHandoffStatusQueryReq;

  static void _initializeBuilder(GActorHandoffStatusQueryReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'ActorHandoffStatusQuery',
    )
    ..executeOnListen = true;

  @override
  _i3.GActorHandoffStatusQueryVars get vars;
  @override
  _i4.Operation get operation;
  @override
  _i4.Request get execRequest => _i4.Request(
        operation: operation,
        variables: vars.toJson(),
        context: context ?? const _i4.Context(),
      );

  @override
  String? get requestId;
  @override
  @BuiltValueField(serialize: false)
  _i2.GActorHandoffStatusQueryData? Function(
    _i2.GActorHandoffStatusQueryData?,
    _i2.GActorHandoffStatusQueryData?,
  )? get updateResult;
  @override
  _i2.GActorHandoffStatusQueryData? get optimisticResponse;
  @override
  String? get updateCacheHandlerKey;
  @override
  Map<String, dynamic>? get updateCacheHandlerContext;
  @override
  _i1.FetchPolicy? get fetchPolicy;
  @override
  bool get executeOnListen;
  @override
  @BuiltValueField(serialize: false)
  _i4.Context? get context;
  @override
  _i2.GActorHandoffStatusQueryData? parseData(Map<String, dynamic> json) =>
      _i2.GActorHandoffStatusQueryData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GActorHandoffStatusQueryData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GActorHandoffStatusQueryData,
      _i3.GActorHandoffStatusQueryVars> transformOperation(
          _i4.Operation Function(_i4.Operation) transform) =>
      this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GActorHandoffStatusQueryReq> get serializer =>
      _$gActorHandoffStatusQueryReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GActorHandoffStatusQueryReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GActorHandoffStatusQueryReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GActorHandoffStatusQueryReq.serializer,
        json,
      );
}

abstract class GLearningStateQueryReq
    implements
        Built<GLearningStateQueryReq, GLearningStateQueryReqBuilder>,
        _i1.OperationRequest<_i2.GLearningStateQueryData,
            _i3.GLearningStateQueryVars> {
  GLearningStateQueryReq._();

  factory GLearningStateQueryReq(
          [void Function(GLearningStateQueryReqBuilder b) updates]) =
      _$GLearningStateQueryReq;

  static void _initializeBuilder(GLearningStateQueryReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'LearningStateQuery',
    )
    ..executeOnListen = true;

  @override
  _i3.GLearningStateQueryVars get vars;
  @override
  _i4.Operation get operation;
  @override
  _i4.Request get execRequest => _i4.Request(
        operation: operation,
        variables: vars.toJson(),
        context: context ?? const _i4.Context(),
      );

  @override
  String? get requestId;
  @override
  @BuiltValueField(serialize: false)
  _i2.GLearningStateQueryData? Function(
    _i2.GLearningStateQueryData?,
    _i2.GLearningStateQueryData?,
  )? get updateResult;
  @override
  _i2.GLearningStateQueryData? get optimisticResponse;
  @override
  String? get updateCacheHandlerKey;
  @override
  Map<String, dynamic>? get updateCacheHandlerContext;
  @override
  _i1.FetchPolicy? get fetchPolicy;
  @override
  bool get executeOnListen;
  @override
  @BuiltValueField(serialize: false)
  _i4.Context? get context;
  @override
  _i2.GLearningStateQueryData? parseData(Map<String, dynamic> json) =>
      _i2.GLearningStateQueryData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GLearningStateQueryData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GLearningStateQueryData, _i3.GLearningStateQueryVars>
      transformOperation(_i4.Operation Function(_i4.Operation) transform) =>
          this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GLearningStateQueryReq> get serializer =>
      _$gLearningStateQueryReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GLearningStateQueryReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GLearningStateQueryReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GLearningStateQueryReq.serializer,
        json,
      );
}
