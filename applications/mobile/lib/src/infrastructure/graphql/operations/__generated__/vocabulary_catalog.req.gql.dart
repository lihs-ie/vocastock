// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:vocastock_mobile/src/infrastructure/graphql/__generated__/serializers.gql.dart'
    as _i6;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/vocabulary_catalog.ast.gql.dart'
    as _i5;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/vocabulary_catalog.data.gql.dart'
    as _i2;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/vocabulary_catalog.var.gql.dart'
    as _i3;

part 'vocabulary_catalog.req.gql.g.dart';

abstract class GVocabularyCatalogQueryReq
    implements
        Built<GVocabularyCatalogQueryReq, GVocabularyCatalogQueryReqBuilder>,
        _i1.OperationRequest<_i2.GVocabularyCatalogQueryData,
            _i3.GVocabularyCatalogQueryVars> {
  GVocabularyCatalogQueryReq._();

  factory GVocabularyCatalogQueryReq(
          [void Function(GVocabularyCatalogQueryReqBuilder b) updates]) =
      _$GVocabularyCatalogQueryReq;

  static void _initializeBuilder(GVocabularyCatalogQueryReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'VocabularyCatalogQuery',
    )
    ..executeOnListen = true;

  @override
  _i3.GVocabularyCatalogQueryVars get vars;
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
  _i2.GVocabularyCatalogQueryData? Function(
    _i2.GVocabularyCatalogQueryData?,
    _i2.GVocabularyCatalogQueryData?,
  )? get updateResult;
  @override
  _i2.GVocabularyCatalogQueryData? get optimisticResponse;
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
  _i2.GVocabularyCatalogQueryData? parseData(Map<String, dynamic> json) =>
      _i2.GVocabularyCatalogQueryData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GVocabularyCatalogQueryData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GVocabularyCatalogQueryData,
      _i3.GVocabularyCatalogQueryVars> transformOperation(
          _i4.Operation Function(_i4.Operation) transform) =>
      this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GVocabularyCatalogQueryReq> get serializer =>
      _$gVocabularyCatalogQueryReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GVocabularyCatalogQueryReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GVocabularyCatalogQueryReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GVocabularyCatalogQueryReq.serializer,
        json,
      );
}

abstract class GVocabularyExpressionDetailQueryReq
    implements
        Built<GVocabularyExpressionDetailQueryReq,
            GVocabularyExpressionDetailQueryReqBuilder>,
        _i1.OperationRequest<_i2.GVocabularyExpressionDetailQueryData,
            _i3.GVocabularyExpressionDetailQueryVars> {
  GVocabularyExpressionDetailQueryReq._();

  factory GVocabularyExpressionDetailQueryReq(
      [void Function(GVocabularyExpressionDetailQueryReqBuilder b)
          updates]) = _$GVocabularyExpressionDetailQueryReq;

  static void _initializeBuilder(
          GVocabularyExpressionDetailQueryReqBuilder b) =>
      b
        ..operation = _i4.Operation(
          document: _i5.document,
          operationName: 'VocabularyExpressionDetailQuery',
        )
        ..executeOnListen = true;

  @override
  _i3.GVocabularyExpressionDetailQueryVars get vars;
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
  _i2.GVocabularyExpressionDetailQueryData? Function(
    _i2.GVocabularyExpressionDetailQueryData?,
    _i2.GVocabularyExpressionDetailQueryData?,
  )? get updateResult;
  @override
  _i2.GVocabularyExpressionDetailQueryData? get optimisticResponse;
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
  _i2.GVocabularyExpressionDetailQueryData? parseData(
          Map<String, dynamic> json) =>
      _i2.GVocabularyExpressionDetailQueryData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(
          _i2.GVocabularyExpressionDetailQueryData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GVocabularyExpressionDetailQueryData,
      _i3.GVocabularyExpressionDetailQueryVars> transformOperation(
          _i4.Operation Function(_i4.Operation) transform) =>
      this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GVocabularyExpressionDetailQueryReq> get serializer =>
      _$gVocabularyExpressionDetailQueryReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GVocabularyExpressionDetailQueryReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GVocabularyExpressionDetailQueryReq? fromJson(
          Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GVocabularyExpressionDetailQueryReq.serializer,
        json,
      );
}
