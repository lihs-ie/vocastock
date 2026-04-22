// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'completed_details.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GExplanationDetailQueryVars>
_$gExplanationDetailQueryVarsSerializer =
    _$GExplanationDetailQueryVarsSerializer();
Serializer<GImageDetailQueryVars> _$gImageDetailQueryVarsSerializer =
    _$GImageDetailQueryVarsSerializer();

class _$GExplanationDetailQueryVarsSerializer
    implements StructuredSerializer<GExplanationDetailQueryVars> {
  @override
  final Iterable<Type> types = const [
    GExplanationDetailQueryVars,
    _$GExplanationDetailQueryVars,
  ];
  @override
  final String wireName = 'GExplanationDetailQueryVars';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GExplanationDetailQueryVars object, {
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
  GExplanationDetailQueryVars deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GExplanationDetailQueryVarsBuilder();

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

class _$GImageDetailQueryVarsSerializer
    implements StructuredSerializer<GImageDetailQueryVars> {
  @override
  final Iterable<Type> types = const [
    GImageDetailQueryVars,
    _$GImageDetailQueryVars,
  ];
  @override
  final String wireName = 'GImageDetailQueryVars';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GImageDetailQueryVars object, {
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
  GImageDetailQueryVars deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GImageDetailQueryVarsBuilder();

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

class _$GExplanationDetailQueryVars extends GExplanationDetailQueryVars {
  @override
  final String identifier;

  factory _$GExplanationDetailQueryVars([
    void Function(GExplanationDetailQueryVarsBuilder)? updates,
  ]) => (GExplanationDetailQueryVarsBuilder()..update(updates))._build();

  _$GExplanationDetailQueryVars._({required this.identifier}) : super._();
  @override
  GExplanationDetailQueryVars rebuild(
    void Function(GExplanationDetailQueryVarsBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GExplanationDetailQueryVarsBuilder toBuilder() =>
      GExplanationDetailQueryVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GExplanationDetailQueryVars &&
        identifier == other.identifier;
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
      r'GExplanationDetailQueryVars',
    )..add('identifier', identifier)).toString();
  }
}

class GExplanationDetailQueryVarsBuilder
    implements
        Builder<
          GExplanationDetailQueryVars,
          GExplanationDetailQueryVarsBuilder
        > {
  _$GExplanationDetailQueryVars? _$v;

  String? _identifier;
  String? get identifier => _$this._identifier;
  set identifier(String? identifier) => _$this._identifier = identifier;

  GExplanationDetailQueryVarsBuilder();

  GExplanationDetailQueryVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _identifier = $v.identifier;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GExplanationDetailQueryVars other) {
    _$v = other as _$GExplanationDetailQueryVars;
  }

  @override
  void update(void Function(GExplanationDetailQueryVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GExplanationDetailQueryVars build() => _build();

  _$GExplanationDetailQueryVars _build() {
    final _$result =
        _$v ??
        _$GExplanationDetailQueryVars._(
          identifier: BuiltValueNullFieldError.checkNotNull(
            identifier,
            r'GExplanationDetailQueryVars',
            'identifier',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GImageDetailQueryVars extends GImageDetailQueryVars {
  @override
  final String identifier;

  factory _$GImageDetailQueryVars([
    void Function(GImageDetailQueryVarsBuilder)? updates,
  ]) => (GImageDetailQueryVarsBuilder()..update(updates))._build();

  _$GImageDetailQueryVars._({required this.identifier}) : super._();
  @override
  GImageDetailQueryVars rebuild(
    void Function(GImageDetailQueryVarsBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GImageDetailQueryVarsBuilder toBuilder() =>
      GImageDetailQueryVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GImageDetailQueryVars && identifier == other.identifier;
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
      r'GImageDetailQueryVars',
    )..add('identifier', identifier)).toString();
  }
}

class GImageDetailQueryVarsBuilder
    implements Builder<GImageDetailQueryVars, GImageDetailQueryVarsBuilder> {
  _$GImageDetailQueryVars? _$v;

  String? _identifier;
  String? get identifier => _$this._identifier;
  set identifier(String? identifier) => _$this._identifier = identifier;

  GImageDetailQueryVarsBuilder();

  GImageDetailQueryVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _identifier = $v.identifier;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GImageDetailQueryVars other) {
    _$v = other as _$GImageDetailQueryVars;
  }

  @override
  void update(void Function(GImageDetailQueryVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GImageDetailQueryVars build() => _build();

  _$GImageDetailQueryVars _build() {
    final _$result =
        _$v ??
        _$GImageDetailQueryVars._(
          identifier: BuiltValueNullFieldError.checkNotNull(
            identifier,
            r'GImageDetailQueryVars',
            'identifier',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
