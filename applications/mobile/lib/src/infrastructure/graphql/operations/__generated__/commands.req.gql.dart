// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:vocastock_mobile/src/infrastructure/graphql/__generated__/serializers.gql.dart'
    as _i6;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/commands.ast.gql.dart'
    as _i5;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/commands.data.gql.dart'
    as _i2;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/commands.var.gql.dart'
    as _i3;

part 'commands.req.gql.g.dart';

abstract class GRegisterVocabularyExpressionMutationReq
    implements
        Built<GRegisterVocabularyExpressionMutationReq,
            GRegisterVocabularyExpressionMutationReqBuilder>,
        _i1.OperationRequest<_i2.GRegisterVocabularyExpressionMutationData,
            _i3.GRegisterVocabularyExpressionMutationVars> {
  GRegisterVocabularyExpressionMutationReq._();

  factory GRegisterVocabularyExpressionMutationReq(
      [void Function(GRegisterVocabularyExpressionMutationReqBuilder b)
          updates]) = _$GRegisterVocabularyExpressionMutationReq;

  static void _initializeBuilder(
          GRegisterVocabularyExpressionMutationReqBuilder b) =>
      b
        ..operation = _i4.Operation(
          document: _i5.document,
          operationName: 'RegisterVocabularyExpressionMutation',
        )
        ..executeOnListen = true;

  @override
  _i3.GRegisterVocabularyExpressionMutationVars get vars;
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
  _i2.GRegisterVocabularyExpressionMutationData? Function(
    _i2.GRegisterVocabularyExpressionMutationData?,
    _i2.GRegisterVocabularyExpressionMutationData?,
  )? get updateResult;
  @override
  _i2.GRegisterVocabularyExpressionMutationData? get optimisticResponse;
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
  _i2.GRegisterVocabularyExpressionMutationData? parseData(
          Map<String, dynamic> json) =>
      _i2.GRegisterVocabularyExpressionMutationData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(
          _i2.GRegisterVocabularyExpressionMutationData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GRegisterVocabularyExpressionMutationData,
      _i3.GRegisterVocabularyExpressionMutationVars> transformOperation(
          _i4.Operation Function(_i4.Operation) transform) =>
      this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GRegisterVocabularyExpressionMutationReq> get serializer =>
      _$gRegisterVocabularyExpressionMutationReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GRegisterVocabularyExpressionMutationReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRegisterVocabularyExpressionMutationReq? fromJson(
          Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GRegisterVocabularyExpressionMutationReq.serializer,
        json,
      );
}

abstract class GRequestExplanationGenerationMutationReq
    implements
        Built<GRequestExplanationGenerationMutationReq,
            GRequestExplanationGenerationMutationReqBuilder>,
        _i1.OperationRequest<_i2.GRequestExplanationGenerationMutationData,
            _i3.GRequestExplanationGenerationMutationVars> {
  GRequestExplanationGenerationMutationReq._();

  factory GRequestExplanationGenerationMutationReq(
      [void Function(GRequestExplanationGenerationMutationReqBuilder b)
          updates]) = _$GRequestExplanationGenerationMutationReq;

  static void _initializeBuilder(
          GRequestExplanationGenerationMutationReqBuilder b) =>
      b
        ..operation = _i4.Operation(
          document: _i5.document,
          operationName: 'RequestExplanationGenerationMutation',
        )
        ..executeOnListen = true;

  @override
  _i3.GRequestExplanationGenerationMutationVars get vars;
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
  _i2.GRequestExplanationGenerationMutationData? Function(
    _i2.GRequestExplanationGenerationMutationData?,
    _i2.GRequestExplanationGenerationMutationData?,
  )? get updateResult;
  @override
  _i2.GRequestExplanationGenerationMutationData? get optimisticResponse;
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
  _i2.GRequestExplanationGenerationMutationData? parseData(
          Map<String, dynamic> json) =>
      _i2.GRequestExplanationGenerationMutationData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(
          _i2.GRequestExplanationGenerationMutationData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GRequestExplanationGenerationMutationData,
      _i3.GRequestExplanationGenerationMutationVars> transformOperation(
          _i4.Operation Function(_i4.Operation) transform) =>
      this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GRequestExplanationGenerationMutationReq> get serializer =>
      _$gRequestExplanationGenerationMutationReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GRequestExplanationGenerationMutationReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRequestExplanationGenerationMutationReq? fromJson(
          Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GRequestExplanationGenerationMutationReq.serializer,
        json,
      );
}

abstract class GRequestImageGenerationMutationReq
    implements
        Built<GRequestImageGenerationMutationReq,
            GRequestImageGenerationMutationReqBuilder>,
        _i1.OperationRequest<_i2.GRequestImageGenerationMutationData,
            _i3.GRequestImageGenerationMutationVars> {
  GRequestImageGenerationMutationReq._();

  factory GRequestImageGenerationMutationReq(
      [void Function(GRequestImageGenerationMutationReqBuilder b)
          updates]) = _$GRequestImageGenerationMutationReq;

  static void _initializeBuilder(GRequestImageGenerationMutationReqBuilder b) =>
      b
        ..operation = _i4.Operation(
          document: _i5.document,
          operationName: 'RequestImageGenerationMutation',
        )
        ..executeOnListen = true;

  @override
  _i3.GRequestImageGenerationMutationVars get vars;
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
  _i2.GRequestImageGenerationMutationData? Function(
    _i2.GRequestImageGenerationMutationData?,
    _i2.GRequestImageGenerationMutationData?,
  )? get updateResult;
  @override
  _i2.GRequestImageGenerationMutationData? get optimisticResponse;
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
  _i2.GRequestImageGenerationMutationData? parseData(
          Map<String, dynamic> json) =>
      _i2.GRequestImageGenerationMutationData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(
          _i2.GRequestImageGenerationMutationData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GRequestImageGenerationMutationData,
      _i3.GRequestImageGenerationMutationVars> transformOperation(
          _i4.Operation Function(_i4.Operation) transform) =>
      this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GRequestImageGenerationMutationReq> get serializer =>
      _$gRequestImageGenerationMutationReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GRequestImageGenerationMutationReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRequestImageGenerationMutationReq? fromJson(
          Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GRequestImageGenerationMutationReq.serializer,
        json,
      );
}

abstract class GRetryGenerationMutationReq
    implements
        Built<GRetryGenerationMutationReq, GRetryGenerationMutationReqBuilder>,
        _i1.OperationRequest<_i2.GRetryGenerationMutationData,
            _i3.GRetryGenerationMutationVars> {
  GRetryGenerationMutationReq._();

  factory GRetryGenerationMutationReq(
          [void Function(GRetryGenerationMutationReqBuilder b) updates]) =
      _$GRetryGenerationMutationReq;

  static void _initializeBuilder(GRetryGenerationMutationReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'RetryGenerationMutation',
    )
    ..executeOnListen = true;

  @override
  _i3.GRetryGenerationMutationVars get vars;
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
  _i2.GRetryGenerationMutationData? Function(
    _i2.GRetryGenerationMutationData?,
    _i2.GRetryGenerationMutationData?,
  )? get updateResult;
  @override
  _i2.GRetryGenerationMutationData? get optimisticResponse;
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
  _i2.GRetryGenerationMutationData? parseData(Map<String, dynamic> json) =>
      _i2.GRetryGenerationMutationData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GRetryGenerationMutationData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GRetryGenerationMutationData,
      _i3.GRetryGenerationMutationVars> transformOperation(
          _i4.Operation Function(_i4.Operation) transform) =>
      this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GRetryGenerationMutationReq> get serializer =>
      _$gRetryGenerationMutationReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GRetryGenerationMutationReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRetryGenerationMutationReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GRetryGenerationMutationReq.serializer,
        json,
      );
}
