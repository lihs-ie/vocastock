// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commands.req.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GRegisterVocabularyExpressionMutationReq>
_$gRegisterVocabularyExpressionMutationReqSerializer =
    _$GRegisterVocabularyExpressionMutationReqSerializer();
Serializer<GRequestExplanationGenerationMutationReq>
_$gRequestExplanationGenerationMutationReqSerializer =
    _$GRequestExplanationGenerationMutationReqSerializer();
Serializer<GRequestImageGenerationMutationReq>
_$gRequestImageGenerationMutationReqSerializer =
    _$GRequestImageGenerationMutationReqSerializer();
Serializer<GRetryGenerationMutationReq>
_$gRetryGenerationMutationReqSerializer =
    _$GRetryGenerationMutationReqSerializer();

class _$GRegisterVocabularyExpressionMutationReqSerializer
    implements StructuredSerializer<GRegisterVocabularyExpressionMutationReq> {
  @override
  final Iterable<Type> types = const [
    GRegisterVocabularyExpressionMutationReq,
    _$GRegisterVocabularyExpressionMutationReq,
  ];
  @override
  final String wireName = 'GRegisterVocabularyExpressionMutationReq';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GRegisterVocabularyExpressionMutationReq object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'vars',
      serializers.serialize(
        object.vars,
        specifiedType: const FullType(
          _i3.GRegisterVocabularyExpressionMutationVars,
        ),
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
              _i2.GRegisterVocabularyExpressionMutationData,
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
  GRegisterVocabularyExpressionMutationReq deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GRegisterVocabularyExpressionMutationReqBuilder();

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
                    _i3.GRegisterVocabularyExpressionMutationVars,
                  ),
                )!
                as _i3.GRegisterVocabularyExpressionMutationVars,
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
                    _i2.GRegisterVocabularyExpressionMutationData,
                  ),
                )!
                as _i2.GRegisterVocabularyExpressionMutationData,
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

class _$GRequestExplanationGenerationMutationReqSerializer
    implements StructuredSerializer<GRequestExplanationGenerationMutationReq> {
  @override
  final Iterable<Type> types = const [
    GRequestExplanationGenerationMutationReq,
    _$GRequestExplanationGenerationMutationReq,
  ];
  @override
  final String wireName = 'GRequestExplanationGenerationMutationReq';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GRequestExplanationGenerationMutationReq object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'vars',
      serializers.serialize(
        object.vars,
        specifiedType: const FullType(
          _i3.GRequestExplanationGenerationMutationVars,
        ),
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
              _i2.GRequestExplanationGenerationMutationData,
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
  GRequestExplanationGenerationMutationReq deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GRequestExplanationGenerationMutationReqBuilder();

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
                    _i3.GRequestExplanationGenerationMutationVars,
                  ),
                )!
                as _i3.GRequestExplanationGenerationMutationVars,
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
                    _i2.GRequestExplanationGenerationMutationData,
                  ),
                )!
                as _i2.GRequestExplanationGenerationMutationData,
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

class _$GRequestImageGenerationMutationReqSerializer
    implements StructuredSerializer<GRequestImageGenerationMutationReq> {
  @override
  final Iterable<Type> types = const [
    GRequestImageGenerationMutationReq,
    _$GRequestImageGenerationMutationReq,
  ];
  @override
  final String wireName = 'GRequestImageGenerationMutationReq';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GRequestImageGenerationMutationReq object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'vars',
      serializers.serialize(
        object.vars,
        specifiedType: const FullType(_i3.GRequestImageGenerationMutationVars),
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
              _i2.GRequestImageGenerationMutationData,
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
  GRequestImageGenerationMutationReq deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GRequestImageGenerationMutationReqBuilder();

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
                    _i3.GRequestImageGenerationMutationVars,
                  ),
                )!
                as _i3.GRequestImageGenerationMutationVars,
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
                    _i2.GRequestImageGenerationMutationData,
                  ),
                )!
                as _i2.GRequestImageGenerationMutationData,
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

