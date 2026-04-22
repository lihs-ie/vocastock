// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:vocastock_mobile/src/infrastructure/graphql/__generated__/serializers.gql.dart'
    as _i6;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/subscription.ast.gql.dart'
    as _i5;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/subscription.data.gql.dart'
    as _i2;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/subscription.var.gql.dart'
    as _i3;

part 'subscription.req.gql.g.dart';

abstract class GSubscriptionStatusQueryReq
    implements
        Built<GSubscriptionStatusQueryReq, GSubscriptionStatusQueryReqBuilder>,
        _i1.OperationRequest<_i2.GSubscriptionStatusQueryData,
            _i3.GSubscriptionStatusQueryVars> {
  GSubscriptionStatusQueryReq._();

  factory GSubscriptionStatusQueryReq(
          [void Function(GSubscriptionStatusQueryReqBuilder b) updates]) =
      _$GSubscriptionStatusQueryReq;

  static void _initializeBuilder(GSubscriptionStatusQueryReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'SubscriptionStatusQuery',
    )
    ..executeOnListen = true;

  @override
  _i3.GSubscriptionStatusQueryVars get vars;
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
  _i2.GSubscriptionStatusQueryData? Function(
    _i2.GSubscriptionStatusQueryData?,
    _i2.GSubscriptionStatusQueryData?,
  )? get updateResult;
  @override
  _i2.GSubscriptionStatusQueryData? get optimisticResponse;
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
  _i2.GSubscriptionStatusQueryData? parseData(Map<String, dynamic> json) =>
      _i2.GSubscriptionStatusQueryData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GSubscriptionStatusQueryData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GSubscriptionStatusQueryData,
      _i3.GSubscriptionStatusQueryVars> transformOperation(
          _i4.Operation Function(_i4.Operation) transform) =>
      this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GSubscriptionStatusQueryReq> get serializer =>
      _$gSubscriptionStatusQueryReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GSubscriptionStatusQueryReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSubscriptionStatusQueryReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GSubscriptionStatusQueryReq.serializer,
        json,
      );
}

abstract class GRequestPurchaseMutationReq
    implements
        Built<GRequestPurchaseMutationReq, GRequestPurchaseMutationReqBuilder>,
        _i1.OperationRequest<_i2.GRequestPurchaseMutationData,
            _i3.GRequestPurchaseMutationVars> {
  GRequestPurchaseMutationReq._();

  factory GRequestPurchaseMutationReq(
          [void Function(GRequestPurchaseMutationReqBuilder b) updates]) =
      _$GRequestPurchaseMutationReq;

  static void _initializeBuilder(GRequestPurchaseMutationReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'RequestPurchaseMutation',
    )
    ..executeOnListen = true;

  @override
  _i3.GRequestPurchaseMutationVars get vars;
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
  _i2.GRequestPurchaseMutationData? Function(
    _i2.GRequestPurchaseMutationData?,
    _i2.GRequestPurchaseMutationData?,
  )? get updateResult;
  @override
  _i2.GRequestPurchaseMutationData? get optimisticResponse;
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
  _i2.GRequestPurchaseMutationData? parseData(Map<String, dynamic> json) =>
      _i2.GRequestPurchaseMutationData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GRequestPurchaseMutationData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GRequestPurchaseMutationData,
      _i3.GRequestPurchaseMutationVars> transformOperation(
          _i4.Operation Function(_i4.Operation) transform) =>
      this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GRequestPurchaseMutationReq> get serializer =>
      _$gRequestPurchaseMutationReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GRequestPurchaseMutationReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRequestPurchaseMutationReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GRequestPurchaseMutationReq.serializer,
        json,
      );
}

abstract class GRequestRestorePurchaseMutationReq
    implements
        Built<GRequestRestorePurchaseMutationReq,
            GRequestRestorePurchaseMutationReqBuilder>,
        _i1.OperationRequest<_i2.GRequestRestorePurchaseMutationData,
            _i3.GRequestRestorePurchaseMutationVars> {
  GRequestRestorePurchaseMutationReq._();

  factory GRequestRestorePurchaseMutationReq(
      [void Function(GRequestRestorePurchaseMutationReqBuilder b)
          updates]) = _$GRequestRestorePurchaseMutationReq;

  static void _initializeBuilder(GRequestRestorePurchaseMutationReqBuilder b) =>
      b
        ..operation = _i4.Operation(
          document: _i5.document,
          operationName: 'RequestRestorePurchaseMutation',
        )
        ..executeOnListen = true;

  @override
  _i3.GRequestRestorePurchaseMutationVars get vars;
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
  _i2.GRequestRestorePurchaseMutationData? Function(
    _i2.GRequestRestorePurchaseMutationData?,
    _i2.GRequestRestorePurchaseMutationData?,
  )? get updateResult;
  @override
  _i2.GRequestRestorePurchaseMutationData? get optimisticResponse;
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
  _i2.GRequestRestorePurchaseMutationData? parseData(
          Map<String, dynamic> json) =>
      _i2.GRequestRestorePurchaseMutationData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(
          _i2.GRequestRestorePurchaseMutationData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GRequestRestorePurchaseMutationData,
      _i3.GRequestRestorePurchaseMutationVars> transformOperation(
          _i4.Operation Function(_i4.Operation) transform) =>
      this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GRequestRestorePurchaseMutationReq> get serializer =>
      _$gRequestRestorePurchaseMutationReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GRequestRestorePurchaseMutationReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRequestRestorePurchaseMutationReq? fromJson(
          Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GRequestRestorePurchaseMutationReq.serializer,
        json,
      );
}
