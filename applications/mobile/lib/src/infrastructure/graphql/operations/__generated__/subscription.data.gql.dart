// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:vocastock_mobile/src/infrastructure/graphql/__generated__/schema.schema.gql.dart'
    as _i2;
import 'package:vocastock_mobile/src/infrastructure/graphql/__generated__/serializers.gql.dart'
    as _i1;

part 'subscription.data.gql.g.dart';

abstract class GSubscriptionStatusQueryData
    implements
        Built<GSubscriptionStatusQueryData,
            GSubscriptionStatusQueryDataBuilder> {
  GSubscriptionStatusQueryData._();

  factory GSubscriptionStatusQueryData(
          [void Function(GSubscriptionStatusQueryDataBuilder b) updates]) =
      _$GSubscriptionStatusQueryData;

  static void _initializeBuilder(GSubscriptionStatusQueryDataBuilder b) =>
      b..G__typename = 'Query';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GSubscriptionStatusQueryData_subscriptionStatus get subscriptionStatus;
  static Serializer<GSubscriptionStatusQueryData> get serializer =>
      _$gSubscriptionStatusQueryDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GSubscriptionStatusQueryData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSubscriptionStatusQueryData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GSubscriptionStatusQueryData.serializer,
        json,
      );
}

abstract class GSubscriptionStatusQueryData_subscriptionStatus
    implements
        Built<GSubscriptionStatusQueryData_subscriptionStatus,
            GSubscriptionStatusQueryData_subscriptionStatusBuilder> {
  GSubscriptionStatusQueryData_subscriptionStatus._();

  factory GSubscriptionStatusQueryData_subscriptionStatus(
      [void Function(GSubscriptionStatusQueryData_subscriptionStatusBuilder b)
          updates]) = _$GSubscriptionStatusQueryData_subscriptionStatus;

  static void _initializeBuilder(
          GSubscriptionStatusQueryData_subscriptionStatusBuilder b) =>
      b..G__typename = 'SubscriptionStatusView';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  _i2.GSubscriptionState get state;
  _i2.GPlanCode get plan;
  _i2.GEntitlementBundle get entitlement;
  GSubscriptionStatusQueryData_subscriptionStatus_allowance get allowance;
  static Serializer<GSubscriptionStatusQueryData_subscriptionStatus>
      get serializer =>
          _$gSubscriptionStatusQueryDataSubscriptionStatusSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GSubscriptionStatusQueryData_subscriptionStatus.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSubscriptionStatusQueryData_subscriptionStatus? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GSubscriptionStatusQueryData_subscriptionStatus.serializer,
        json,
      );
}

abstract class GSubscriptionStatusQueryData_subscriptionStatus_allowance
    implements
        Built<GSubscriptionStatusQueryData_subscriptionStatus_allowance,
            GSubscriptionStatusQueryData_subscriptionStatus_allowanceBuilder> {
  GSubscriptionStatusQueryData_subscriptionStatus_allowance._();

  factory GSubscriptionStatusQueryData_subscriptionStatus_allowance(
      [void Function(
              GSubscriptionStatusQueryData_subscriptionStatus_allowanceBuilder
                  b)
          updates]) = _$GSubscriptionStatusQueryData_subscriptionStatus_allowance;

  static void _initializeBuilder(
          GSubscriptionStatusQueryData_subscriptionStatus_allowanceBuilder b) =>
      b..G__typename = 'UsageAllowance';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  int get remainingExplanationGenerations;
  int get remainingImageGenerations;
  static Serializer<GSubscriptionStatusQueryData_subscriptionStatus_allowance>
      get serializer =>
          _$gSubscriptionStatusQueryDataSubscriptionStatusAllowanceSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GSubscriptionStatusQueryData_subscriptionStatus_allowance.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSubscriptionStatusQueryData_subscriptionStatus_allowance? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GSubscriptionStatusQueryData_subscriptionStatus_allowance.serializer,
        json,
      );
}

abstract class GRequestPurchaseMutationData
    implements
        Built<GRequestPurchaseMutationData,
            GRequestPurchaseMutationDataBuilder> {
  GRequestPurchaseMutationData._();

  factory GRequestPurchaseMutationData(
          [void Function(GRequestPurchaseMutationDataBuilder b) updates]) =
      _$GRequestPurchaseMutationData;

  static void _initializeBuilder(GRequestPurchaseMutationDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GRequestPurchaseMutationData_requestPurchase get requestPurchase;
  static Serializer<GRequestPurchaseMutationData> get serializer =>
      _$gRequestPurchaseMutationDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GRequestPurchaseMutationData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRequestPurchaseMutationData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GRequestPurchaseMutationData.serializer,
        json,
      );
}

abstract class GRequestPurchaseMutationData_requestPurchase
    implements
        Built<GRequestPurchaseMutationData_requestPurchase,
            GRequestPurchaseMutationData_requestPurchaseBuilder> {
  GRequestPurchaseMutationData_requestPurchase._();

  factory GRequestPurchaseMutationData_requestPurchase(
      [void Function(GRequestPurchaseMutationData_requestPurchaseBuilder b)
          updates]) = _$GRequestPurchaseMutationData_requestPurchase;

  static void _initializeBuilder(
          GRequestPurchaseMutationData_requestPurchaseBuilder b) =>
      b..G__typename = 'CommandResponseEnvelope';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  bool get accepted;
  _i2.GAcceptanceOutcome? get outcome;
  _i2.GCommandErrorCategory? get errorCategory;
  GRequestPurchaseMutationData_requestPurchase_message get message;
  static Serializer<GRequestPurchaseMutationData_requestPurchase>
      get serializer => _$gRequestPurchaseMutationDataRequestPurchaseSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GRequestPurchaseMutationData_requestPurchase.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRequestPurchaseMutationData_requestPurchase? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GRequestPurchaseMutationData_requestPurchase.serializer,
        json,
      );
}

