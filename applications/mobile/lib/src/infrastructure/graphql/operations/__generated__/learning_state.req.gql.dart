// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:vocastock_mobile/src/infrastructure/graphql/__generated__/serializers.gql.dart'
    as _i6;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/learning_state.ast.gql.dart'
    as _i5;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/learning_state.data.gql.dart'
    as _i2;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/learning_state.var.gql.dart'
    as _i3;

part 'learning_state.req.gql.g.dart';

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

abstract class GLearningStatesQueryReq
    implements
        Built<GLearningStatesQueryReq, GLearningStatesQueryReqBuilder>,
        _i1.OperationRequest<_i2.GLearningStatesQueryData,
            _i3.GLearningStatesQueryVars> {
  GLearningStatesQueryReq._();

  factory GLearningStatesQueryReq(
          [void Function(GLearningStatesQueryReqBuilder b) updates]) =
      _$GLearningStatesQueryReq;

  static void _initializeBuilder(GLearningStatesQueryReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'LearningStatesQuery',
    )
    ..executeOnListen = true;

  @override
  _i3.GLearningStatesQueryVars get vars;
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
  _i2.GLearningStatesQueryData? Function(
    _i2.GLearningStatesQueryData?,
    _i2.GLearningStatesQueryData?,
  )? get updateResult;
  @override
  _i2.GLearningStatesQueryData? get optimisticResponse;
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
  _i2.GLearningStatesQueryData? parseData(Map<String, dynamic> json) =>
      _i2.GLearningStatesQueryData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GLearningStatesQueryData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GLearningStatesQueryData,
      _i3.GLearningStatesQueryVars> transformOperation(
          _i4.Operation Function(_i4.Operation) transform) =>
      this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GLearningStatesQueryReq> get serializer =>
      _$gLearningStatesQueryReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GLearningStatesQueryReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GLearningStatesQueryReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GLearningStatesQueryReq.serializer,
        json,
      );
}
