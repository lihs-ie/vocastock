// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commands.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GRegisterVocabularyExpressionMutationVars>
_$gRegisterVocabularyExpressionMutationVarsSerializer =
    _$GRegisterVocabularyExpressionMutationVarsSerializer();
Serializer<GRequestExplanationGenerationMutationVars>
_$gRequestExplanationGenerationMutationVarsSerializer =
    _$GRequestExplanationGenerationMutationVarsSerializer();
Serializer<GRequestImageGenerationMutationVars>
_$gRequestImageGenerationMutationVarsSerializer =
    _$GRequestImageGenerationMutationVarsSerializer();
Serializer<GRetryGenerationMutationVars>
_$gRetryGenerationMutationVarsSerializer =
    _$GRetryGenerationMutationVarsSerializer();

class _$GRegisterVocabularyExpressionMutationVarsSerializer
    implements StructuredSerializer<GRegisterVocabularyExpressionMutationVars> {
  @override
  final Iterable<Type> types = const [
    GRegisterVocabularyExpressionMutationVars,
    _$GRegisterVocabularyExpressionMutationVars,
  ];
  @override
  final String wireName = 'GRegisterVocabularyExpressionMutationVars';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GRegisterVocabularyExpressionMutationVars object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'input',
      serializers.serialize(
        object.input,
        specifiedType: const FullType(_i1.GRegisterVocabularyExpressionInput),
      ),
    ];

    return result;
  }

  @override
  GRegisterVocabularyExpressionMutationVars deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GRegisterVocabularyExpressionMutationVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'input':
          result.input.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(
                    _i1.GRegisterVocabularyExpressionInput,
                  ),
                )!
                as _i1.GRegisterVocabularyExpressionInput,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$GRequestExplanationGenerationMutationVarsSerializer
    implements StructuredSerializer<GRequestExplanationGenerationMutationVars> {
  @override
  final Iterable<Type> types = const [
    GRequestExplanationGenerationMutationVars,
    _$GRequestExplanationGenerationMutationVars,
  ];
  @override
  final String wireName = 'GRequestExplanationGenerationMutationVars';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GRequestExplanationGenerationMutationVars object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'input',
      serializers.serialize(
        object.input,
        specifiedType: const FullType(_i1.GRequestGenerationInput),
      ),
    ];

    return result;
  }

  @override
  GRequestExplanationGenerationMutationVars deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GRequestExplanationGenerationMutationVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'input':
          result.input.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(_i1.GRequestGenerationInput),
                )!
                as _i1.GRequestGenerationInput,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$GRequestImageGenerationMutationVarsSerializer
    implements StructuredSerializer<GRequestImageGenerationMutationVars> {
  @override
  final Iterable<Type> types = const [
    GRequestImageGenerationMutationVars,
    _$GRequestImageGenerationMutationVars,
  ];
  @override
  final String wireName = 'GRequestImageGenerationMutationVars';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GRequestImageGenerationMutationVars object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'input',
      serializers.serialize(
        object.input,
        specifiedType: const FullType(_i1.GRequestGenerationInput),
      ),
    ];

    return result;
  }

  @override
  GRequestImageGenerationMutationVars deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GRequestImageGenerationMutationVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'input':
          result.input.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(_i1.GRequestGenerationInput),
                )!
                as _i1.GRequestGenerationInput,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$GRetryGenerationMutationVarsSerializer
    implements StructuredSerializer<GRetryGenerationMutationVars> {
  @override
  final Iterable<Type> types = const [
    GRetryGenerationMutationVars,
    _$GRetryGenerationMutationVars,
  ];
  @override
  final String wireName = 'GRetryGenerationMutationVars';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GRetryGenerationMutationVars object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'input',
      serializers.serialize(
        object.input,
        specifiedType: const FullType(_i1.GRetryGenerationInput),
      ),
    ];

    return result;
  }

  @override
  GRetryGenerationMutationVars deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GRetryGenerationMutationVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'input':
          result.input.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(_i1.GRetryGenerationInput),
                )!
                as _i1.GRetryGenerationInput,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$GRegisterVocabularyExpressionMutationVars
    extends GRegisterVocabularyExpressionMutationVars {
  @override
  final _i1.GRegisterVocabularyExpressionInput input;

  factory _$GRegisterVocabularyExpressionMutationVars([
    void Function(GRegisterVocabularyExpressionMutationVarsBuilder)? updates,
  ]) => (GRegisterVocabularyExpressionMutationVarsBuilder()..update(updates))
      ._build();

  _$GRegisterVocabularyExpressionMutationVars._({required this.input})
    : super._();
  @override
  GRegisterVocabularyExpressionMutationVars rebuild(
    void Function(GRegisterVocabularyExpressionMutationVarsBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GRegisterVocabularyExpressionMutationVarsBuilder toBuilder() =>
      GRegisterVocabularyExpressionMutationVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRegisterVocabularyExpressionMutationVars &&
        input == other.input;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, input.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'GRegisterVocabularyExpressionMutationVars',
    )..add('input', input)).toString();
  }
}

