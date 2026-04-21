// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocabulary_catalog.req.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GVocabularyCatalogQueryReq> _$gVocabularyCatalogQueryReqSerializer =
    _$GVocabularyCatalogQueryReqSerializer();
Serializer<GVocabularyExpressionDetailQueryReq>
_$gVocabularyExpressionDetailQueryReqSerializer =
    _$GVocabularyExpressionDetailQueryReqSerializer();

class _$GVocabularyCatalogQueryReqSerializer
    implements StructuredSerializer<GVocabularyCatalogQueryReq> {
  @override
  final Iterable<Type> types = const [
    GVocabularyCatalogQueryReq,
    _$GVocabularyCatalogQueryReq,
  ];
  @override
  final String wireName = 'GVocabularyCatalogQueryReq';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GVocabularyCatalogQueryReq object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'vars',
      serializers.serialize(
        object.vars,
        specifiedType: const FullType(_i3.GVocabularyCatalogQueryVars),
      ),
      'operation',
      serializers.serialize(
        object.operation,
        specifiedType: const FullType(_i4.Operation),
      ),
      'executeOnListen',
      serializers.serialize(
        object.executeOnListen,
        specifiedType: const FullType(bool),
      ),
    ];
    Object? value;
    value = object.requestId;
    if (value != null) {
      result
        ..add('requestId')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(String)),
        );
    }
    value = object.optimisticResponse;
    if (value != null) {
      result
        ..add('optimisticResponse')
        ..add(
          serializers.serialize(
            value,
            specifiedType: const FullType(_i2.GVocabularyCatalogQueryData),
          ),
        );
    }
    value = object.updateCacheHandlerKey;
    if (value != null) {
      result
        ..add('updateCacheHandlerKey')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(String)),
        );
    }
    value = object.updateCacheHandlerContext;
    if (value != null) {
      result
        ..add('updateCacheHandlerContext')
        ..add(
          serializers.serialize(
            value,
            specifiedType: const FullType(Map, const [
              const FullType(String),
              const FullType(dynamic),
            ]),
          ),
        );
    }
    value = object.fetchPolicy;
    if (value != null) {
      result
        ..add('fetchPolicy')
        ..add(
          serializers.serialize(
            value,
            specifiedType: const FullType(_i1.FetchPolicy),
          ),
        );
    }
    return result;
  }

  @override
  GVocabularyCatalogQueryReq deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GVocabularyCatalogQueryReqBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'vars':
          result.vars.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(
                    _i3.GVocabularyCatalogQueryVars,
                  ),
                )!
                as _i3.GVocabularyCatalogQueryVars,
          );
          break;
        case 'operation':
          result.operation =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(_i4.Operation),
                  )!
                  as _i4.Operation;
          break;
        case 'requestId':
          result.requestId =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String?;
          break;
        case 'optimisticResponse':
          result.optimisticResponse.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(
                    _i2.GVocabularyCatalogQueryData,
                  ),
                )!
                as _i2.GVocabularyCatalogQueryData,
          );
          break;
        case 'updateCacheHandlerKey':
          result.updateCacheHandlerKey =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String?;
          break;
        case 'updateCacheHandlerContext':
          result.updateCacheHandlerContext =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Map, const [
                      const FullType(String),
                      const FullType(dynamic),
                    ]),
                  )
                  as Map<String, dynamic>?;
          break;
        case 'fetchPolicy':
          result.fetchPolicy =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(_i1.FetchPolicy),
                  )
                  as _i1.FetchPolicy?;
          break;
        case 'executeOnListen':
          result.executeOnListen =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )!
                  as bool;
          break;
      }
    }

    return result.build();
  }
}