abstract class GRequestPurchaseMutationData_requestPurchase_message
    implements
        Built<GRequestPurchaseMutationData_requestPurchase_message,
            GRequestPurchaseMutationData_requestPurchase_messageBuilder> {
  GRequestPurchaseMutationData_requestPurchase_message._();

  factory GRequestPurchaseMutationData_requestPurchase_message(
      [void Function(
              GRequestPurchaseMutationData_requestPurchase_messageBuilder b)
          updates]) = _$GRequestPurchaseMutationData_requestPurchase_message;

  static void _initializeBuilder(
          GRequestPurchaseMutationData_requestPurchase_messageBuilder b) =>
      b..G__typename = 'UserFacingMessage';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get key;
  String get text;
  static Serializer<GRequestPurchaseMutationData_requestPurchase_message>
      get serializer =>
          _$gRequestPurchaseMutationDataRequestPurchaseMessageSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GRequestPurchaseMutationData_requestPurchase_message.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRequestPurchaseMutationData_requestPurchase_message? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GRequestPurchaseMutationData_requestPurchase_message.serializer,
        json,
      );
}

abstract class GRequestRestorePurchaseMutationData
    implements
        Built<GRequestRestorePurchaseMutationData,
            GRequestRestorePurchaseMutationDataBuilder> {
  GRequestRestorePurchaseMutationData._();

  factory GRequestRestorePurchaseMutationData(
      [void Function(GRequestRestorePurchaseMutationDataBuilder b)
          updates]) = _$GRequestRestorePurchaseMutationData;

  static void _initializeBuilder(
          GRequestRestorePurchaseMutationDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GRequestRestorePurchaseMutationData_requestRestorePurchase
      get requestRestorePurchase;
  static Serializer<GRequestRestorePurchaseMutationData> get serializer =>
      _$gRequestRestorePurchaseMutationDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GRequestRestorePurchaseMutationData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRequestRestorePurchaseMutationData? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GRequestRestorePurchaseMutationData.serializer,
        json,
      );
}

abstract class GRequestRestorePurchaseMutationData_requestRestorePurchase
    implements
        Built<GRequestRestorePurchaseMutationData_requestRestorePurchase,
            GRequestRestorePurchaseMutationData_requestRestorePurchaseBuilder> {
  GRequestRestorePurchaseMutationData_requestRestorePurchase._();

  factory GRequestRestorePurchaseMutationData_requestRestorePurchase(
      [void Function(
              GRequestRestorePurchaseMutationData_requestRestorePurchaseBuilder
                  b)
          updates]) = _$GRequestRestorePurchaseMutationData_requestRestorePurchase;

  static void _initializeBuilder(
          GRequestRestorePurchaseMutationData_requestRestorePurchaseBuilder
              b) =>
      b..G__typename = 'CommandResponseEnvelope';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  bool get accepted;
  _i2.GAcceptanceOutcome? get outcome;
  _i2.GCommandErrorCategory? get errorCategory;
  GRequestRestorePurchaseMutationData_requestRestorePurchase_message
      get message;
  static Serializer<GRequestRestorePurchaseMutationData_requestRestorePurchase>
      get serializer =>
          _$gRequestRestorePurchaseMutationDataRequestRestorePurchaseSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GRequestRestorePurchaseMutationData_requestRestorePurchase.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRequestRestorePurchaseMutationData_requestRestorePurchase? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GRequestRestorePurchaseMutationData_requestRestorePurchase.serializer,
        json,
      );
}

abstract class GRequestRestorePurchaseMutationData_requestRestorePurchase_message
    implements
        Built<
            GRequestRestorePurchaseMutationData_requestRestorePurchase_message,
            GRequestRestorePurchaseMutationData_requestRestorePurchase_messageBuilder> {
  GRequestRestorePurchaseMutationData_requestRestorePurchase_message._();

  factory GRequestRestorePurchaseMutationData_requestRestorePurchase_message(
          [void Function(
                  GRequestRestorePurchaseMutationData_requestRestorePurchase_messageBuilder
                      b)
              updates]) =
      _$GRequestRestorePurchaseMutationData_requestRestorePurchase_message;

  static void _initializeBuilder(
          GRequestRestorePurchaseMutationData_requestRestorePurchase_messageBuilder
              b) =>
      b..G__typename = 'UserFacingMessage';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get key;
  String get text;
  static Serializer<
          GRequestRestorePurchaseMutationData_requestRestorePurchase_message>
      get serializer =>
          _$gRequestRestorePurchaseMutationDataRequestRestorePurchaseMessageSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GRequestRestorePurchaseMutationData_requestRestorePurchase_message
            .serializer,
        this,
      ) as Map<String, dynamic>);

  static GRequestRestorePurchaseMutationData_requestRestorePurchase_message?
      fromJson(Map<String, dynamic> json) => _i1.serializers.deserializeWith(
            GRequestRestorePurchaseMutationData_requestRestorePurchase_message
                .serializer,
            json,
          );
}
