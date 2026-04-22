// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_state.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GLearningStateQueryData> _$gLearningStateQueryDataSerializer =
    _$GLearningStateQueryDataSerializer();
Serializer<GLearningStateQueryData_learningState>
_$gLearningStateQueryDataLearningStateSerializer =
    _$GLearningStateQueryData_learningStateSerializer();

class _$GLearningStateQueryDataSerializer
    implements StructuredSerializer<GLearningStateQueryData> {
  @override
  final Iterable<Type> types = const [
    GLearningStateQueryData,
    _$GLearningStateQueryData,
  ];
  @override
  final String wireName = 'GLearningStateQueryData';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GLearningStateQueryData object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
    ];
    Object? value;
    value = object.learningState;
    if (value != null) {
      result
        ..add('learningState')
        ..add(
          serializers.serialize(
            value,
            specifiedType: const FullType(
              GLearningStateQueryData_learningState,
            ),
          ),
        );
    }
    return result;
  }

  @override
  GLearningStateQueryData deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GLearningStateQueryDataBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'learningState':
          result.learningState.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(
                    GLearningStateQueryData_learningState,
                  ),
                )!
                as GLearningStateQueryData_learningState,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$GLearningStateQueryData_learningStateSerializer
    implements StructuredSerializer<GLearningStateQueryData_learningState> {
  @override
  final Iterable<Type> types = const [
    GLearningStateQueryData_learningState,
    _$GLearningStateQueryData_learningState,
  ];
  @override
  final String wireName = 'GLearningStateQueryData_learningState';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GLearningStateQueryData_learningState object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
      'vocabularyExpression',
      serializers.serialize(
        object.vocabularyExpression,
        specifiedType: const FullType(String),
      ),
      'proficiency',
      serializers.serialize(
        object.proficiency,
        specifiedType: const FullType(_i2.GProficiencyLevel),
      ),
    ];

    return result;
  }

  @override
  GLearningStateQueryData_learningState deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GLearningStateQueryData_learningStateBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'vocabularyExpression':
          result.vocabularyExpression =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'proficiency':
          result.proficiency =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(_i2.GProficiencyLevel),
                  )!
                  as _i2.GProficiencyLevel;
          break;
      }
    }

    return result.build();
  }
}

class _$GLearningStateQueryData extends GLearningStateQueryData {
  @override
  final String G__typename;
  @override
  final GLearningStateQueryData_learningState? learningState;

  factory _$GLearningStateQueryData([
    void Function(GLearningStateQueryDataBuilder)? updates,
  ]) => (GLearningStateQueryDataBuilder()..update(updates))._build();

  _$GLearningStateQueryData._({required this.G__typename, this.learningState})
    : super._();
  @override
  GLearningStateQueryData rebuild(
    void Function(GLearningStateQueryDataBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GLearningStateQueryDataBuilder toBuilder() =>
      GLearningStateQueryDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GLearningStateQueryData &&
        G__typename == other.G__typename &&
        learningState == other.learningState;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, learningState.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GLearningStateQueryData')
          ..add('G__typename', G__typename)
          ..add('learningState', learningState))
        .toString();
  }
}

class GLearningStateQueryDataBuilder
    implements
        Builder<GLearningStateQueryData, GLearningStateQueryDataBuilder> {
  _$GLearningStateQueryData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GLearningStateQueryData_learningStateBuilder? _learningState;
  GLearningStateQueryData_learningStateBuilder get learningState =>
      _$this._learningState ??= GLearningStateQueryData_learningStateBuilder();
  set learningState(
    GLearningStateQueryData_learningStateBuilder? learningState,
  ) => _$this._learningState = learningState;

  GLearningStateQueryDataBuilder() {
    GLearningStateQueryData._initializeBuilder(this);
  }

  GLearningStateQueryDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _learningState = $v.learningState?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GLearningStateQueryData other) {
    _$v = other as _$GLearningStateQueryData;
  }

  @override
  void update(void Function(GLearningStateQueryDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GLearningStateQueryData build() => _build();

  _$GLearningStateQueryData _build() {
    _$GLearningStateQueryData _$result;
    try {
      _$result =
          _$v ??
          _$GLearningStateQueryData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GLearningStateQueryData',
              'G__typename',
            ),
            learningState: _learningState?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'learningState';
        _learningState?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GLearningStateQueryData',
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

class _$GLearningStateQueryData_learningState
    extends GLearningStateQueryData_learningState {
  @override
  final String G__typename;
  @override
  final String vocabularyExpression;
  @override
  final _i2.GProficiencyLevel proficiency;

  factory _$GLearningStateQueryData_learningState([
    void Function(GLearningStateQueryData_learningStateBuilder)? updates,
  ]) => (GLearningStateQueryData_learningStateBuilder()..update(updates))
      ._build();

  _$GLearningStateQueryData_learningState._({
    required this.G__typename,
    required this.vocabularyExpression,
    required this.proficiency,
  }) : super._();
  @override
  GLearningStateQueryData_learningState rebuild(
    void Function(GLearningStateQueryData_learningStateBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GLearningStateQueryData_learningStateBuilder toBuilder() =>
      GLearningStateQueryData_learningStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GLearningStateQueryData_learningState &&
        G__typename == other.G__typename &&
        vocabularyExpression == other.vocabularyExpression &&
        proficiency == other.proficiency;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, vocabularyExpression.hashCode);
    _$hash = $jc(_$hash, proficiency.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GLearningStateQueryData_learningState',
          )
          ..add('G__typename', G__typename)
          ..add('vocabularyExpression', vocabularyExpression)
          ..add('proficiency', proficiency))
        .toString();
  }
}

class GLearningStateQueryData_learningStateBuilder
    implements
        Builder<
          GLearningStateQueryData_learningState,
          GLearningStateQueryData_learningStateBuilder
        > {
  _$GLearningStateQueryData_learningState? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _vocabularyExpression;
  String? get vocabularyExpression => _$this._vocabularyExpression;
  set vocabularyExpression(String? vocabularyExpression) =>
      _$this._vocabularyExpression = vocabularyExpression;

  _i2.GProficiencyLevel? _proficiency;
  _i2.GProficiencyLevel? get proficiency => _$this._proficiency;
  set proficiency(_i2.GProficiencyLevel? proficiency) =>
      _$this._proficiency = proficiency;

  GLearningStateQueryData_learningStateBuilder() {
    GLearningStateQueryData_learningState._initializeBuilder(this);
  }

  GLearningStateQueryData_learningStateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _vocabularyExpression = $v.vocabularyExpression;
      _proficiency = $v.proficiency;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GLearningStateQueryData_learningState other) {
    _$v = other as _$GLearningStateQueryData_learningState;
  }

  @override
  void update(
    void Function(GLearningStateQueryData_learningStateBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GLearningStateQueryData_learningState build() => _build();

  _$GLearningStateQueryData_learningState _build() {
    final _$result =
        _$v ??
        _$GLearningStateQueryData_learningState._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
            G__typename,
            r'GLearningStateQueryData_learningState',
            'G__typename',
          ),
          vocabularyExpression: BuiltValueNullFieldError.checkNotNull(
            vocabularyExpression,
            r'GLearningStateQueryData_learningState',
            'vocabularyExpression',
          ),
          proficiency: BuiltValueNullFieldError.checkNotNull(
            proficiency,
            r'GLearningStateQueryData_learningState',
            'proficiency',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
