// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'actor_handoff.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GActorHandoffStatusQueryVars>
_$gActorHandoffStatusQueryVarsSerializer =
    _$GActorHandoffStatusQueryVarsSerializer();
Serializer<GLearningStateQueryVars> _$gLearningStateQueryVarsSerializer =
    _$GLearningStateQueryVarsSerializer();

class _$GActorHandoffStatusQueryVarsSerializer
    implements StructuredSerializer<GActorHandoffStatusQueryVars> {
  @override
  final Iterable<Type> types = const [
    GActorHandoffStatusQueryVars,
    _$GActorHandoffStatusQueryVars,
  ];
  @override
  final String wireName = 'GActorHandoffStatusQueryVars';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GActorHandoffStatusQueryVars object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return <Object?>[];
  }

  @override
  GActorHandoffStatusQueryVars deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return GActorHandoffStatusQueryVarsBuilder().build();
  }
}

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

class _$GActorHandoffStatusQueryVars extends GActorHandoffStatusQueryVars {
  factory _$GActorHandoffStatusQueryVars([
    void Function(GActorHandoffStatusQueryVarsBuilder)? updates,
  ]) => (GActorHandoffStatusQueryVarsBuilder()..update(updates))._build();

  _$GActorHandoffStatusQueryVars._() : super._();
  @override
  GActorHandoffStatusQueryVars rebuild(
    void Function(GActorHandoffStatusQueryVarsBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GActorHandoffStatusQueryVarsBuilder toBuilder() =>
      GActorHandoffStatusQueryVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GActorHandoffStatusQueryVars;
  }

  @override
  int get hashCode {
    return 1006831169;
  }

  @override
  String toString() {
    return newBuiltValueToStringHelper(
      r'GActorHandoffStatusQueryVars',
    ).toString();
  }
}

class GActorHandoffStatusQueryVarsBuilder
    implements
        Builder<
          GActorHandoffStatusQueryVars,
          GActorHandoffStatusQueryVarsBuilder
        > {
  _$GActorHandoffStatusQueryVars? _$v;

  GActorHandoffStatusQueryVarsBuilder();

  @override
  void replace(GActorHandoffStatusQueryVars other) {
    _$v = other as _$GActorHandoffStatusQueryVars;
  }

  @override
  void update(void Function(GActorHandoffStatusQueryVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GActorHandoffStatusQueryVars build() => _build();

  _$GActorHandoffStatusQueryVars _build() {
    final _$result = _$v ?? _$GActorHandoffStatusQueryVars._();
    replace(_$result);
    return _$result;
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

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