class GRegisterVocabularyExpressionMutationVarsBuilder
    implements
        Builder<
          GRegisterVocabularyExpressionMutationVars,
          GRegisterVocabularyExpressionMutationVarsBuilder
        > {
  _$GRegisterVocabularyExpressionMutationVars? _$v;

  _i1.GRegisterVocabularyExpressionInputBuilder? _input;
  _i1.GRegisterVocabularyExpressionInputBuilder get input =>
      _$this._input ??= _i1.GRegisterVocabularyExpressionInputBuilder();
  set input(_i1.GRegisterVocabularyExpressionInputBuilder? input) =>
      _$this._input = input;

  GRegisterVocabularyExpressionMutationVarsBuilder();

  GRegisterVocabularyExpressionMutationVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _input = $v.input.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRegisterVocabularyExpressionMutationVars other) {
    _$v = other as _$GRegisterVocabularyExpressionMutationVars;
  }

  @override
  void update(
    void Function(GRegisterVocabularyExpressionMutationVarsBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GRegisterVocabularyExpressionMutationVars build() => _build();

  _$GRegisterVocabularyExpressionMutationVars _build() {
    _$GRegisterVocabularyExpressionMutationVars _$result;
    try {
      _$result =
          _$v ??
          _$GRegisterVocabularyExpressionMutationVars._(input: input.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'input';
        input.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GRegisterVocabularyExpressionMutationVars',
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

class _$GRequestExplanationGenerationMutationVars
    extends GRequestExplanationGenerationMutationVars {
  @override
  final _i1.GRequestGenerationInput input;

  factory _$GRequestExplanationGenerationMutationVars([
    void Function(GRequestExplanationGenerationMutationVarsBuilder)? updates,
  ]) => (GRequestExplanationGenerationMutationVarsBuilder()..update(updates))
      ._build();

  _$GRequestExplanationGenerationMutationVars._({required this.input})
    : super._();
  @override
  GRequestExplanationGenerationMutationVars rebuild(
    void Function(GRequestExplanationGenerationMutationVarsBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GRequestExplanationGenerationMutationVarsBuilder toBuilder() =>
      GRequestExplanationGenerationMutationVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRequestExplanationGenerationMutationVars &&
        input == other.input;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, input.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'GRequestExplanationGenerationMutationVars',
    )..add('input', input)).toString();
  }
}

class GRequestExplanationGenerationMutationVarsBuilder
    implements
        Builder<
          GRequestExplanationGenerationMutationVars,
          GRequestExplanationGenerationMutationVarsBuilder
        > {
  _$GRequestExplanationGenerationMutationVars? _$v;

  _i1.GRequestGenerationInputBuilder? _input;
  _i1.GRequestGenerationInputBuilder get input =>
      _$this._input ??= _i1.GRequestGenerationInputBuilder();
  set input(_i1.GRequestGenerationInputBuilder? input) => _$this._input = input;

  GRequestExplanationGenerationMutationVarsBuilder();

  GRequestExplanationGenerationMutationVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _input = $v.input.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRequestExplanationGenerationMutationVars other) {
    _$v = other as _$GRequestExplanationGenerationMutationVars;
  }

  @override
  void update(
    void Function(GRequestExplanationGenerationMutationVarsBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GRequestExplanationGenerationMutationVars build() => _build();

  _$GRequestExplanationGenerationMutationVars _build() {
    _$GRequestExplanationGenerationMutationVars _$result;
    try {
      _$result =
          _$v ??
          _$GRequestExplanationGenerationMutationVars._(input: input.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'input';
        input.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GRequestExplanationGenerationMutationVars',
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

class _$GRequestImageGenerationMutationVars
    extends GRequestImageGenerationMutationVars {
  @override
  final _i1.GRequestGenerationInput input;

  factory _$GRequestImageGenerationMutationVars([
    void Function(GRequestImageGenerationMutationVarsBuilder)? updates,
  ]) =>
      (GRequestImageGenerationMutationVarsBuilder()..update(updates))._build();

  _$GRequestImageGenerationMutationVars._({required this.input}) : super._();
  @override
  GRequestImageGenerationMutationVars rebuild(
    void Function(GRequestImageGenerationMutationVarsBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GRequestImageGenerationMutationVarsBuilder toBuilder() =>
      GRequestImageGenerationMutationVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRequestImageGenerationMutationVars && input == other.input;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, input.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'GRequestImageGenerationMutationVars',
    )..add('input', input)).toString();
  }
}

class GRequestImageGenerationMutationVarsBuilder
    implements
        Builder<
          GRequestImageGenerationMutationVars,
          GRequestImageGenerationMutationVarsBuilder
        > {
  _$GRequestImageGenerationMutationVars? _$v;

  _i1.GRequestGenerationInputBuilder? _input;
  _i1.GRequestGenerationInputBuilder get input =>
      _$this._input ??= _i1.GRequestGenerationInputBuilder();
  set input(_i1.GRequestGenerationInputBuilder? input) => _$this._input = input;

  GRequestImageGenerationMutationVarsBuilder();

  GRequestImageGenerationMutationVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _input = $v.input.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRequestImageGenerationMutationVars other) {
    _$v = other as _$GRequestImageGenerationMutationVars;
  }

  @override
  void update(
    void Function(GRequestImageGenerationMutationVarsBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GRequestImageGenerationMutationVars build() => _build();

  _$GRequestImageGenerationMutationVars _build() {
    _$GRequestImageGenerationMutationVars _$result;
    try {
      _$result =
          _$v ?? _$GRequestImageGenerationMutationVars._(input: input.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'input';
        input.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GRequestImageGenerationMutationVars',
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

class _$GRetryGenerationMutationVars extends GRetryGenerationMutationVars {
  @override
  final _i1.GRetryGenerationInput input;

  factory _$GRetryGenerationMutationVars([
    void Function(GRetryGenerationMutationVarsBuilder)? updates,
  ]) => (GRetryGenerationMutationVarsBuilder()..update(updates))._build();

  _$GRetryGenerationMutationVars._({required this.input}) : super._();
  @override
  GRetryGenerationMutationVars rebuild(
    void Function(GRetryGenerationMutationVarsBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GRetryGenerationMutationVarsBuilder toBuilder() =>
      GRetryGenerationMutationVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRetryGenerationMutationVars && input == other.input;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, input.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'GRetryGenerationMutationVars',
    )..add('input', input)).toString();
  }
}

class GRetryGenerationMutationVarsBuilder
    implements
        Builder<
          GRetryGenerationMutationVars,
          GRetryGenerationMutationVarsBuilder
        > {
  _$GRetryGenerationMutationVars? _$v;

  _i1.GRetryGenerationInputBuilder? _input;
  _i1.GRetryGenerationInputBuilder get input =>
      _$this._input ??= _i1.GRetryGenerationInputBuilder();
  set input(_i1.GRetryGenerationInputBuilder? input) => _$this._input = input;

  GRetryGenerationMutationVarsBuilder();

  GRetryGenerationMutationVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _input = $v.input.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRetryGenerationMutationVars other) {
    _$v = other as _$GRetryGenerationMutationVars;
  }

  @override
  void update(void Function(GRetryGenerationMutationVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GRetryGenerationMutationVars build() => _build();

  _$GRetryGenerationMutationVars _build() {
    _$GRetryGenerationMutationVars _$result;
    try {
      _$result = _$v ?? _$GRetryGenerationMutationVars._(input: input.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'input';
        input.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GRetryGenerationMutationVars',
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
