// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_state.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GLearningStateQueryVars> _$gLearningStateQueryVarsSerializer =
    _$GLearningStateQueryVarsSerializer();
Serializer<GLearningStatesQueryVars> _$gLearningStatesQueryVarsSerializer =
    _$GLearningStatesQueryVarsSerializer();

class _$GLearningStateQueryVarsSerializer
    implements StructuredSerializer<GLearningStateQueryVars> {
  @override
  final Iterable<Type> types = const [
    GLearningStateQueryVars,
    _$GLearningStateQueryVars,
  ];
  @override
  final String wireName = 'GLearningStateQueryVars';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GLearningStateQueryVars object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'identifier',
      serializers.serialize(
        object.identifier,
        specifiedType: const FullType(String),
      ),
    ];

    return result;
  }

  @override
  GLearningStateQueryVars deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GLearningStateQueryVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'identifier':
          result.identifier =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
      }
    }

    return result.build();
  }
}

class _$GLearningStatesQueryVarsSerializer
    implements StructuredSerializer<GLearningStatesQueryVars> {
  @override
  final Iterable<Type> types = const [
    GLearningStatesQueryVars,
    _$GLearningStatesQueryVars,
  ];
  @override
  final String wireName = 'GLearningStatesQueryVars';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GLearningStatesQueryVars object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return <Object?>[];
  }

  @override
  GLearningStatesQueryVars deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return GLearningStatesQueryVarsBuilder().build();
  }
}

class _$GLearningStateQueryVars extends GLearningStateQueryVars {
  @override
  final String identifier;

  factory _$GLearningStateQueryVars([
    void Function(GLearningStateQueryVarsBuilder)? updates,
  ]) => (GLearningStateQueryVarsBuilder()..update(updates))._build();

  _$GLearningStateQueryVars._({required this.identifier}) : super._();
  @override
  GLearningStateQueryVars rebuild(
    void Function(GLearningStateQueryVarsBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GLearningStateQueryVarsBuilder toBuilder() =>
      GLearningStateQueryVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GLearningStateQueryVars && identifier == other.identifier;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, identifier.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'GLearningStateQueryVars',
    )..add('identifier', identifier)).toString();
  }
}

class GLearningStateQueryVarsBuilder
    implements
        Builder<GLearningStateQueryVars, GLearningStateQueryVarsBuilder> {
  _$GLearningStateQueryVars? _$v;

  String? _identifier;
  String? get identifier => _$this._identifier;
  set identifier(String? identifier) => _$this._identifier = identifier;

  GLearningStateQueryVarsBuilder();

  GLearningStateQueryVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _identifier = $v.identifier;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GLearningStateQueryVars other) {
    _$v = other as _$GLearningStateQueryVars;
  }

  @override
  void update(void Function(GLearningStateQueryVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GLearningStateQueryVars build() => _build();

  _$GLearningStateQueryVars _build() {
    final _$result =
        _$v ??
        _$GLearningStateQueryVars._(
          identifier: BuiltValueNullFieldError.checkNotNull(
            identifier,
            r'GLearningStateQueryVars',
            'identifier',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GLearningStatesQueryVars extends GLearningStatesQueryVars {
  factory _$GLearningStatesQueryVars([
    void Function(GLearningStatesQueryVarsBuilder)? updates,
  ]) => (GLearningStatesQueryVarsBuilder()..update(updates))._build();

  _$GLearningStatesQueryVars._() : super._();
  @override
  GLearningStatesQueryVars rebuild(
    void Function(GLearningStatesQueryVarsBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GLearningStatesQueryVarsBuilder toBuilder() =>
      GLearningStatesQueryVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GLearningStatesQueryVars;
  }

  @override
  int get hashCode {
    return 827205671;
  }

  @override
  String toString() {
    return newBuiltValueToStringHelper(r'GLearningStatesQueryVars').toString();
  }
}

class GLearningStatesQueryVarsBuilder
    implements
        Builder<GLearningStatesQueryVars, GLearningStatesQueryVarsBuilder> {
  _$GLearningStatesQueryVars? _$v;

  GLearningStatesQueryVarsBuilder();

  @override
  void replace(GLearningStatesQueryVars other) {
    _$v = other as _$GLearningStatesQueryVars;
  }

  @override
  void update(void Function(GLearningStatesQueryVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GLearningStatesQueryVars build() => _build();

  _$GLearningStatesQueryVars _build() {
    final _$result = _$v ?? _$GLearningStatesQueryVars._();
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
