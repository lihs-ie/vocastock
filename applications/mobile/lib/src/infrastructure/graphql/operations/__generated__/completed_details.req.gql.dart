// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:vocastock_mobile/src/infrastructure/graphql/__generated__/serializers.gql.dart'
    as _i6;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/completed_details.ast.gql.dart'
    as _i5;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/completed_details.data.gql.dart'
    as _i2;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/completed_details.var.gql.dart'
    as _i3;

part 'completed_details.req.gql.g.dart';

abstract class GExplanationDetailQueryReq
    implements
        Built<GExplanationDetailQueryReq, GExplanationDetailQueryReqBuilder>,
        _i1.OperationRequest<_i2.GExplanationDetailQueryData,
            _i3.GExplanationDetailQueryVars> {
  GExplanationDetailQueryReq._();

  factory GExplanationDetailQueryReq(
          [void Function(GExplanationDetailQueryReqBuilder b) updates]) =
      _$GExplanationDetailQueryReq;

  static void _initializeBuilder(GExplanationDetailQueryReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'ExplanationDetailQuery',
    )
    ..executeOnListen = true;

  @override
  _i3.GExplanationDetailQueryVars get vars;
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
  _i2.GExplanationDetailQueryData? Function(
    _i2.GExplanationDetailQueryData?,
    _i2.GExplanationDetailQueryData?,
  )? get updateResult;
  @override
  _i2.GExplanationDetailQueryData? get optimisticResponse;
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
  _i2.GExplanationDetailQueryData? parseData(Map<String, dynamic> json) =>
      _i2.GExplanationDetailQueryData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GExplanationDetailQueryData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GExplanationDetailQueryData,
      _i3.GExplanationDetailQueryVars> transformOperation(
          _i4.Operation Function(_i4.Operation) transform) =>
      this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GExplanationDetailQueryReq> get serializer =>
      _$gExplanationDetailQueryReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GExplanationDetailQueryReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GExplanationDetailQueryReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GExplanationDetailQueryReq.serializer,
        json,
      );
}

abstract class GImageDetailQueryReq
    implements
        Built<GImageDetailQueryReq, GImageDetailQueryReqBuilder>,
        _i1.OperationRequest<_i2.GImageDetailQueryData,
            _i3.GImageDetailQueryVars> {
  GImageDetailQueryReq._();

  factory GImageDetailQueryReq(
          [void Function(GImageDetailQueryReqBuilder b) updates]) =
      _$GImageDetailQueryReq;

  static void _initializeBuilder(GImageDetailQueryReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'ImageDetailQuery',
    )
    ..executeOnListen = true;

  @override
  _i3.GImageDetailQueryVars get vars;
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
  _i2.GImageDetailQueryData? Function(
    _i2.GImageDetailQueryData?,
    _i2.GImageDetailQueryData?,
  )? get updateResult;
  @override
  _i2.GImageDetailQueryData? get optimisticResponse;
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
  _i2.GImageDetailQueryData? parseData(Map<String, dynamic> json) =>
      _i2.GImageDetailQueryData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GImageDetailQueryData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GImageDetailQueryData, _i3.GImageDetailQueryVars>
      transformOperation(_i4.Operation Function(_i4.Operation) transform) =>
          this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GImageDetailQueryReq> get serializer =>
      _$gImageDetailQueryReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GImageDetailQueryReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GImageDetailQueryReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GImageDetailQueryReq.serializer,
        json,
      );
}