class _$GRetryGenerationMutationReqSerializer
    implements StructuredSerializer<GRetryGenerationMutationReq> {
  @override
  final Iterable<Type> types = const [
    GRetryGenerationMutationReq,
    _$GRetryGenerationMutationReq,
  ];
  @override
  final String wireName = 'GRetryGenerationMutationReq';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GRetryGenerationMutationReq object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'vars',
      serializers.serialize(
        object.vars,
        specifiedType: const FullType(_i3.GRetryGenerationMutationVars),
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
            specifiedType: const FullType(_i2.GRetryGenerationMutationData),
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
  GRetryGenerationMutationReq deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GRetryGenerationMutationReqBuilder();

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
                    _i3.GRetryGenerationMutationVars,
                  ),
                )!
                as _i3.GRetryGenerationMutationVars,
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
                    _i2.GRetryGenerationMutationData,
                  ),
                )!
                as _i2.GRetryGenerationMutationData,
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

class _$GRegisterVocabularyExpressionMutationReq
    extends GRegisterVocabularyExpressionMutationReq {
  @override
  final _i3.GRegisterVocabularyExpressionMutationVars vars;
  @override
  final _i4.Operation operation;
  @override
  final String? requestId;
  @override
  final _i2.GRegisterVocabularyExpressionMutationData? Function(
    _i2.GRegisterVocabularyExpressionMutationData?,
    _i2.GRegisterVocabularyExpressionMutationData?,
  )?
  updateResult;
  @override
  final _i2.GRegisterVocabularyExpressionMutationData? optimisticResponse;
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

  factory _$GRegisterVocabularyExpressionMutationReq([
    void Function(GRegisterVocabularyExpressionMutationReqBuilder)? updates,
  ]) => (GRegisterVocabularyExpressionMutationReqBuilder()..update(updates))
      ._build();

  _$GRegisterVocabularyExpressionMutationReq._({
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
  GRegisterVocabularyExpressionMutationReq rebuild(
    void Function(GRegisterVocabularyExpressionMutationReqBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GRegisterVocabularyExpressionMutationReqBuilder toBuilder() =>
      GRegisterVocabularyExpressionMutationReqBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    final dynamic _$dynamicOther = other;
    return other is GRegisterVocabularyExpressionMutationReq &&
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
    return (newBuiltValueToStringHelper(
            r'GRegisterVocabularyExpressionMutationReq',
          )
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

class GRegisterVocabularyExpressionMutationReqBuilder
    implements
        Builder<
          GRegisterVocabularyExpressionMutationReq,
          GRegisterVocabularyExpressionMutationReqBuilder
        > {
  _$GRegisterVocabularyExpressionMutationReq? _$v;

  _i3.GRegisterVocabularyExpressionMutationVarsBuilder? _vars;
  _i3.GRegisterVocabularyExpressionMutationVarsBuilder get vars =>
      _$this._vars ??= _i3.GRegisterVocabularyExpressionMutationVarsBuilder();
  set vars(_i3.GRegisterVocabularyExpressionMutationVarsBuilder? vars) =>
      _$this._vars = vars;

  _i4.Operation? _operation;
  _i4.Operation? get operation => _$this._operation;
  set operation(_i4.Operation? operation) => _$this._operation = operation;

  String? _requestId;
  String? get requestId => _$this._requestId;
  set requestId(String? requestId) => _$this._requestId = requestId;

  _i2.GRegisterVocabularyExpressionMutationData? Function(
    _i2.GRegisterVocabularyExpressionMutationData?,
    _i2.GRegisterVocabularyExpressionMutationData?,
  )?
  _updateResult;
  _i2.GRegisterVocabularyExpressionMutationData? Function(
    _i2.GRegisterVocabularyExpressionMutationData?,
    _i2.GRegisterVocabularyExpressionMutationData?,
  )?
  get updateResult => _$this._updateResult;
  set updateResult(
    _i2.GRegisterVocabularyExpressionMutationData? Function(
      _i2.GRegisterVocabularyExpressionMutationData?,
      _i2.GRegisterVocabularyExpressionMutationData?,
    )?
    updateResult,
  ) => _$this._updateResult = updateResult;

  _i2.GRegisterVocabularyExpressionMutationDataBuilder? _optimisticResponse;
  _i2.GRegisterVocabularyExpressionMutationDataBuilder get optimisticResponse =>
      _$this._optimisticResponse ??=
          _i2.GRegisterVocabularyExpressionMutationDataBuilder();
  set optimisticResponse(
    _i2.GRegisterVocabularyExpressionMutationDataBuilder? optimisticResponse,
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

  GRegisterVocabularyExpressionMutationReqBuilder() {
    GRegisterVocabularyExpressionMutationReq._initializeBuilder(this);
  }

  GRegisterVocabularyExpressionMutationReqBuilder get _$this {
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
  void replace(GRegisterVocabularyExpressionMutationReq other) {
    _$v = other as _$GRegisterVocabularyExpressionMutationReq;
  }

  @override
  void update(
    void Function(GRegisterVocabularyExpressionMutationReqBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GRegisterVocabularyExpressionMutationReq build() => _build();

  _$GRegisterVocabularyExpressionMutationReq _build() {
    _$GRegisterVocabularyExpressionMutationReq _$result;
    try {
      _$result =
          _$v ??
          _$GRegisterVocabularyExpressionMutationReq._(
            vars: vars.build(),
            operation: BuiltValueNullFieldError.checkNotNull(
              operation,
              r'GRegisterVocabularyExpressionMutationReq',
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
              r'GRegisterVocabularyExpressionMutationReq',
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
          r'GRegisterVocabularyExpressionMutationReq',
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

class _$GRequestExplanationGenerationMutationReq
    extends GRequestExplanationGenerationMutationReq {
  @override
  final _i3.GRequestExplanationGenerationMutationVars vars;
  @override
  final _i4.Operation operation;
  @override
  final String? requestId;
  @override
  final _i2.GRequestExplanationGenerationMutationData? Function(
    _i2.GRequestExplanationGenerationMutationData?,
    _i2.GRequestExplanationGenerationMutationData?,
  )?
  updateResult;
  @override
  final _i2.GRequestExplanationGenerationMutationData? optimisticResponse;
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

  factory _$GRequestExplanationGenerationMutationReq([
    void Function(GRequestExplanationGenerationMutationReqBuilder)? updates,
  ]) => (GRequestExplanationGenerationMutationReqBuilder()..update(updates))
      ._build();

  _$GRequestExplanationGenerationMutationReq._({
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
  GRequestExplanationGenerationMutationReq rebuild(
    void Function(GRequestExplanationGenerationMutationReqBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GRequestExplanationGenerationMutationReqBuilder toBuilder() =>
      GRequestExplanationGenerationMutationReqBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    final dynamic _$dynamicOther = other;
    return other is GRequestExplanationGenerationMutationReq &&
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
    return (newBuiltValueToStringHelper(
            r'GRequestExplanationGenerationMutationReq',
          )
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

class GRequestExplanationGenerationMutationReqBuilder
    implements
        Builder<
          GRequestExplanationGenerationMutationReq,
          GRequestExplanationGenerationMutationReqBuilder
        > {
  _$GRequestExplanationGenerationMutationReq? _$v;

  _i3.GRequestExplanationGenerationMutationVarsBuilder? _vars;
  _i3.GRequestExplanationGenerationMutationVarsBuilder get vars =>
      _$this._vars ??= _i3.GRequestExplanationGenerationMutationVarsBuilder();
  set vars(_i3.GRequestExplanationGenerationMutationVarsBuilder? vars) =>
      _$this._vars = vars;

  _i4.Operation? _operation;
  _i4.Operation? get operation => _$this._operation;
  set operation(_i4.Operation? operation) => _$this._operation = operation;

  String? _requestId;
  String? get requestId => _$this._requestId;
  set requestId(String? requestId) => _$this._requestId = requestId;

  _i2.GRequestExplanationGenerationMutationData? Function(
    _i2.GRequestExplanationGenerationMutationData?,
    _i2.GRequestExplanationGenerationMutationData?,
  )?
  _updateResult;
  _i2.GRequestExplanationGenerationMutationData? Function(
    _i2.GRequestExplanationGenerationMutationData?,
    _i2.GRequestExplanationGenerationMutationData?,
  )?
  get updateResult => _$this._updateResult;
  set updateResult(
    _i2.GRequestExplanationGenerationMutationData? Function(
      _i2.GRequestExplanationGenerationMutationData?,
      _i2.GRequestExplanationGenerationMutationData?,
    )?
    updateResult,
  ) => _$this._updateResult = updateResult;

  _i2.GRequestExplanationGenerationMutationDataBuilder? _optimisticResponse;
  _i2.GRequestExplanationGenerationMutationDataBuilder get optimisticResponse =>
      _$this._optimisticResponse ??=
          _i2.GRequestExplanationGenerationMutationDataBuilder();
  set optimisticResponse(
    _i2.GRequestExplanationGenerationMutationDataBuilder? optimisticResponse,
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

  GRequestExplanationGenerationMutationReqBuilder() {
    GRequestExplanationGenerationMutationReq._initializeBuilder(this);
  }

  GRequestExplanationGenerationMutationReqBuilder get _$this {
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
  void replace(GRequestExplanationGenerationMutationReq other) {
    _$v = other as _$GRequestExplanationGenerationMutationReq;
  }

  @override
  void update(
    void Function(GRequestExplanationGenerationMutationReqBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GRequestExplanationGenerationMutationReq build() => _build();

  _$GRequestExplanationGenerationMutationReq _build() {
    _$GRequestExplanationGenerationMutationReq _$result;
    try {
      _$result =
          _$v ??
          _$GRequestExplanationGenerationMutationReq._(
            vars: vars.build(),
            operation: BuiltValueNullFieldError.checkNotNull(
              operation,
              r'GRequestExplanationGenerationMutationReq',
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
              r'GRequestExplanationGenerationMutationReq',
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
          r'GRequestExplanationGenerationMutationReq',
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

class _$GRequestImageGenerationMutationReq
    extends GRequestImageGenerationMutationReq {
  @override
  final _i3.GRequestImageGenerationMutationVars vars;
  @override
  final _i4.Operation operation;
  @override
  final String? requestId;
  @override
  final _i2.GRequestImageGenerationMutationData? Function(
    _i2.GRequestImageGenerationMutationData?,
    _i2.GRequestImageGenerationMutationData?,
  )?
  updateResult;
  @override
  final _i2.GRequestImageGenerationMutationData? optimisticResponse;
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

  factory _$GRequestImageGenerationMutationReq([
    void Function(GRequestImageGenerationMutationReqBuilder)? updates,
  ]) => (GRequestImageGenerationMutationReqBuilder()..update(updates))._build();

  _$GRequestImageGenerationMutationReq._({
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
  GRequestImageGenerationMutationReq rebuild(
    void Function(GRequestImageGenerationMutationReqBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GRequestImageGenerationMutationReqBuilder toBuilder() =>
      GRequestImageGenerationMutationReqBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    final dynamic _$dynamicOther = other;
    return other is GRequestImageGenerationMutationReq &&
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
    return (newBuiltValueToStringHelper(r'GRequestImageGenerationMutationReq')
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

class GRequestImageGenerationMutationReqBuilder
    implements
        Builder<
          GRequestImageGenerationMutationReq,
          GRequestImageGenerationMutationReqBuilder
        > {
  _$GRequestImageGenerationMutationReq? _$v;

  _i3.GRequestImageGenerationMutationVarsBuilder? _vars;
  _i3.GRequestImageGenerationMutationVarsBuilder get vars =>
      _$this._vars ??= _i3.GRequestImageGenerationMutationVarsBuilder();
  set vars(_i3.GRequestImageGenerationMutationVarsBuilder? vars) =>
      _$this._vars = vars;

  _i4.Operation? _operation;
  _i4.Operation? get operation => _$this._operation;
  set operation(_i4.Operation? operation) => _$this._operation = operation;

  String? _requestId;
  String? get requestId => _$this._requestId;
  set requestId(String? requestId) => _$this._requestId = requestId;

  _i2.GRequestImageGenerationMutationData? Function(
    _i2.GRequestImageGenerationMutationData?,
    _i2.GRequestImageGenerationMutationData?,
  )?
  _updateResult;
  _i2.GRequestImageGenerationMutationData? Function(
    _i2.GRequestImageGenerationMutationData?,
    _i2.GRequestImageGenerationMutationData?,
  )?
  get updateResult => _$this._updateResult;
  set updateResult(
    _i2.GRequestImageGenerationMutationData? Function(
      _i2.GRequestImageGenerationMutationData?,
      _i2.GRequestImageGenerationMutationData?,
    )?
    updateResult,
  ) => _$this._updateResult = updateResult;

  _i2.GRequestImageGenerationMutationDataBuilder? _optimisticResponse;
  _i2.GRequestImageGenerationMutationDataBuilder get optimisticResponse =>
      _$this._optimisticResponse ??=
          _i2.GRequestImageGenerationMutationDataBuilder();
  set optimisticResponse(
    _i2.GRequestImageGenerationMutationDataBuilder? optimisticResponse,
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

  GRequestImageGenerationMutationReqBuilder() {
    GRequestImageGenerationMutationReq._initializeBuilder(this);
  }

  GRequestImageGenerationMutationReqBuilder get _$this {
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
  void replace(GRequestImageGenerationMutationReq other) {
    _$v = other as _$GRequestImageGenerationMutationReq;
  }

  @override
  void update(
    void Function(GRequestImageGenerationMutationReqBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GRequestImageGenerationMutationReq build() => _build();

  _$GRequestImageGenerationMutationReq _build() {
    _$GRequestImageGenerationMutationReq _$result;
    try {
      _$result =
          _$v ??
          _$GRequestImageGenerationMutationReq._(
            vars: vars.build(),
            operation: BuiltValueNullFieldError.checkNotNull(
              operation,
              r'GRequestImageGenerationMutationReq',
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
              r'GRequestImageGenerationMutationReq',
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
          r'GRequestImageGenerationMutationReq',
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

class _$GRetryGenerationMutationReq extends GRetryGenerationMutationReq {
  @override
  final _i3.GRetryGenerationMutationVars vars;
  @override
  final _i4.Operation operation;
  @override
  final String? requestId;
  @override
  final _i2.GRetryGenerationMutationData? Function(
    _i2.GRetryGenerationMutationData?,
    _i2.GRetryGenerationMutationData?,
  )?
  updateResult;
  @override
  final _i2.GRetryGenerationMutationData? optimisticResponse;
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

  factory _$GRetryGenerationMutationReq([
    void Function(GRetryGenerationMutationReqBuilder)? updates,
  ]) => (GRetryGenerationMutationReqBuilder()..update(updates))._build();

  _$GRetryGenerationMutationReq._({
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
  GRetryGenerationMutationReq rebuild(
    void Function(GRetryGenerationMutationReqBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GRetryGenerationMutationReqBuilder toBuilder() =>
      GRetryGenerationMutationReqBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    final dynamic _$dynamicOther = other;
    return other is GRetryGenerationMutationReq &&
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
    return (newBuiltValueToStringHelper(r'GRetryGenerationMutationReq')
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

class GRetryGenerationMutationReqBuilder
    implements
        Builder<
          GRetryGenerationMutationReq,
          GRetryGenerationMutationReqBuilder
        > {
  _$GRetryGenerationMutationReq? _$v;

  _i3.GRetryGenerationMutationVarsBuilder? _vars;
  _i3.GRetryGenerationMutationVarsBuilder get vars =>
      _$this._vars ??= _i3.GRetryGenerationMutationVarsBuilder();
  set vars(_i3.GRetryGenerationMutationVarsBuilder? vars) =>
      _$this._vars = vars;

  _i4.Operation? _operation;
  _i4.Operation? get operation => _$this._operation;
  set operation(_i4.Operation? operation) => _$this._operation = operation;

  String? _requestId;
  String? get requestId => _$this._requestId;
  set requestId(String? requestId) => _$this._requestId = requestId;

  _i2.GRetryGenerationMutationData? Function(
    _i2.GRetryGenerationMutationData?,
    _i2.GRetryGenerationMutationData?,
  )?
  _updateResult;
  _i2.GRetryGenerationMutationData? Function(
    _i2.GRetryGenerationMutationData?,
    _i2.GRetryGenerationMutationData?,
  )?
  get updateResult => _$this._updateResult;
  set updateResult(
    _i2.GRetryGenerationMutationData? Function(
      _i2.GRetryGenerationMutationData?,
      _i2.GRetryGenerationMutationData?,
    )?
    updateResult,
  ) => _$this._updateResult = updateResult;

  _i2.GRetryGenerationMutationDataBuilder? _optimisticResponse;
  _i2.GRetryGenerationMutationDataBuilder get optimisticResponse =>
      _$this._optimisticResponse ??= _i2.GRetryGenerationMutationDataBuilder();
  set optimisticResponse(
    _i2.GRetryGenerationMutationDataBuilder? optimisticResponse,
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

  GRetryGenerationMutationReqBuilder() {
    GRetryGenerationMutationReq._initializeBuilder(this);
  }

  GRetryGenerationMutationReqBuilder get _$this {
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
  void replace(GRetryGenerationMutationReq other) {
    _$v = other as _$GRetryGenerationMutationReq;
  }

  @override
  void update(void Function(GRetryGenerationMutationReqBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GRetryGenerationMutationReq build() => _build();

  _$GRetryGenerationMutationReq _build() {
    _$GRetryGenerationMutationReq _$result;
    try {
      _$result =
          _$v ??
          _$GRetryGenerationMutationReq._(
            vars: vars.build(),
            operation: BuiltValueNullFieldError.checkNotNull(
              operation,
              r'GRetryGenerationMutationReq',
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
              r'GRetryGenerationMutationReq',
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
          r'GRetryGenerationMutationReq',
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
