// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocabulary_catalog.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GVocabularyCatalogQueryVars>
_$gVocabularyCatalogQueryVarsSerializer =
    _$GVocabularyCatalogQueryVarsSerializer();
Serializer<GVocabularyExpressionDetailQueryVars>
_$gVocabularyExpressionDetailQueryVarsSerializer =
    _$GVocabularyExpressionDetailQueryVarsSerializer();

class _$GVocabularyCatalogQueryVarsSerializer
    implements StructuredSerializer<GVocabularyCatalogQueryVars> {
  @override
  final Iterable<Type> types = const [
    GVocabularyCatalogQueryVars,
    _$GVocabularyCatalogQueryVars,
  ];
  @override
  final String wireName = 'GVocabularyCatalogQueryVars';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GVocabularyCatalogQueryVars object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return <Object?>[];
  }

  @override
  GVocabularyCatalogQueryVars deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return GVocabularyCatalogQueryVarsBuilder().build();
  }
}

class _$GVocabularyExpressionDetailQueryVarsSerializer
    implements StructuredSerializer<GVocabularyExpressionDetailQueryVars> {
  @override
  final Iterable<Type> types = const [
    GVocabularyExpressionDetailQueryVars,
    _$GVocabularyExpressionDetailQueryVars,
  ];
  @override
  final String wireName = 'GVocabularyExpressionDetailQueryVars';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GVocabularyExpressionDetailQueryVars object, {
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
  GVocabularyExpressionDetailQueryVars deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GVocabularyExpressionDetailQueryVarsBuilder();

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

class _$GVocabularyCatalogQueryVars extends GVocabularyCatalogQueryVars {
  factory _$GVocabularyCatalogQueryVars([
    void Function(GVocabularyCatalogQueryVarsBuilder)? updates,
  ]) => (GVocabularyCatalogQueryVarsBuilder()..update(updates))._build();

  _$GVocabularyCatalogQueryVars._() : super._();
  @override
  GVocabularyCatalogQueryVars rebuild(
    void Function(GVocabularyCatalogQueryVarsBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GVocabularyCatalogQueryVarsBuilder toBuilder() =>
      GVocabularyCatalogQueryVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GVocabularyCatalogQueryVars;
  }

  @override
  int get hashCode {
    return 606955085;
  }

  @override
  String toString() {
    return newBuiltValueToStringHelper(
      r'GVocabularyCatalogQueryVars',
    ).toString();
  }
}

class GVocabularyCatalogQueryVarsBuilder
    implements
        Builder<
          GVocabularyCatalogQueryVars,
          GVocabularyCatalogQueryVarsBuilder
        > {
  _$GVocabularyCatalogQueryVars? _$v;

  GVocabularyCatalogQueryVarsBuilder();

  @override
  void replace(GVocabularyCatalogQueryVars other) {
    _$v = other as _$GVocabularyCatalogQueryVars;
  }

  @override
  void update(void Function(GVocabularyCatalogQueryVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GVocabularyCatalogQueryVars build() => _build();

  _$GVocabularyCatalogQueryVars _build() {
    final _$result = _$v ?? _$GVocabularyCatalogQueryVars._();
    replace(_$result);
    return _$result;
  }
}

class _$GVocabularyExpressionDetailQueryVars
    extends GVocabularyExpressionDetailQueryVars {
  @override
  final String identifier;

  factory _$GVocabularyExpressionDetailQueryVars([
    void Function(GVocabularyExpressionDetailQueryVarsBuilder)? updates,
  ]) =>
      (GVocabularyExpressionDetailQueryVarsBuilder()..update(updates))._build();

  _$GVocabularyExpressionDetailQueryVars._({required this.identifier})
    : super._();
  @override
  GVocabularyExpressionDetailQueryVars rebuild(
    void Function(GVocabularyExpressionDetailQueryVarsBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GVocabularyExpressionDetailQueryVarsBuilder toBuilder() =>
      GVocabularyExpressionDetailQueryVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GVocabularyExpressionDetailQueryVars &&
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
      r'GVocabularyExpressionDetailQueryVars',
    )..add('identifier', identifier)).toString();
  }
}

class GVocabularyExpressionDetailQueryVarsBuilder
    implements
        Builder<
          GVocabularyExpressionDetailQueryVars,
          GVocabularyExpressionDetailQueryVarsBuilder
        > {
  _$GVocabularyExpressionDetailQueryVars? _$v;

  String? _identifier;
  String? get identifier => _$this._identifier;
  set identifier(String? identifier) => _$this._identifier = identifier;

  GVocabularyExpressionDetailQueryVarsBuilder();

  GVocabularyExpressionDetailQueryVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _identifier = $v.identifier;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GVocabularyExpressionDetailQueryVars other) {
    _$v = other as _$GVocabularyExpressionDetailQueryVars;
  }

  @override
  void update(
    void Function(GVocabularyExpressionDetailQueryVarsBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GVocabularyExpressionDetailQueryVars build() => _build();

  _$GVocabularyExpressionDetailQueryVars _build() {
    final _$result =
        _$v ??
        _$GVocabularyExpressionDetailQueryVars._(
          identifier: BuiltValueNullFieldError.checkNotNull(
            identifier,
            r'GVocabularyExpressionDetailQueryVars',
            'identifier',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