class _$GVocabularyExpressionDetailQueryReqSerializer
    implements StructuredSerializer<GVocabularyExpressionDetailQueryReq> {
  @override
  final Iterable<Type> types = const [
    GVocabularyExpressionDetailQueryReq,
    _$GVocabularyExpressionDetailQueryReq,
  ];
  @override
  final String wireName = 'GVocabularyExpressionDetailQueryReq';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GVocabularyExpressionDetailQueryReq object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'vars',
      serializers.serialize(
        object.vars,
        specifiedType: const FullType(_i3.GVocabularyExpressionDetailQueryVars),
      ),
      'operation',
      serializers.serialize(
        object.operation,
        specifiedType: const FullType(_i4.Operation),
      ),
      'executeOnListen',
      serializers.serialize(
        object.executeOnListen,
        specifiedType: const FullType(bool),
      ),
    ];
    Object? value;
    value = object.requestId;
    if (value != null) {
      result
        ..add('requestId')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(String)),
        );
    }
    value = object.optimisticResponse;
    if (value != null) {
      result
        ..add('optimisticResponse')
        ..add(
          serializers.serialize(
            value,
            specifiedType: const FullType(
              _i2.GVocabularyExpressionDetailQueryData,
            ),
          ),
        );
    }
    value = object.updateCacheHandlerKey;
    if (value != null) {
      result
        ..add('updateCacheHandlerKey')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(String)),
        );
    }
    value = object.updateCacheHandlerContext;
    if (value != null) {
      result
        ..add('updateCacheHandlerContext')
        ..add(
          serializers.serialize(
            value,
            specifiedType: const FullType(Map, const [
              const FullType(String),
              const FullType(dynamic),
            ]),
          ),
        );
    }
    value = object.fetchPolicy;
    if (value != null) {
      result
        ..add('fetchPolicy')
        ..add(
          serializers.serialize(
            value,
            specifiedType: const FullType(_i1.FetchPolicy),
          ),
        );
    }
    return result;
  }

  @override
  GVocabularyExpressionDetailQueryReq deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GVocabularyExpressionDetailQueryReqBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'vars':
          result.vars.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(
                    _i3.GVocabularyExpressionDetailQueryVars,
                  ),
                )!
                as _i3.GVocabularyExpressionDetailQueryVars,
          );
          break;
        case 'operation':
          result.operation =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(_i4.Operation),
                  )!
                  as _i4.Operation;
          break;
        case 'requestId':
          result.requestId =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String?;
          break;
        case 'optimisticResponse':
          result.optimisticResponse.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(
                    _i2.GVocabularyExpressionDetailQueryData,
                  ),
                )!
                as _i2.GVocabularyExpressionDetailQueryData,
          );
          break;
        case 'updateCacheHandlerKey':
          result.updateCacheHandlerKey =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String?;
          break;
        case 'updateCacheHandlerContext':
          result.updateCacheHandlerContext =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Map, const [
                      const FullType(String),
                      const FullType(dynamic),
                    ]),
                  )
                  as Map<String, dynamic>?;
          break;
        case 'fetchPolicy':
          result.fetchPolicy =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(_i1.FetchPolicy),
                  )
                  as _i1.FetchPolicy?;
          break;
        case 'executeOnListen':
          result.executeOnListen =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )!
                  as bool;
          break;
      }
    }

    return result.build();
  }
}

class _$GVocabularyCatalogQueryReq extends GVocabularyCatalogQueryReq {
  @override
  final _i3.GVocabularyCatalogQueryVars vars;
  @override
  final _i4.Operation operation;
  @override
  final String? requestId;
  @override
  final _i2.GVocabularyCatalogQueryData? Function(
    _i2.GVocabularyCatalogQueryData?,
    _i2.GVocabularyCatalogQueryData?,
  )?
  updateResult;
  @override
  final _i2.GVocabularyCatalogQueryData? optimisticResponse;
  @override
  final String? updateCacheHandlerKey;
  @override
  final Map<String, dynamic>? updateCacheHandlerContext;
  @override
  final _i1.FetchPolicy? fetchPolicy;
  @override
  final bool executeOnListen;
  @override
  final _i4.Context? context;

  factory _$GVocabularyCatalogQueryReq([
    void Function(GVocabularyCatalogQueryReqBuilder)? updates,
  ]) => (GVocabularyCatalogQueryReqBuilder()..update(updates))._build();

