// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GSubscriptionStatusQueryData>
_$gSubscriptionStatusQueryDataSerializer =
    _$GSubscriptionStatusQueryDataSerializer();
Serializer<GSubscriptionStatusQueryData_subscriptionStatus>
_$gSubscriptionStatusQueryDataSubscriptionStatusSerializer =
    _$GSubscriptionStatusQueryData_subscriptionStatusSerializer();
Serializer<GSubscriptionStatusQueryData_subscriptionStatus_allowance>
_$gSubscriptionStatusQueryDataSubscriptionStatusAllowanceSerializer =
    _$GSubscriptionStatusQueryData_subscriptionStatus_allowanceSerializer();
Serializer<GRequestPurchaseMutationData>
_$gRequestPurchaseMutationDataSerializer =
    _$GRequestPurchaseMutationDataSerializer();
Serializer<GRequestPurchaseMutationData_requestPurchase>
_$gRequestPurchaseMutationDataRequestPurchaseSerializer =
    _$GRequestPurchaseMutationData_requestPurchaseSerializer();
Serializer<GRequestPurchaseMutationData_requestPurchase_message>
_$gRequestPurchaseMutationDataRequestPurchaseMessageSerializer =
    _$GRequestPurchaseMutationData_requestPurchase_messageSerializer();
Serializer<GRequestRestorePurchaseMutationData>
_$gRequestRestorePurchaseMutationDataSerializer =
    _$GRequestRestorePurchaseMutationDataSerializer();
Serializer<GRequestRestorePurchaseMutationData_requestRestorePurchase>
_$gRequestRestorePurchaseMutationDataRequestRestorePurchaseSerializer =
    _$GRequestRestorePurchaseMutationData_requestRestorePurchaseSerializer();
Serializer<GRequestRestorePurchaseMutationData_requestRestorePurchase_message>
_$gRequestRestorePurchaseMutationDataRequestRestorePurchaseMessageSerializer =
    _$GRequestRestorePurchaseMutationData_requestRestorePurchase_messageSerializer();

class _$GSubscriptionStatusQueryDataSerializer
    implements StructuredSerializer<GSubscriptionStatusQueryData> {
  @override
  final Iterable<Type> types = const [
    GSubscriptionStatusQueryData,
    _$GSubscriptionStatusQueryData,
  ];
  @override
  final String wireName = 'GSubscriptionStatusQueryData';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GSubscriptionStatusQueryData object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
      'subscriptionStatus',
      serializers.serialize(
        object.subscriptionStatus,
        specifiedType: const FullType(
          GSubscriptionStatusQueryData_subscriptionStatus,
        ),
      ),
    ];

    return result;
  }

  @override
  GSubscriptionStatusQueryData deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GSubscriptionStatusQueryDataBuilder();

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
        case 'subscriptionStatus':
          result.subscriptionStatus.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(
                    GSubscriptionStatusQueryData_subscriptionStatus,
                  ),
                )!
                as GSubscriptionStatusQueryData_subscriptionStatus,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$GSubscriptionStatusQueryData_subscriptionStatusSerializer
    implements
        StructuredSerializer<GSubscriptionStatusQueryData_subscriptionStatus> {
  @override
  final Iterable<Type> types = const [
    GSubscriptionStatusQueryData_subscriptionStatus,
    _$GSubscriptionStatusQueryData_subscriptionStatus,
  ];
  @override
  final String wireName = 'GSubscriptionStatusQueryData_subscriptionStatus';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GSubscriptionStatusQueryData_subscriptionStatus object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
      'state',
      serializers.serialize(
        object.state,
        specifiedType: const FullType(_i2.GSubscriptionState),
      ),
      'plan',
      serializers.serialize(
        object.plan,
        specifiedType: const FullType(_i2.GPlanCode),
      ),
      'entitlement',
      serializers.serialize(
        object.entitlement,
        specifiedType: const FullType(_i2.GEntitlementBundle),
      ),
      'allowance',
      serializers.serialize(
        object.allowance,
        specifiedType: const FullType(
          GSubscriptionStatusQueryData_subscriptionStatus_allowance,
        ),
      ),
    ];

    return result;
  }

  @override
  GSubscriptionStatusQueryData_subscriptionStatus deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GSubscriptionStatusQueryData_subscriptionStatusBuilder();

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
        case 'state':
          result.state =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(_i2.GSubscriptionState),
                  )!
                  as _i2.GSubscriptionState;
          break;
        case 'plan':
          result.plan =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(_i2.GPlanCode),
                  )!
                  as _i2.GPlanCode;
          break;
        case 'entitlement':
          result.entitlement =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(_i2.GEntitlementBundle),
                  )!
                  as _i2.GEntitlementBundle;
          break;
        case 'allowance':
          result.allowance.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(
                    GSubscriptionStatusQueryData_subscriptionStatus_allowance,
                  ),
                )!
                as GSubscriptionStatusQueryData_subscriptionStatus_allowance,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$GSubscriptionStatusQueryData_subscriptionStatus_allowanceSerializer
    implements
        StructuredSerializer<
          GSubscriptionStatusQueryData_subscriptionStatus_allowance
        > {
  @override
  final Iterable<Type> types = const [
    GSubscriptionStatusQueryData_subscriptionStatus_allowance,
    _$GSubscriptionStatusQueryData_subscriptionStatus_allowance,
  ];
  @override
  final String wireName =
      'GSubscriptionStatusQueryData_subscriptionStatus_allowance';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GSubscriptionStatusQueryData_subscriptionStatus_allowance object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
      'remainingExplanationGenerations',
      serializers.serialize(
        object.remainingExplanationGenerations,
        specifiedType: const FullType(int),
      ),
      'remainingImageGenerations',
      serializers.serialize(
        object.remainingImageGenerations,
        specifiedType: const FullType(int),
      ),
    ];

    return result;
  }

  @override
  GSubscriptionStatusQueryData_subscriptionStatus_allowance deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GSubscriptionStatusQueryData_subscriptionStatus_allowanceBuilder();

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
        case 'remainingExplanationGenerations':
          result.remainingExplanationGenerations =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(int),
                  )!
                  as int;
          break;
        case 'remainingImageGenerations':
          result.remainingImageGenerations =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(int),
                  )!
                  as int;
          break;
      }
    }

    return result.build();
  }
}

