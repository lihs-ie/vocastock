// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GSubscriptionStatusQueryVars>
_$gSubscriptionStatusQueryVarsSerializer =
    _$GSubscriptionStatusQueryVarsSerializer();
Serializer<GRequestPurchaseMutationVars>
_$gRequestPurchaseMutationVarsSerializer =
    _$GRequestPurchaseMutationVarsSerializer();
Serializer<GRequestRestorePurchaseMutationVars>
_$gRequestRestorePurchaseMutationVarsSerializer =
    _$GRequestRestorePurchaseMutationVarsSerializer();

class _$GSubscriptionStatusQueryVarsSerializer
    implements StructuredSerializer<GSubscriptionStatusQueryVars> {
  @override
  final Iterable<Type> types = const [
    GSubscriptionStatusQueryVars,
    _$GSubscriptionStatusQueryVars,
  ];
  @override
  final String wireName = 'GSubscriptionStatusQueryVars';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GSubscriptionStatusQueryVars object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return <Object?>[];
  }

  @override
  GSubscriptionStatusQueryVars deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return GSubscriptionStatusQueryVarsBuilder().build();
  }
}

class _$GRequestPurchaseMutationVarsSerializer
    implements StructuredSerializer<GRequestPurchaseMutationVars> {
  @override
  final Iterable<Type> types = const [
    GRequestPurchaseMutationVars,
    _$GRequestPurchaseMutationVars,
  ];
  @override
  final String wireName = 'GRequestPurchaseMutationVars';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GRequestPurchaseMutationVars object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'input',
      serializers.serialize(
        object.input,
        specifiedType: const FullType(_i2.GRequestPurchaseInput),
      ),
    ];

    return result;
  }

  @override
  GRequestPurchaseMutationVars deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GRequestPurchaseMutationVarsBuilder();

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
                  specifiedType: const FullType(_i2.GRequestPurchaseInput),
                )!
                as _i2.GRequestPurchaseInput,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$GRequestRestorePurchaseMutationVarsSerializer
    implements StructuredSerializer<GRequestRestorePurchaseMutationVars> {
  @override
  final Iterable<Type> types = const [
    GRequestRestorePurchaseMutationVars,
    _$GRequestRestorePurchaseMutationVars,
  ];
  @override
  final String wireName = 'GRequestRestorePurchaseMutationVars';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GRequestRestorePurchaseMutationVars object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'input',
      serializers.serialize(
        object.input,
        specifiedType: const FullType(_i2.GRequestRestorePurchaseInput),
      ),
    ];

    return result;
  }

  @override
  GRequestRestorePurchaseMutationVars deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GRequestRestorePurchaseMutationVarsBuilder();

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
                    _i2.GRequestRestorePurchaseInput,
                  ),
                )!
                as _i2.GRequestRestorePurchaseInput,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$GSubscriptionStatusQueryVars extends GSubscriptionStatusQueryVars {
  factory _$GSubscriptionStatusQueryVars([
    void Function(GSubscriptionStatusQueryVarsBuilder)? updates,
  ]) => (GSubscriptionStatusQueryVarsBuilder()..update(updates))._build();

  _$GSubscriptionStatusQueryVars._() : super._();
  @override
  GSubscriptionStatusQueryVars rebuild(
    void Function(GSubscriptionStatusQueryVarsBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GSubscriptionStatusQueryVarsBuilder toBuilder() =>
      GSubscriptionStatusQueryVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GSubscriptionStatusQueryVars;
  }

  @override
  int get hashCode {
    return 1045893176;
  }

  @override
  String toString() {
    return newBuiltValueToStringHelper(
      r'GSubscriptionStatusQueryVars',
    ).toString();
  }
}

class GSubscriptionStatusQueryVarsBuilder
    implements
        Builder<
          GSubscriptionStatusQueryVars,
          GSubscriptionStatusQueryVarsBuilder
        > {
  _$GSubscriptionStatusQueryVars? _$v;

  GSubscriptionStatusQueryVarsBuilder();

  @override
  void replace(GSubscriptionStatusQueryVars other) {
    _$v = other as _$GSubscriptionStatusQueryVars;
  }

  @override
  void update(void Function(GSubscriptionStatusQueryVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GSubscriptionStatusQueryVars build() => _build();

  _$GSubscriptionStatusQueryVars _build() {
    final _$result = _$v ?? _$GSubscriptionStatusQueryVars._();
    replace(_$result);
    return _$result;
  }
}

class _$GRequestPurchaseMutationVars extends GRequestPurchaseMutationVars {
  @override
  final _i2.GRequestPurchaseInput input;

  factory _$GRequestPurchaseMutationVars([
    void Function(GRequestPurchaseMutationVarsBuilder)? updates,
  ]) => (GRequestPurchaseMutationVarsBuilder()..update(updates))._build();

  _$GRequestPurchaseMutationVars._({required this.input}) : super._();
  @override
  GRequestPurchaseMutationVars rebuild(
    void Function(GRequestPurchaseMutationVarsBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GRequestPurchaseMutationVarsBuilder toBuilder() =>
      GRequestPurchaseMutationVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRequestPurchaseMutationVars && input == other.input;
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
      r'GRequestPurchaseMutationVars',
    )..add('input', input)).toString();
  }
}

class GRequestPurchaseMutationVarsBuilder
    implements
        Builder<
          GRequestPurchaseMutationVars,
          GRequestPurchaseMutationVarsBuilder
        > {
  _$GRequestPurchaseMutationVars? _$v;

  _i2.GRequestPurchaseInputBuilder? _input;
  _i2.GRequestPurchaseInputBuilder get input =>
      _$this._input ??= _i2.GRequestPurchaseInputBuilder();
  set input(_i2.GRequestPurchaseInputBuilder? input) => _$this._input = input;

  GRequestPurchaseMutationVarsBuilder();

  GRequestPurchaseMutationVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _input = $v.input.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRequestPurchaseMutationVars other) {
    _$v = other as _$GRequestPurchaseMutationVars;
  }

  @override
  void update(void Function(GRequestPurchaseMutationVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GRequestPurchaseMutationVars build() => _build();

  _$GRequestPurchaseMutationVars _build() {
    _$GRequestPurchaseMutationVars _$result;
    try {
      _$result = _$v ?? _$GRequestPurchaseMutationVars._(input: input.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'input';
        input.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GRequestPurchaseMutationVars',
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

class _$GRequestRestorePurchaseMutationVars
    extends GRequestRestorePurchaseMutationVars {
  @override
  final _i2.GRequestRestorePurchaseInput input;

  factory _$GRequestRestorePurchaseMutationVars([
    void Function(GRequestRestorePurchaseMutationVarsBuilder)? updates,
  ]) =>
      (GRequestRestorePurchaseMutationVarsBuilder()..update(updates))._build();

  _$GRequestRestorePurchaseMutationVars._({required this.input}) : super._();
  @override
  GRequestRestorePurchaseMutationVars rebuild(
    void Function(GRequestRestorePurchaseMutationVarsBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GRequestRestorePurchaseMutationVarsBuilder toBuilder() =>
      GRequestRestorePurchaseMutationVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRequestRestorePurchaseMutationVars && input == other.input;
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
      r'GRequestRestorePurchaseMutationVars',
    )..add('input', input)).toString();
  }
}

class GRequestRestorePurchaseMutationVarsBuilder
    implements
        Builder<
          GRequestRestorePurchaseMutationVars,
          GRequestRestorePurchaseMutationVarsBuilder
        > {
  _$GRequestRestorePurchaseMutationVars? _$v;

  _i2.GRequestRestorePurchaseInputBuilder? _input;
  _i2.GRequestRestorePurchaseInputBuilder get input =>
      _$this._input ??= _i2.GRequestRestorePurchaseInputBuilder();
  set input(_i2.GRequestRestorePurchaseInputBuilder? input) =>
      _$this._input = input;

  GRequestRestorePurchaseMutationVarsBuilder();

  GRequestRestorePurchaseMutationVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _input = $v.input.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRequestRestorePurchaseMutationVars other) {
    _$v = other as _$GRequestRestorePurchaseMutationVars;
  }

  @override
  void update(
    void Function(GRequestRestorePurchaseMutationVarsBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GRequestRestorePurchaseMutationVars build() => _build();

  _$GRequestRestorePurchaseMutationVars _build() {
    _$GRequestRestorePurchaseMutationVars _$result;
    try {
      _$result =
          _$v ?? _$GRequestRestorePurchaseMutationVars._(input: input.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'input';
        input.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GRequestRestorePurchaseMutationVars',
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
