// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:vocastock_mobile/src/infrastructure/graphql/__generated__/schema.schema.gql.dart'
    as _i2;
import 'package:vocastock_mobile/src/infrastructure/graphql/__generated__/serializers.gql.dart'
    as _i1;

part 'subscription.var.gql.g.dart';

abstract class GSubscriptionStatusQueryVars
    implements
        Built<GSubscriptionStatusQueryVars,
            GSubscriptionStatusQueryVarsBuilder> {
  GSubscriptionStatusQueryVars._();

  factory GSubscriptionStatusQueryVars(
          [void Function(GSubscriptionStatusQueryVarsBuilder b) updates]) =
      _$GSubscriptionStatusQueryVars;

  static Serializer<GSubscriptionStatusQueryVars> get serializer =>
      _$gSubscriptionStatusQueryVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GSubscriptionStatusQueryVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSubscriptionStatusQueryVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GSubscriptionStatusQueryVars.serializer,
        json,
      );
}

abstract class GRequestPurchaseMutationVars
    implements
        Built<GRequestPurchaseMutationVars,
            GRequestPurchaseMutationVarsBuilder> {
  GRequestPurchaseMutationVars._();

  factory GRequestPurchaseMutationVars(
          [void Function(GRequestPurchaseMutationVarsBuilder b) updates]) =
      _$GRequestPurchaseMutationVars;

  _i2.GRequestPurchaseInput get input;
  static Serializer<GRequestPurchaseMutationVars> get serializer =>
      _$gRequestPurchaseMutationVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GRequestPurchaseMutationVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRequestPurchaseMutationVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GRequestPurchaseMutationVars.serializer,
        json,
      );
}

abstract class GRequestRestorePurchaseMutationVars
    implements
        Built<GRequestRestorePurchaseMutationVars,
            GRequestRestorePurchaseMutationVarsBuilder> {
  GRequestRestorePurchaseMutationVars._();

  factory GRequestRestorePurchaseMutationVars(
      [void Function(GRequestRestorePurchaseMutationVarsBuilder b)
          updates]) = _$GRequestRestorePurchaseMutationVars;

  _i2.GRequestRestorePurchaseInput get input;
  static Serializer<GRequestRestorePurchaseMutationVars> get serializer =>
      _$gRequestRestorePurchaseMutationVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GRequestRestorePurchaseMutationVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRequestRestorePurchaseMutationVars? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GRequestRestorePurchaseMutationVars.serializer,
        json,
      );
}