  _$GVocabularyCatalogQueryReq._({
    required this.vars,
    required this.operation,
    this.requestId,
    this.updateResult,
    this.optimisticResponse,
    this.updateCacheHandlerKey,
    this.updateCacheHandlerContext,
    this.fetchPolicy,
    required this.executeOnListen,
    this.context,
  }) : super._();
  @override
  GVocabularyCatalogQueryReq rebuild(
    void Function(GVocabularyCatalogQueryReqBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GVocabularyCatalogQueryReqBuilder toBuilder() =>
      GVocabularyCatalogQueryReqBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    final dynamic _$dynamicOther = other;
    return other is GVocabularyCatalogQueryReq &&
        vars == other.vars &&
        operation == other.operation &&
        requestId == other.requestId &&
        updateResult == _$dynamicOther.updateResult &&
        optimisticResponse == other.optimisticResponse &&
        updateCacheHandlerKey == other.updateCacheHandlerKey &&
        updateCacheHandlerContext == other.updateCacheHandlerContext &&
        fetchPolicy == other.fetchPolicy &&
        executeOnListen == other.executeOnListen &&
        context == other.context;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, vars.hashCode);
    _$hash = $jc(_$hash, operation.hashCode);
    _$hash = $jc(_$hash, requestId.hashCode);
    _$hash = $jc(_$hash, updateResult.hashCode);
    _$hash = $jc(_$hash, optimisticResponse.hashCode);
    _$hash = $jc(_$hash, updateCacheHandlerKey.hashCode);
    _$hash = $jc(_$hash, updateCacheHandlerContext.hashCode);
    _$hash = $jc(_$hash, fetchPolicy.hashCode);
    _$hash = $jc(_$hash, executeOnListen.hashCode);
    _$hash = $jc(_$hash, context.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GVocabularyCatalogQueryReq')
          ..add('vars', vars)
          ..add('operation', operation)
          ..add('requestId', requestId)
          ..add('updateResult', updateResult)
          ..add('optimisticResponse', optimisticResponse)
          ..add('updateCacheHandlerKey', updateCacheHandlerKey)
          ..add('updateCacheHandlerContext', updateCacheHandlerContext)
          ..add('fetchPolicy', fetchPolicy)
          ..add('executeOnListen', executeOnListen)
          ..add('context', context))
        .toString();
  }
}