class _$GRequestPurchaseMutationDataSerializer
    implements StructuredSerializer<GRequestPurchaseMutationData> {
  @override
  final Iterable<Type> types = const [
    GRequestPurchaseMutationData,
    _$GRequestPurchaseMutationData,
  ];
  @override
  final String wireName = 'GRequestPurchaseMutationData';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GRequestPurchaseMutationData object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
      'requestPurchase',
      serializers.serialize(
        object.requestPurchase,
        specifiedType: const FullType(
          GRequestPurchaseMutationData_requestPurchase,
        ),
      ),
    ];

    return result;
  }

  @override
  GRequestPurchaseMutationData deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GRequestPurchaseMutationDataBuilder();

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
        case 'requestPurchase':
          result.requestPurchase.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(
                    GRequestPurchaseMutationData_requestPurchase,
                  ),
                )!
                as GRequestPurchaseMutationData_requestPurchase,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$GRequestPurchaseMutationData_requestPurchaseSerializer
    implements
        StructuredSerializer<GRequestPurchaseMutationData_requestPurchase> {
  @override
  final Iterable<Type> types = const [
    GRequestPurchaseMutationData_requestPurchase,
    _$GRequestPurchaseMutationData_requestPurchase,
  ];
  @override
  final String wireName = 'GRequestPurchaseMutationData_requestPurchase';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GRequestPurchaseMutationData_requestPurchase object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
      'accepted',
      serializers.serialize(
        object.accepted,
        specifiedType: const FullType(bool),
      ),
      'message',
      serializers.serialize(
        object.message,
        specifiedType: const FullType(
          GRequestPurchaseMutationData_requestPurchase_message,
        ),
      ),
    ];
    Object? value;
    value = object.outcome;
    if (value != null) {
      result
        ..add('outcome')
        ..add(
          serializers.serialize(
            value,
            specifiedType: const FullType(_i2.GAcceptanceOutcome),
          ),
        );
    }
    value = object.errorCategory;
    if (value != null) {
      result
        ..add('errorCategory')
        ..add(
          serializers.serialize(
            value,
            specifiedType: const FullType(_i2.GCommandErrorCategory),
          ),
        );
    }
    return result;
  }

  @override
  GRequestPurchaseMutationData_requestPurchase deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GRequestPurchaseMutationData_requestPurchaseBuilder();

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
        case 'accepted':
          result.accepted =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )!
                  as bool;
          break;
        case 'outcome':
          result.outcome =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(_i2.GAcceptanceOutcome),
                  )
                  as _i2.GAcceptanceOutcome?;
          break;
        case 'errorCategory':
          result.errorCategory =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(_i2.GCommandErrorCategory),
                  )
                  as _i2.GCommandErrorCategory?;
          break;
        case 'message':
          result.message.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(
                    GRequestPurchaseMutationData_requestPurchase_message,
                  ),
                )!
                as GRequestPurchaseMutationData_requestPurchase_message,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$GRequestPurchaseMutationData_requestPurchase_messageSerializer
    implements
        StructuredSerializer<
          GRequestPurchaseMutationData_requestPurchase_message
        > {
  @override
  final Iterable<Type> types = const [
    GRequestPurchaseMutationData_requestPurchase_message,
    _$GRequestPurchaseMutationData_requestPurchase_message,
  ];
  @override
  final String wireName =
      'GRequestPurchaseMutationData_requestPurchase_message';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GRequestPurchaseMutationData_requestPurchase_message object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
      'key',
      serializers.serialize(object.key, specifiedType: const FullType(String)),
      'text',
      serializers.serialize(object.text, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GRequestPurchaseMutationData_requestPurchase_message deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GRequestPurchaseMutationData_requestPurchase_messageBuilder();

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
        case 'key':
          result.key =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'text':
          result.text =
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

class _$GRequestRestorePurchaseMutationDataSerializer
    implements StructuredSerializer<GRequestRestorePurchaseMutationData> {
  @override
  final Iterable<Type> types = const [
    GRequestRestorePurchaseMutationData,
    _$GRequestRestorePurchaseMutationData,
  ];
  @override
  final String wireName = 'GRequestRestorePurchaseMutationData';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GRequestRestorePurchaseMutationData object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
      'requestRestorePurchase',
      serializers.serialize(
        object.requestRestorePurchase,
        specifiedType: const FullType(
          GRequestRestorePurchaseMutationData_requestRestorePurchase,
        ),
      ),
    ];

    return result;
  }

  @override
  GRequestRestorePurchaseMutationData deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GRequestRestorePurchaseMutationDataBuilder();

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
        case 'requestRestorePurchase':
          result.requestRestorePurchase.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(
                    GRequestRestorePurchaseMutationData_requestRestorePurchase,
                  ),
                )!
                as GRequestRestorePurchaseMutationData_requestRestorePurchase,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$GRequestRestorePurchaseMutationData_requestRestorePurchaseSerializer
    implements
        StructuredSerializer<
          GRequestRestorePurchaseMutationData_requestRestorePurchase
        > {
  @override
  final Iterable<Type> types = const [
    GRequestRestorePurchaseMutationData_requestRestorePurchase,
    _$GRequestRestorePurchaseMutationData_requestRestorePurchase,
  ];
  @override
  final String wireName =
      'GRequestRestorePurchaseMutationData_requestRestorePurchase';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GRequestRestorePurchaseMutationData_requestRestorePurchase object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
      'accepted',
      serializers.serialize(
        object.accepted,
        specifiedType: const FullType(bool),
      ),
      'message',
      serializers.serialize(
        object.message,
        specifiedType: const FullType(
          GRequestRestorePurchaseMutationData_requestRestorePurchase_message,
        ),
      ),
    ];
    Object? value;
    value = object.outcome;
    if (value != null) {
      result
        ..add('outcome')
        ..add(
          serializers.serialize(
            value,
            specifiedType: const FullType(_i2.GAcceptanceOutcome),
          ),
        );
    }
    value = object.errorCategory;
    if (value != null) {
      result
        ..add('errorCategory')
        ..add(
          serializers.serialize(
            value,
            specifiedType: const FullType(_i2.GCommandErrorCategory),
          ),
        );
    }
    return result;
  }

  @override
  GRequestRestorePurchaseMutationData_requestRestorePurchase deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GRequestRestorePurchaseMutationData_requestRestorePurchaseBuilder();

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
        case 'accepted':
          result.accepted =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )!
                  as bool;
          break;
        case 'outcome':
          result.outcome =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(_i2.GAcceptanceOutcome),
                  )
                  as _i2.GAcceptanceOutcome?;
          break;
        case 'errorCategory':
          result.errorCategory =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(_i2.GCommandErrorCategory),
                  )
                  as _i2.GCommandErrorCategory?;
          break;
        case 'message':
          result.message.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(
                    GRequestRestorePurchaseMutationData_requestRestorePurchase_message,
                  ),
                )!
                as GRequestRestorePurchaseMutationData_requestRestorePurchase_message,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$GRequestRestorePurchaseMutationData_requestRestorePurchase_messageSerializer
    implements
        StructuredSerializer<
          GRequestRestorePurchaseMutationData_requestRestorePurchase_message
        > {
  @override
  final Iterable<Type> types = const [
    GRequestRestorePurchaseMutationData_requestRestorePurchase_message,
    _$GRequestRestorePurchaseMutationData_requestRestorePurchase_message,
  ];
  @override
  final String wireName =
      'GRequestRestorePurchaseMutationData_requestRestorePurchase_message';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GRequestRestorePurchaseMutationData_requestRestorePurchase_message object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
      'key',
      serializers.serialize(object.key, specifiedType: const FullType(String)),
      'text',
      serializers.serialize(object.text, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GRequestRestorePurchaseMutationData_requestRestorePurchase_message
  deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GRequestRestorePurchaseMutationData_requestRestorePurchase_messageBuilder();

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
        case 'key':
          result.key =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'text':
          result.text =
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

class _$GSubscriptionStatusQueryData extends GSubscriptionStatusQueryData {
  @override
  final String G__typename;
  @override
  final GSubscriptionStatusQueryData_subscriptionStatus subscriptionStatus;

  factory _$GSubscriptionStatusQueryData([
    void Function(GSubscriptionStatusQueryDataBuilder)? updates,
  ]) => (GSubscriptionStatusQueryDataBuilder()..update(updates))._build();

  _$GSubscriptionStatusQueryData._({
    required this.G__typename,
    required this.subscriptionStatus,
  }) : super._();
  @override
  GSubscriptionStatusQueryData rebuild(
    void Function(GSubscriptionStatusQueryDataBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GSubscriptionStatusQueryDataBuilder toBuilder() =>
      GSubscriptionStatusQueryDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GSubscriptionStatusQueryData &&
        G__typename == other.G__typename &&
        subscriptionStatus == other.subscriptionStatus;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, subscriptionStatus.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GSubscriptionStatusQueryData')
          ..add('G__typename', G__typename)
          ..add('subscriptionStatus', subscriptionStatus))
        .toString();
  }
}

class GSubscriptionStatusQueryDataBuilder
    implements
        Builder<
          GSubscriptionStatusQueryData,
          GSubscriptionStatusQueryDataBuilder
        > {
  _$GSubscriptionStatusQueryData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GSubscriptionStatusQueryData_subscriptionStatusBuilder? _subscriptionStatus;
  GSubscriptionStatusQueryData_subscriptionStatusBuilder
  get subscriptionStatus => _$this._subscriptionStatus ??=
      GSubscriptionStatusQueryData_subscriptionStatusBuilder();
  set subscriptionStatus(
    GSubscriptionStatusQueryData_subscriptionStatusBuilder? subscriptionStatus,
  ) => _$this._subscriptionStatus = subscriptionStatus;

  GSubscriptionStatusQueryDataBuilder() {
    GSubscriptionStatusQueryData._initializeBuilder(this);
  }

  GSubscriptionStatusQueryDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _subscriptionStatus = $v.subscriptionStatus.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GSubscriptionStatusQueryData other) {
    _$v = other as _$GSubscriptionStatusQueryData;
  }

  @override
  void update(void Function(GSubscriptionStatusQueryDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GSubscriptionStatusQueryData build() => _build();

  _$GSubscriptionStatusQueryData _build() {
    _$GSubscriptionStatusQueryData _$result;
    try {
      _$result =
          _$v ??
          _$GSubscriptionStatusQueryData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GSubscriptionStatusQueryData',
              'G__typename',
            ),
            subscriptionStatus: subscriptionStatus.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'subscriptionStatus';
        subscriptionStatus.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GSubscriptionStatusQueryData',
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

class _$GSubscriptionStatusQueryData_subscriptionStatus
    extends GSubscriptionStatusQueryData_subscriptionStatus {
  @override
  final String G__typename;
  @override
  final _i2.GSubscriptionState state;
  @override
  final _i2.GPlanCode plan;
  @override
  final _i2.GEntitlementBundle entitlement;
  @override
  final GSubscriptionStatusQueryData_subscriptionStatus_allowance allowance;

  factory _$GSubscriptionStatusQueryData_subscriptionStatus([
    void Function(GSubscriptionStatusQueryData_subscriptionStatusBuilder)?
    updates,
  ]) =>
      (GSubscriptionStatusQueryData_subscriptionStatusBuilder()
            ..update(updates))
          ._build();

  _$GSubscriptionStatusQueryData_subscriptionStatus._({
    required this.G__typename,
    required this.state,
    required this.plan,
    required this.entitlement,
    required this.allowance,
  }) : super._();
  @override
  GSubscriptionStatusQueryData_subscriptionStatus rebuild(
    void Function(GSubscriptionStatusQueryData_subscriptionStatusBuilder)
    updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GSubscriptionStatusQueryData_subscriptionStatusBuilder toBuilder() =>
      GSubscriptionStatusQueryData_subscriptionStatusBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GSubscriptionStatusQueryData_subscriptionStatus &&
        G__typename == other.G__typename &&
        state == other.state &&
        plan == other.plan &&
        entitlement == other.entitlement &&
        allowance == other.allowance;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, state.hashCode);
    _$hash = $jc(_$hash, plan.hashCode);
    _$hash = $jc(_$hash, entitlement.hashCode);
    _$hash = $jc(_$hash, allowance.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GSubscriptionStatusQueryData_subscriptionStatus',
          )
          ..add('G__typename', G__typename)
          ..add('state', state)
          ..add('plan', plan)
          ..add('entitlement', entitlement)
          ..add('allowance', allowance))
        .toString();
  }
}

class GSubscriptionStatusQueryData_subscriptionStatusBuilder
    implements
        Builder<
          GSubscriptionStatusQueryData_subscriptionStatus,
          GSubscriptionStatusQueryData_subscriptionStatusBuilder
        > {
  _$GSubscriptionStatusQueryData_subscriptionStatus? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  _i2.GSubscriptionState? _state;
  _i2.GSubscriptionState? get state => _$this._state;
  set state(_i2.GSubscriptionState? state) => _$this._state = state;

  _i2.GPlanCode? _plan;
  _i2.GPlanCode? get plan => _$this._plan;
  set plan(_i2.GPlanCode? plan) => _$this._plan = plan;

  _i2.GEntitlementBundle? _entitlement;
  _i2.GEntitlementBundle? get entitlement => _$this._entitlement;
  set entitlement(_i2.GEntitlementBundle? entitlement) =>
      _$this._entitlement = entitlement;

  GSubscriptionStatusQueryData_subscriptionStatus_allowanceBuilder? _allowance;
  GSubscriptionStatusQueryData_subscriptionStatus_allowanceBuilder
  get allowance => _$this._allowance ??=
      GSubscriptionStatusQueryData_subscriptionStatus_allowanceBuilder();
  set allowance(
    GSubscriptionStatusQueryData_subscriptionStatus_allowanceBuilder? allowance,
  ) => _$this._allowance = allowance;

  GSubscriptionStatusQueryData_subscriptionStatusBuilder() {
    GSubscriptionStatusQueryData_subscriptionStatus._initializeBuilder(this);
  }

  GSubscriptionStatusQueryData_subscriptionStatusBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _state = $v.state;
      _plan = $v.plan;
      _entitlement = $v.entitlement;
      _allowance = $v.allowance.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GSubscriptionStatusQueryData_subscriptionStatus other) {
    _$v = other as _$GSubscriptionStatusQueryData_subscriptionStatus;
  }

  @override
  void update(
    void Function(GSubscriptionStatusQueryData_subscriptionStatusBuilder)?
    updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GSubscriptionStatusQueryData_subscriptionStatus build() => _build();

  _$GSubscriptionStatusQueryData_subscriptionStatus _build() {
    _$GSubscriptionStatusQueryData_subscriptionStatus _$result;
    try {
      _$result =
          _$v ??
          _$GSubscriptionStatusQueryData_subscriptionStatus._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GSubscriptionStatusQueryData_subscriptionStatus',
              'G__typename',
            ),
            state: BuiltValueNullFieldError.checkNotNull(
              state,
              r'GSubscriptionStatusQueryData_subscriptionStatus',
              'state',
            ),
            plan: BuiltValueNullFieldError.checkNotNull(
              plan,
              r'GSubscriptionStatusQueryData_subscriptionStatus',
              'plan',
            ),
            entitlement: BuiltValueNullFieldError.checkNotNull(
              entitlement,
              r'GSubscriptionStatusQueryData_subscriptionStatus',
              'entitlement',
            ),
            allowance: allowance.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'allowance';
        allowance.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GSubscriptionStatusQueryData_subscriptionStatus',
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

class _$GSubscriptionStatusQueryData_subscriptionStatus_allowance
    extends GSubscriptionStatusQueryData_subscriptionStatus_allowance {
  @override
  final String G__typename;
  @override
  final int remainingExplanationGenerations;
  @override
  final int remainingImageGenerations;

  factory _$GSubscriptionStatusQueryData_subscriptionStatus_allowance([
    void Function(
      GSubscriptionStatusQueryData_subscriptionStatus_allowanceBuilder,
    )?
    updates,
  ]) =>
      (GSubscriptionStatusQueryData_subscriptionStatus_allowanceBuilder()
            ..update(updates))
          ._build();

  _$GSubscriptionStatusQueryData_subscriptionStatus_allowance._({
    required this.G__typename,
    required this.remainingExplanationGenerations,
    required this.remainingImageGenerations,
  }) : super._();
  @override
  GSubscriptionStatusQueryData_subscriptionStatus_allowance rebuild(
    void Function(
      GSubscriptionStatusQueryData_subscriptionStatus_allowanceBuilder,
    )
    updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GSubscriptionStatusQueryData_subscriptionStatus_allowanceBuilder
  toBuilder() =>
      GSubscriptionStatusQueryData_subscriptionStatus_allowanceBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GSubscriptionStatusQueryData_subscriptionStatus_allowance &&
        G__typename == other.G__typename &&
        remainingExplanationGenerations ==
            other.remainingExplanationGenerations &&
        remainingImageGenerations == other.remainingImageGenerations;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, remainingExplanationGenerations.hashCode);
    _$hash = $jc(_$hash, remainingImageGenerations.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GSubscriptionStatusQueryData_subscriptionStatus_allowance',
          )
          ..add('G__typename', G__typename)
          ..add(
            'remainingExplanationGenerations',
            remainingExplanationGenerations,
          )
          ..add('remainingImageGenerations', remainingImageGenerations))
        .toString();
  }
}

class GSubscriptionStatusQueryData_subscriptionStatus_allowanceBuilder
    implements
        Builder<
          GSubscriptionStatusQueryData_subscriptionStatus_allowance,
          GSubscriptionStatusQueryData_subscriptionStatus_allowanceBuilder
        > {
  _$GSubscriptionStatusQueryData_subscriptionStatus_allowance? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  int? _remainingExplanationGenerations;
  int? get remainingExplanationGenerations =>
      _$this._remainingExplanationGenerations;
  set remainingExplanationGenerations(int? remainingExplanationGenerations) =>
      _$this._remainingExplanationGenerations = remainingExplanationGenerations;

  int? _remainingImageGenerations;
  int? get remainingImageGenerations => _$this._remainingImageGenerations;
  set remainingImageGenerations(int? remainingImageGenerations) =>
      _$this._remainingImageGenerations = remainingImageGenerations;

  GSubscriptionStatusQueryData_subscriptionStatus_allowanceBuilder() {
    GSubscriptionStatusQueryData_subscriptionStatus_allowance._initializeBuilder(
      this,
    );
  }

  GSubscriptionStatusQueryData_subscriptionStatus_allowanceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _remainingExplanationGenerations = $v.remainingExplanationGenerations;
      _remainingImageGenerations = $v.remainingImageGenerations;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
    GSubscriptionStatusQueryData_subscriptionStatus_allowance other,
  ) {
    _$v = other as _$GSubscriptionStatusQueryData_subscriptionStatus_allowance;
  }

  @override
  void update(
    void Function(
      GSubscriptionStatusQueryData_subscriptionStatus_allowanceBuilder,
    )?
    updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GSubscriptionStatusQueryData_subscriptionStatus_allowance build() => _build();

  _$GSubscriptionStatusQueryData_subscriptionStatus_allowance _build() {
    final _$result =
        _$v ??
        _$GSubscriptionStatusQueryData_subscriptionStatus_allowance._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
            G__typename,
            r'GSubscriptionStatusQueryData_subscriptionStatus_allowance',
            'G__typename',
          ),
          remainingExplanationGenerations:
              BuiltValueNullFieldError.checkNotNull(
                remainingExplanationGenerations,
                r'GSubscriptionStatusQueryData_subscriptionStatus_allowance',
                'remainingExplanationGenerations',
              ),
          remainingImageGenerations: BuiltValueNullFieldError.checkNotNull(
            remainingImageGenerations,
            r'GSubscriptionStatusQueryData_subscriptionStatus_allowance',
            'remainingImageGenerations',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GRequestPurchaseMutationData extends GRequestPurchaseMutationData {
  @override
  final String G__typename;
  @override
  final GRequestPurchaseMutationData_requestPurchase requestPurchase;

  factory _$GRequestPurchaseMutationData([
    void Function(GRequestPurchaseMutationDataBuilder)? updates,
  ]) => (GRequestPurchaseMutationDataBuilder()..update(updates))._build();

  _$GRequestPurchaseMutationData._({
    required this.G__typename,
    required this.requestPurchase,
  }) : super._();
  @override
  GRequestPurchaseMutationData rebuild(
    void Function(GRequestPurchaseMutationDataBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GRequestPurchaseMutationDataBuilder toBuilder() =>
      GRequestPurchaseMutationDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRequestPurchaseMutationData &&
        G__typename == other.G__typename &&
        requestPurchase == other.requestPurchase;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, requestPurchase.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GRequestPurchaseMutationData')
          ..add('G__typename', G__typename)
          ..add('requestPurchase', requestPurchase))
        .toString();
  }
}

class GRequestPurchaseMutationDataBuilder
    implements
        Builder<
          GRequestPurchaseMutationData,
          GRequestPurchaseMutationDataBuilder
        > {
  _$GRequestPurchaseMutationData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GRequestPurchaseMutationData_requestPurchaseBuilder? _requestPurchase;
  GRequestPurchaseMutationData_requestPurchaseBuilder get requestPurchase =>
      _$this._requestPurchase ??=
          GRequestPurchaseMutationData_requestPurchaseBuilder();
  set requestPurchase(
    GRequestPurchaseMutationData_requestPurchaseBuilder? requestPurchase,
  ) => _$this._requestPurchase = requestPurchase;

  GRequestPurchaseMutationDataBuilder() {
    GRequestPurchaseMutationData._initializeBuilder(this);
  }

  GRequestPurchaseMutationDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _requestPurchase = $v.requestPurchase.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRequestPurchaseMutationData other) {
    _$v = other as _$GRequestPurchaseMutationData;
  }

  @override
  void update(void Function(GRequestPurchaseMutationDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GRequestPurchaseMutationData build() => _build();

  _$GRequestPurchaseMutationData _build() {
    _$GRequestPurchaseMutationData _$result;
    try {
      _$result =
          _$v ??
          _$GRequestPurchaseMutationData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GRequestPurchaseMutationData',
              'G__typename',
            ),
            requestPurchase: requestPurchase.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'requestPurchase';
        requestPurchase.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GRequestPurchaseMutationData',
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

class _$GRequestPurchaseMutationData_requestPurchase
    extends GRequestPurchaseMutationData_requestPurchase {
  @override
  final String G__typename;
  @override
  final bool accepted;
  @override
  final _i2.GAcceptanceOutcome? outcome;
  @override
  final _i2.GCommandErrorCategory? errorCategory;
  @override
  final GRequestPurchaseMutationData_requestPurchase_message message;

  factory _$GRequestPurchaseMutationData_requestPurchase([
    void Function(GRequestPurchaseMutationData_requestPurchaseBuilder)? updates,
  ]) => (GRequestPurchaseMutationData_requestPurchaseBuilder()..update(updates))
      ._build();

  _$GRequestPurchaseMutationData_requestPurchase._({
    required this.G__typename,
    required this.accepted,
    this.outcome,
    this.errorCategory,
    required this.message,
  }) : super._();
  @override
  GRequestPurchaseMutationData_requestPurchase rebuild(
    void Function(GRequestPurchaseMutationData_requestPurchaseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GRequestPurchaseMutationData_requestPurchaseBuilder toBuilder() =>
      GRequestPurchaseMutationData_requestPurchaseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRequestPurchaseMutationData_requestPurchase &&
        G__typename == other.G__typename &&
        accepted == other.accepted &&
        outcome == other.outcome &&
        errorCategory == other.errorCategory &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, accepted.hashCode);
    _$hash = $jc(_$hash, outcome.hashCode);
    _$hash = $jc(_$hash, errorCategory.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GRequestPurchaseMutationData_requestPurchase',
          )
          ..add('G__typename', G__typename)
          ..add('accepted', accepted)
          ..add('outcome', outcome)
          ..add('errorCategory', errorCategory)
          ..add('message', message))
        .toString();
  }
}

class GRequestPurchaseMutationData_requestPurchaseBuilder
    implements
        Builder<
          GRequestPurchaseMutationData_requestPurchase,
          GRequestPurchaseMutationData_requestPurchaseBuilder
        > {
  _$GRequestPurchaseMutationData_requestPurchase? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  bool? _accepted;
  bool? get accepted => _$this._accepted;
  set accepted(bool? accepted) => _$this._accepted = accepted;

  _i2.GAcceptanceOutcome? _outcome;
  _i2.GAcceptanceOutcome? get outcome => _$this._outcome;
  set outcome(_i2.GAcceptanceOutcome? outcome) => _$this._outcome = outcome;

  _i2.GCommandErrorCategory? _errorCategory;
  _i2.GCommandErrorCategory? get errorCategory => _$this._errorCategory;
  set errorCategory(_i2.GCommandErrorCategory? errorCategory) =>
      _$this._errorCategory = errorCategory;

  GRequestPurchaseMutationData_requestPurchase_messageBuilder? _message;
  GRequestPurchaseMutationData_requestPurchase_messageBuilder get message =>
      _$this._message ??=
          GRequestPurchaseMutationData_requestPurchase_messageBuilder();
  set message(
    GRequestPurchaseMutationData_requestPurchase_messageBuilder? message,
  ) => _$this._message = message;

  GRequestPurchaseMutationData_requestPurchaseBuilder() {
    GRequestPurchaseMutationData_requestPurchase._initializeBuilder(this);
  }

  GRequestPurchaseMutationData_requestPurchaseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _accepted = $v.accepted;
      _outcome = $v.outcome;
      _errorCategory = $v.errorCategory;
      _message = $v.message.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRequestPurchaseMutationData_requestPurchase other) {
    _$v = other as _$GRequestPurchaseMutationData_requestPurchase;
  }

  @override
  void update(
    void Function(GRequestPurchaseMutationData_requestPurchaseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GRequestPurchaseMutationData_requestPurchase build() => _build();

  _$GRequestPurchaseMutationData_requestPurchase _build() {
    _$GRequestPurchaseMutationData_requestPurchase _$result;
    try {
      _$result =
          _$v ??
          _$GRequestPurchaseMutationData_requestPurchase._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GRequestPurchaseMutationData_requestPurchase',
              'G__typename',
            ),
            accepted: BuiltValueNullFieldError.checkNotNull(
              accepted,
              r'GRequestPurchaseMutationData_requestPurchase',
              'accepted',
            ),
            outcome: outcome,
            errorCategory: errorCategory,
            message: message.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'message';
        message.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GRequestPurchaseMutationData_requestPurchase',
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

class _$GRequestPurchaseMutationData_requestPurchase_message
    extends GRequestPurchaseMutationData_requestPurchase_message {
  @override
  final String G__typename;
  @override
  final String key;
  @override
  final String text;

  factory _$GRequestPurchaseMutationData_requestPurchase_message([
    void Function(GRequestPurchaseMutationData_requestPurchase_messageBuilder)?
    updates,
  ]) =>
      (GRequestPurchaseMutationData_requestPurchase_messageBuilder()
            ..update(updates))
          ._build();

  _$GRequestPurchaseMutationData_requestPurchase_message._({
    required this.G__typename,
    required this.key,
    required this.text,
  }) : super._();
  @override
  GRequestPurchaseMutationData_requestPurchase_message rebuild(
    void Function(GRequestPurchaseMutationData_requestPurchase_messageBuilder)
    updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GRequestPurchaseMutationData_requestPurchase_messageBuilder toBuilder() =>
      GRequestPurchaseMutationData_requestPurchase_messageBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRequestPurchaseMutationData_requestPurchase_message &&
        G__typename == other.G__typename &&
        key == other.key &&
        text == other.text;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, text.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GRequestPurchaseMutationData_requestPurchase_message',
          )
          ..add('G__typename', G__typename)
          ..add('key', key)
          ..add('text', text))
        .toString();
  }
}

class GRequestPurchaseMutationData_requestPurchase_messageBuilder
    implements
        Builder<
          GRequestPurchaseMutationData_requestPurchase_message,
          GRequestPurchaseMutationData_requestPurchase_messageBuilder
        > {
  _$GRequestPurchaseMutationData_requestPurchase_message? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  String? _text;
  String? get text => _$this._text;
  set text(String? text) => _$this._text = text;

  GRequestPurchaseMutationData_requestPurchase_messageBuilder() {
    GRequestPurchaseMutationData_requestPurchase_message._initializeBuilder(
      this,
    );
  }

  GRequestPurchaseMutationData_requestPurchase_messageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _key = $v.key;
      _text = $v.text;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRequestPurchaseMutationData_requestPurchase_message other) {
    _$v = other as _$GRequestPurchaseMutationData_requestPurchase_message;
  }

  @override
  void update(
    void Function(GRequestPurchaseMutationData_requestPurchase_messageBuilder)?
    updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GRequestPurchaseMutationData_requestPurchase_message build() => _build();

  _$GRequestPurchaseMutationData_requestPurchase_message _build() {
    final _$result =
        _$v ??
        _$GRequestPurchaseMutationData_requestPurchase_message._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
            G__typename,
            r'GRequestPurchaseMutationData_requestPurchase_message',
            'G__typename',
          ),
          key: BuiltValueNullFieldError.checkNotNull(
            key,
            r'GRequestPurchaseMutationData_requestPurchase_message',
            'key',
          ),
          text: BuiltValueNullFieldError.checkNotNull(
            text,
            r'GRequestPurchaseMutationData_requestPurchase_message',
            'text',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GRequestRestorePurchaseMutationData
    extends GRequestRestorePurchaseMutationData {
  @override
  final String G__typename;
  @override
  final GRequestRestorePurchaseMutationData_requestRestorePurchase
  requestRestorePurchase;

  factory _$GRequestRestorePurchaseMutationData([
    void Function(GRequestRestorePurchaseMutationDataBuilder)? updates,
  ]) =>
      (GRequestRestorePurchaseMutationDataBuilder()..update(updates))._build();

  _$GRequestRestorePurchaseMutationData._({
    required this.G__typename,
    required this.requestRestorePurchase,
  }) : super._();
  @override
  GRequestRestorePurchaseMutationData rebuild(
    void Function(GRequestRestorePurchaseMutationDataBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GRequestRestorePurchaseMutationDataBuilder toBuilder() =>
      GRequestRestorePurchaseMutationDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRequestRestorePurchaseMutationData &&
        G__typename == other.G__typename &&
        requestRestorePurchase == other.requestRestorePurchase;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, requestRestorePurchase.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GRequestRestorePurchaseMutationData')
          ..add('G__typename', G__typename)
          ..add('requestRestorePurchase', requestRestorePurchase))
        .toString();
  }
}

class GRequestRestorePurchaseMutationDataBuilder
    implements
        Builder<
          GRequestRestorePurchaseMutationData,
          GRequestRestorePurchaseMutationDataBuilder
        > {
  _$GRequestRestorePurchaseMutationData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GRequestRestorePurchaseMutationData_requestRestorePurchaseBuilder?
  _requestRestorePurchase;
  GRequestRestorePurchaseMutationData_requestRestorePurchaseBuilder
  get requestRestorePurchase => _$this._requestRestorePurchase ??=
      GRequestRestorePurchaseMutationData_requestRestorePurchaseBuilder();
  set requestRestorePurchase(
    GRequestRestorePurchaseMutationData_requestRestorePurchaseBuilder?
    requestRestorePurchase,
  ) => _$this._requestRestorePurchase = requestRestorePurchase;

  GRequestRestorePurchaseMutationDataBuilder() {
    GRequestRestorePurchaseMutationData._initializeBuilder(this);
  }

  GRequestRestorePurchaseMutationDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _requestRestorePurchase = $v.requestRestorePurchase.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRequestRestorePurchaseMutationData other) {
    _$v = other as _$GRequestRestorePurchaseMutationData;
  }

  @override
  void update(
    void Function(GRequestRestorePurchaseMutationDataBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GRequestRestorePurchaseMutationData build() => _build();

  _$GRequestRestorePurchaseMutationData _build() {
    _$GRequestRestorePurchaseMutationData _$result;
    try {
      _$result =
          _$v ??
          _$GRequestRestorePurchaseMutationData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GRequestRestorePurchaseMutationData',
              'G__typename',
            ),
            requestRestorePurchase: requestRestorePurchase.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'requestRestorePurchase';
        requestRestorePurchase.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GRequestRestorePurchaseMutationData',
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

class _$GRequestRestorePurchaseMutationData_requestRestorePurchase
    extends GRequestRestorePurchaseMutationData_requestRestorePurchase {
  @override
  final String G__typename;
  @override
  final bool accepted;
  @override
  final _i2.GAcceptanceOutcome? outcome;
  @override
  final _i2.GCommandErrorCategory? errorCategory;
  @override
  final GRequestRestorePurchaseMutationData_requestRestorePurchase_message
  message;

  factory _$GRequestRestorePurchaseMutationData_requestRestorePurchase([
    void Function(
      GRequestRestorePurchaseMutationData_requestRestorePurchaseBuilder,
    )?
    updates,
  ]) =>
      (GRequestRestorePurchaseMutationData_requestRestorePurchaseBuilder()
            ..update(updates))
          ._build();

  _$GRequestRestorePurchaseMutationData_requestRestorePurchase._({
    required this.G__typename,
    required this.accepted,
    this.outcome,
    this.errorCategory,
    required this.message,
  }) : super._();
  @override
  GRequestRestorePurchaseMutationData_requestRestorePurchase rebuild(
    void Function(
      GRequestRestorePurchaseMutationData_requestRestorePurchaseBuilder,
    )
    updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GRequestRestorePurchaseMutationData_requestRestorePurchaseBuilder
  toBuilder() =>
      GRequestRestorePurchaseMutationData_requestRestorePurchaseBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GRequestRestorePurchaseMutationData_requestRestorePurchase &&
        G__typename == other.G__typename &&
        accepted == other.accepted &&
        outcome == other.outcome &&
        errorCategory == other.errorCategory &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, accepted.hashCode);
    _$hash = $jc(_$hash, outcome.hashCode);
    _$hash = $jc(_$hash, errorCategory.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GRequestRestorePurchaseMutationData_requestRestorePurchase',
          )
          ..add('G__typename', G__typename)
          ..add('accepted', accepted)
          ..add('outcome', outcome)
          ..add('errorCategory', errorCategory)
          ..add('message', message))
        .toString();
  }
}

class GRequestRestorePurchaseMutationData_requestRestorePurchaseBuilder
    implements
        Builder<
          GRequestRestorePurchaseMutationData_requestRestorePurchase,
          GRequestRestorePurchaseMutationData_requestRestorePurchaseBuilder
        > {
  _$GRequestRestorePurchaseMutationData_requestRestorePurchase? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  bool? _accepted;
  bool? get accepted => _$this._accepted;
  set accepted(bool? accepted) => _$this._accepted = accepted;

  _i2.GAcceptanceOutcome? _outcome;
  _i2.GAcceptanceOutcome? get outcome => _$this._outcome;
  set outcome(_i2.GAcceptanceOutcome? outcome) => _$this._outcome = outcome;

  _i2.GCommandErrorCategory? _errorCategory;
  _i2.GCommandErrorCategory? get errorCategory => _$this._errorCategory;
  set errorCategory(_i2.GCommandErrorCategory? errorCategory) =>
      _$this._errorCategory = errorCategory;

  GRequestRestorePurchaseMutationData_requestRestorePurchase_messageBuilder?
  _message;
  GRequestRestorePurchaseMutationData_requestRestorePurchase_messageBuilder
  get message => _$this._message ??=
      GRequestRestorePurchaseMutationData_requestRestorePurchase_messageBuilder();
  set message(
    GRequestRestorePurchaseMutationData_requestRestorePurchase_messageBuilder?
    message,
  ) => _$this._message = message;

  GRequestRestorePurchaseMutationData_requestRestorePurchaseBuilder() {
    GRequestRestorePurchaseMutationData_requestRestorePurchase._initializeBuilder(
      this,
    );
  }

  GRequestRestorePurchaseMutationData_requestRestorePurchaseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _accepted = $v.accepted;
      _outcome = $v.outcome;
      _errorCategory = $v.errorCategory;
      _message = $v.message.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
    GRequestRestorePurchaseMutationData_requestRestorePurchase other,
  ) {
    _$v = other as _$GRequestRestorePurchaseMutationData_requestRestorePurchase;
  }

  @override
  void update(
    void Function(
      GRequestRestorePurchaseMutationData_requestRestorePurchaseBuilder,
    )?
    updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GRequestRestorePurchaseMutationData_requestRestorePurchase build() =>
      _build();

  _$GRequestRestorePurchaseMutationData_requestRestorePurchase _build() {
    _$GRequestRestorePurchaseMutationData_requestRestorePurchase _$result;
    try {
      _$result =
          _$v ??
          _$GRequestRestorePurchaseMutationData_requestRestorePurchase._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GRequestRestorePurchaseMutationData_requestRestorePurchase',
              'G__typename',
            ),
            accepted: BuiltValueNullFieldError.checkNotNull(
              accepted,
              r'GRequestRestorePurchaseMutationData_requestRestorePurchase',
              'accepted',
            ),
            outcome: outcome,
            errorCategory: errorCategory,
            message: message.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'message';
        message.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GRequestRestorePurchaseMutationData_requestRestorePurchase',
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

class _$GRequestRestorePurchaseMutationData_requestRestorePurchase_message
    extends GRequestRestorePurchaseMutationData_requestRestorePurchase_message {
  @override
  final String G__typename;
  @override
  final String key;
  @override
  final String text;

  factory _$GRequestRestorePurchaseMutationData_requestRestorePurchase_message([
    void Function(
      GRequestRestorePurchaseMutationData_requestRestorePurchase_messageBuilder,
    )?
    updates,
  ]) =>
      (GRequestRestorePurchaseMutationData_requestRestorePurchase_messageBuilder()
            ..update(updates))
          ._build();

  _$GRequestRestorePurchaseMutationData_requestRestorePurchase_message._({
    required this.G__typename,
    required this.key,
    required this.text,
  }) : super._();
  @override
  GRequestRestorePurchaseMutationData_requestRestorePurchase_message rebuild(
    void Function(
      GRequestRestorePurchaseMutationData_requestRestorePurchase_messageBuilder,
    )
    updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GRequestRestorePurchaseMutationData_requestRestorePurchase_messageBuilder
  toBuilder() =>
      GRequestRestorePurchaseMutationData_requestRestorePurchase_messageBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GRequestRestorePurchaseMutationData_requestRestorePurchase_message &&
        G__typename == other.G__typename &&
        key == other.key &&
        text == other.text;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, text.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GRequestRestorePurchaseMutationData_requestRestorePurchase_message',
          )
          ..add('G__typename', G__typename)
          ..add('key', key)
          ..add('text', text))
        .toString();
  }
}

class GRequestRestorePurchaseMutationData_requestRestorePurchase_messageBuilder
    implements
        Builder<
          GRequestRestorePurchaseMutationData_requestRestorePurchase_message,
          GRequestRestorePurchaseMutationData_requestRestorePurchase_messageBuilder
        > {
  _$GRequestRestorePurchaseMutationData_requestRestorePurchase_message? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  String? _text;
  String? get text => _$this._text;
  set text(String? text) => _$this._text = text;

  GRequestRestorePurchaseMutationData_requestRestorePurchase_messageBuilder() {
    GRequestRestorePurchaseMutationData_requestRestorePurchase_message._initializeBuilder(
      this,
    );
  }

  GRequestRestorePurchaseMutationData_requestRestorePurchase_messageBuilder
  get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _key = $v.key;
      _text = $v.text;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
    GRequestRestorePurchaseMutationData_requestRestorePurchase_message other,
  ) {
    _$v =
        other
            as _$GRequestRestorePurchaseMutationData_requestRestorePurchase_message;
  }

  @override
  void update(
    void Function(
      GRequestRestorePurchaseMutationData_requestRestorePurchase_messageBuilder,
    )?
    updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GRequestRestorePurchaseMutationData_requestRestorePurchase_message build() =>
      _build();

  _$GRequestRestorePurchaseMutationData_requestRestorePurchase_message
  _build() {
    final _$result =
        _$v ??
        _$GRequestRestorePurchaseMutationData_requestRestorePurchase_message._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
            G__typename,
            r'GRequestRestorePurchaseMutationData_requestRestorePurchase_message',
            'G__typename',
          ),
          key: BuiltValueNullFieldError.checkNotNull(
            key,
            r'GRequestRestorePurchaseMutationData_requestRestorePurchase_message',
            'key',
          ),
          text: BuiltValueNullFieldError.checkNotNull(
            text,
            r'GRequestRestorePurchaseMutationData_requestRestorePurchase_message',
            'text',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