class GVocabularyCatalogQueryReqBuilder
    implements
        Builder<GVocabularyCatalogQueryReq, GVocabularyCatalogQueryReqBuilder> {
  _$GVocabularyCatalogQueryReq? _$v;

  _i3.GVocabularyCatalogQueryVarsBuilder? _vars;
  _i3.GVocabularyCatalogQueryVarsBuilder get vars =>
      _$this._vars ??= _i3.GVocabularyCatalogQueryVarsBuilder();
  set vars(_i3.GVocabularyCatalogQueryVarsBuilder? vars) => _$this._vars = vars;

  _i4.Operation? _operation;
  _i4.Operation? get operation => _$this._operation;
  set operation(_i4.Operation? operation) => _$this._operation = operation;

  String? _requestId;
  String? get requestId => _$this._requestId;
  set requestId(String? requestId) => _$this._requestId = requestId;

  _i2.GVocabularyCatalogQueryData? Function(
    _i2.GVocabularyCatalogQueryData?,
    _i2.GVocabularyCatalogQueryData?,
  )?
  _updateResult;
  _i2.GVocabularyCatalogQueryData? Function(
    _i2.GVocabularyCatalogQueryData?,
    _i2.GVocabularyCatalogQueryData?,
  )?
  get updateResult => _$this._updateResult;
  set updateResult(
    _i2.GVocabularyCatalogQueryData? Function(
      _i2.GVocabularyCatalogQueryData?,
      _i2.GVocabularyCatalogQueryData?,
    )?
    updateResult,
  ) => _$this._updateResult = updateResult;

  _i2.GVocabularyCatalogQueryDataBuilder? _optimisticResponse;
  _i2.GVocabularyCatalogQueryDataBuilder get optimisticResponse =>
      _$this._optimisticResponse ??= _i2.GVocabularyCatalogQueryDataBuilder();
  set optimisticResponse(
    _i2.GVocabularyCatalogQueryDataBuilder? optimisticResponse,
  ) => _$this._optimisticResponse = optimisticResponse;

  String? _updateCacheHandlerKey;
  String? get updateCacheHandlerKey => _$this._updateCacheHandlerKey;
  set updateCacheHandlerKey(String? updateCacheHandlerKey) =>
      _$this._updateCacheHandlerKey = updateCacheHandlerKey;

  Map<String, dynamic>? _updateCacheHandlerContext;
  Map<String, dynamic>? get updateCacheHandlerContext =>
      _$this._updateCacheHandlerContext;
  set updateCacheHandlerContext(
    Map<String, dynamic>? updateCacheHandlerContext,
  ) => _$this._updateCacheHandlerContext = updateCacheHandlerContext;

  _i1.FetchPolicy? _fetchPolicy;
  _i1.FetchPolicy? get fetchPolicy => _$this._fetchPolicy;
  set fetchPolicy(_i1.FetchPolicy? fetchPolicy) =>
      _$this._fetchPolicy = fetchPolicy;

  bool? _executeOnListen;
  bool? get executeOnListen => _$this._executeOnListen;
  set executeOnListen(bool? executeOnListen) =>
      _$this._executeOnListen = executeOnListen;

  _i4.Context? _context;
  _i4.Context? get context => _$this._context;
  set context(_i4.Context? context) => _$this._context = context;

  GVocabularyCatalogQueryReqBuilder() {
    GVocabularyCatalogQueryReq._initializeBuilder(this);
  }

  GVocabularyCatalogQueryReqBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _vars = $v.vars.toBuilder();
      _operation = $v.operation;
      _requestId = $v.requestId;
      _updateResult = $v.updateResult;
      _optimisticResponse = $v.optimisticResponse?.toBuilder();
      _updateCacheHandlerKey = $v.updateCacheHandlerKey;
      _updateCacheHandlerContext = $v.updateCacheHandlerContext;
      _fetchPolicy = $v.fetchPolicy;
      _executeOnListen = $v.executeOnListen;
      _context = $v.context;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GVocabularyCatalogQueryReq other) {
    _$v = other as _$GVocabularyCatalogQueryReq;
  }

  @override
  void update(void Function(GVocabularyCatalogQueryReqBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GVocabularyCatalogQueryReq build() => _build();

  _$GVocabularyCatalogQueryReq _build() {
    _$GVocabularyCatalogQueryReq _$result;
    try {
      _$result =
          _$v ??
          _$GVocabularyCatalogQueryReq._(
            vars: vars.build(),
            operation: BuiltValueNullFieldError.checkNotNull(
              operation,
              r'GVocabularyCatalogQueryReq',
              'operation',
            ),
            requestId: requestId,
            updateResult: updateResult,
            optimisticResponse: _optimisticResponse?.build(),
            updateCacheHandlerKey: updateCacheHandlerKey,
            updateCacheHandlerContext: updateCacheHandlerContext,
            fetchPolicy: fetchPolicy,
            executeOnListen: BuiltValueNullFieldError.checkNotNull(
              executeOnListen,
              r'GVocabularyCatalogQueryReq',
              'executeOnListen',
            ),
            context: context,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'vars';
        vars.build();

        _$failedField = 'optimisticResponse';
        _optimisticResponse?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GVocabularyCatalogQueryReq',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GVocabularyExpressionDetailQueryReq
    extends GVocabularyExpressionDetailQueryReq {
  @override
  final _i3.GVocabularyExpressionDetailQueryVars vars;
  @override
  final _i4.Operation operation;
  @override
  final String? requestId;
  @override
  final _i2.GVocabularyExpressionDetailQueryData? Function(
    _i2.GVocabularyExpressionDetailQueryData?,
    _i2.GVocabularyExpressionDetailQueryData?,
  )?
  updateResult;
  @override
  final _i2.GVocabularyExpressionDetailQueryData? optimisticResponse;
  @override
  final String? updateCacheHandlerKey;
  @override
  final Map<String, dynamic>? updateCacheHandlerContext;
  @override
  final _i1.FetchPolicy? fetchPolicy;
  @override
  final bool executeOnListen;
  @override
  final _i4.Context? context;

  factory _$GVocabularyExpressionDetailQueryReq([
    void Function(GVocabularyExpressionDetailQueryReqBuilder)? updates,
  ]) =>
      (GVocabularyExpressionDetailQueryReqBuilder()..update(updates))._build();

  _$GVocabularyExpressionDetailQueryReq._({
    required this.vars,
    required this.operation,
    this.requestId,
    this.updateResult,
    this.optimisticResponse,
    this.updateCacheHandlerKey,
    this.updateCacheHandlerContext,
    this.fetchPolicy,
    required this.executeOnListen,
    this.context,
  }) : super._();
  @override
  GVocabularyExpressionDetailQueryReq rebuild(
    void Function(GVocabularyExpressionDetailQueryReqBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GVocabularyExpressionDetailQueryReqBuilder toBuilder() =>
      GVocabularyExpressionDetailQueryReqBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    final dynamic _$dynamicOther = other;
    return other is GVocabularyExpressionDetailQueryReq &&
        vars == other.vars &&
        operation == other.operation &&
        requestId == other.requestId &&
        updateResult == _$dynamicOther.updateResult &&
        optimisticResponse == other.optimisticResponse &&
        updateCacheHandlerKey == other.updateCacheHandlerKey &&
        updateCacheHandlerContext == other.updateCacheHandlerContext &&
        fetchPolicy == other.fetchPolicy &&
        executeOnListen == other.executeOnListen &&
        context == other.context;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, vars.hashCode);
    _$hash = $jc(_$hash, operation.hashCode);
    _$hash = $jc(_$hash, requestId.hashCode);
    _$hash = $jc(_$hash, updateResult.hashCode);
    _$hash = $jc(_$hash, optimisticResponse.hashCode);
    _$hash = $jc(_$hash, updateCacheHandlerKey.hashCode);
    _$hash = $jc(_$hash, updateCacheHandlerContext.hashCode);
    _$hash = $jc(_$hash, fetchPolicy.hashCode);
    _$hash = $jc(_$hash, executeOnListen.hashCode);
    _$hash = $jc(_$hash, context.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GVocabularyExpressionDetailQueryReq')
          ..add('vars', vars)
          ..add('operation', operation)
          ..add('requestId', requestId)
          ..add('updateResult', updateResult)
          ..add('optimisticResponse', optimisticResponse)
          ..add('updateCacheHandlerKey', updateCacheHandlerKey)
          ..add('updateCacheHandlerContext', updateCacheHandlerContext)
          ..add('fetchPolicy', fetchPolicy)
          ..add('executeOnListen', executeOnListen)
          ..add('context', context))
        .toString();
  }
}

class GVocabularyExpressionDetailQueryReqBuilder
    implements
        Builder<
          GVocabularyExpressionDetailQueryReq,
          GVocabularyExpressionDetailQueryReqBuilder
        > {
  _$GVocabularyExpressionDetailQueryReq? _$v;

  _i3.GVocabularyExpressionDetailQueryVarsBuilder? _vars;
  _i3.GVocabularyExpressionDetailQueryVarsBuilder get vars =>
      _$this._vars ??= _i3.GVocabularyExpressionDetailQueryVarsBuilder();
  set vars(_i3.GVocabularyExpressionDetailQueryVarsBuilder? vars) =>
      _$this._vars = vars;

  _i4.Operation? _operation;
  _i4.Operation? get operation => _$this._operation;
  set operation(_i4.Operation? operation) => _$this._operation = operation;

  String? _requestId;
  String? get requestId => _$this._requestId;
  set requestId(String? requestId) => _$this._requestId = requestId;

  _i2.GVocabularyExpressionDetailQueryData? Function(
    _i2.GVocabularyExpressionDetailQueryData?,
    _i2.GVocabularyExpressionDetailQueryData?,
  )?
  _updateResult;
  _i2.GVocabularyExpressionDetailQueryData? Function(
    _i2.GVocabularyExpressionDetailQueryData?,
    _i2.GVocabularyExpressionDetailQueryData?,
  )?
  get updateResult => _$this._updateResult;
  set updateResult(
    _i2.GVocabularyExpressionDetailQueryData? Function(
      _i2.GVocabularyExpressionDetailQueryData?,
      _i2.GVocabularyExpressionDetailQueryData?,
    )?
    updateResult,
  ) => _$this._updateResult = updateResult;

  _i2.GVocabularyExpressionDetailQueryDataBuilder? _optimisticResponse;
  _i2.GVocabularyExpressionDetailQueryDataBuilder get optimisticResponse =>
      _$this._optimisticResponse ??=
          _i2.GVocabularyExpressionDetailQueryDataBuilder();
  set optimisticResponse(
    _i2.GVocabularyExpressionDetailQueryDataBuilder? optimisticResponse,
  ) => _$this._optimisticResponse = optimisticResponse;

  String? _updateCacheHandlerKey;
  String? get updateCacheHandlerKey => _$this._updateCacheHandlerKey;
  set updateCacheHandlerKey(String? updateCacheHandlerKey) =>
      _$this._updateCacheHandlerKey = updateCacheHandlerKey;

  Map<String, dynamic>? _updateCacheHandlerContext;
  Map<String, dynamic>? get updateCacheHandlerContext =>
      _$this._updateCacheHandlerContext;
  set updateCacheHandlerContext(
    Map<String, dynamic>? updateCacheHandlerContext,
  ) => _$this._updateCacheHandlerContext = updateCacheHandlerContext;

  _i1.FetchPolicy? _fetchPolicy;
  _i1.FetchPolicy? get fetchPolicy => _$this._fetchPolicy;
  set fetchPolicy(_i1.FetchPolicy? fetchPolicy) =>
      _$this._fetchPolicy = fetchPolicy;

  bool? _executeOnListen;
  bool? get executeOnListen => _$this._executeOnListen;
  set executeOnListen(bool? executeOnListen) =>
      _$this._executeOnListen = executeOnListen;

  _i4.Context? _context;
  _i4.Context? get context => _$this._context;
  set context(_i4.Context? context) => _$this._context = context;

  GVocabularyExpressionDetailQueryReqBuilder() {
    GVocabularyExpressionDetailQueryReq._initializeBuilder(this);
  }

  GVocabularyExpressionDetailQueryReqBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _vars = $v.vars.toBuilder();
      _operation = $v.operation;
      _requestId = $v.requestId;
      _updateResult = $v.updateResult;
      _optimisticResponse = $v.optimisticResponse?.toBuilder();
      _updateCacheHandlerKey = $v.updateCacheHandlerKey;
      _updateCacheHandlerContext = $v.updateCacheHandlerContext;
      _fetchPolicy = $v.fetchPolicy;
      _executeOnListen = $v.executeOnListen;
      _context = $v.context;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GVocabularyExpressionDetailQueryReq other) {
    _$v = other as _$GVocabularyExpressionDetailQueryReq;
  }

  @override
  void update(
    void Function(GVocabularyExpressionDetailQueryReqBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GVocabularyExpressionDetailQueryReq build() => _build();

  _$GVocabularyExpressionDetailQueryReq _build() {
    _$GVocabularyExpressionDetailQueryReq _$result;
    try {
      _$result =
          _$v ??
          _$GVocabularyExpressionDetailQueryReq._(
            vars: vars.build(),
            operation: BuiltValueNullFieldError.checkNotNull(
              operation,
              r'GVocabularyExpressionDetailQueryReq',
              'operation',
            ),
            requestId: requestId,
            updateResult: updateResult,
            optimisticResponse: _optimisticResponse?.build(),
            updateCacheHandlerKey: updateCacheHandlerKey,
            updateCacheHandlerContext: updateCacheHandlerContext,
            fetchPolicy: fetchPolicy,
            executeOnListen: BuiltValueNullFieldError.checkNotNull(
              executeOnListen,
              r'GVocabularyExpressionDetailQueryReq',
              'executeOnListen',
            ),
            context: context,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'vars';
        vars.build();

        _$failedField = 'optimisticResponse';
        _optimisticResponse?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GVocabularyExpressionDetailQueryReq',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
