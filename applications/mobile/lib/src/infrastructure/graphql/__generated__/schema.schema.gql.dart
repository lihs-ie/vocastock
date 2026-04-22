// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:gql_code_builder_serializers/gql_code_builder_serializers.dart'
    as _i1;
import 'package:vocastock_mobile/src/infrastructure/graphql/__generated__/serializers.gql.dart'
    as _i2;

part 'schema.schema.gql.g.dart';

abstract class GDateTime implements Built<GDateTime, GDateTimeBuilder> {
  GDateTime._();

  factory GDateTime([String? value]) =>
      _$GDateTime((b) => value != null ? (b..value = value) : b);

  String get value;
  @BuiltValueSerializer(custom: true)
  static Serializer<GDateTime> get serializer =>
      _i1.DefaultScalarSerializer<GDateTime>(
          (Object serialized) => GDateTime((serialized as String?)));
}

abstract class GULID implements Built<GULID, GULIDBuilder> {
  GULID._();

  factory GULID([String? value]) =>
      _$GULID((b) => value != null ? (b..value = value) : b);

  String get value;
  @BuiltValueSerializer(custom: true)
  static Serializer<GULID> get serializer => _i1.DefaultScalarSerializer<GULID>(
      (Object serialized) => GULID((serialized as String?)));
}

class GAuthProvider extends EnumClass {
  const GAuthProvider._(String name) : super(name);

  static const GAuthProvider BASIC = _$gAuthProviderBASIC;

  static const GAuthProvider GOOGLE = _$gAuthProviderGOOGLE;

  static Serializer<GAuthProvider> get serializer => _$gAuthProviderSerializer;

  static BuiltSet<GAuthProvider> get values => _$gAuthProviderValues;

  static GAuthProvider valueOf(String name) => _$gAuthProviderValueOf(name);
}

class GRegistrationStatus extends EnumClass {
  const GRegistrationStatus._(String name) : super(name);

  static const GRegistrationStatus ACTIVE = _$gRegistrationStatusACTIVE;

  static const GRegistrationStatus ARCHIVED = _$gRegistrationStatusARCHIVED;

  static Serializer<GRegistrationStatus> get serializer =>
      _$gRegistrationStatusSerializer;

  static BuiltSet<GRegistrationStatus> get values =>
      _$gRegistrationStatusValues;

  static GRegistrationStatus valueOf(String name) =>
      _$gRegistrationStatusValueOf(name);
}

class GGenerationTargetKind extends EnumClass {
  const GGenerationTargetKind._(String name) : super(name);

  static const GGenerationTargetKind EXPLANATION =
      _$gGenerationTargetKindEXPLANATION;

  static const GGenerationTargetKind IMAGE = _$gGenerationTargetKindIMAGE;

  static Serializer<GGenerationTargetKind> get serializer =>
      _$gGenerationTargetKindSerializer;

  static BuiltSet<GGenerationTargetKind> get values =>
      _$gGenerationTargetKindValues;

  static GGenerationTargetKind valueOf(String name) =>
      _$gGenerationTargetKindValueOf(name);
}

class GExplanationGenerationStatus extends EnumClass {
  const GExplanationGenerationStatus._(String name) : super(name);

  static const GExplanationGenerationStatus PENDING =
      _$gExplanationGenerationStatusPENDING;

  static const GExplanationGenerationStatus RUNNING =
      _$gExplanationGenerationStatusRUNNING;

  static const GExplanationGenerationStatus RETRY_SCHEDULED =
      _$gExplanationGenerationStatusRETRY_SCHEDULED;

  static const GExplanationGenerationStatus TIMED_OUT =
      _$gExplanationGenerationStatusTIMED_OUT;

  static const GExplanationGenerationStatus SUCCEEDED =
      _$gExplanationGenerationStatusSUCCEEDED;

  static const GExplanationGenerationStatus FAILED_FINAL =
      _$gExplanationGenerationStatusFAILED_FINAL;

  static const GExplanationGenerationStatus DEAD_LETTERED =
      _$gExplanationGenerationStatusDEAD_LETTERED;

  static Serializer<GExplanationGenerationStatus> get serializer =>
      _$gExplanationGenerationStatusSerializer;

  static BuiltSet<GExplanationGenerationStatus> get values =>
      _$gExplanationGenerationStatusValues;

  static GExplanationGenerationStatus valueOf(String name) =>
      _$gExplanationGenerationStatusValueOf(name);
}

class GImageGenerationStatus extends EnumClass {
  const GImageGenerationStatus._(String name) : super(name);

  static const GImageGenerationStatus PENDING = _$gImageGenerationStatusPENDING;

  static const GImageGenerationStatus RUNNING = _$gImageGenerationStatusRUNNING;

  static const GImageGenerationStatus RETRY_SCHEDULED =
      _$gImageGenerationStatusRETRY_SCHEDULED;

  static const GImageGenerationStatus TIMED_OUT =
      _$gImageGenerationStatusTIMED_OUT;

  static const GImageGenerationStatus SUCCEEDED =
      _$gImageGenerationStatusSUCCEEDED;

  static const GImageGenerationStatus FAILED_FINAL =
      _$gImageGenerationStatusFAILED_FINAL;

  static const GImageGenerationStatus DEAD_LETTERED =
      _$gImageGenerationStatusDEAD_LETTERED;

  static Serializer<GImageGenerationStatus> get serializer =>
      _$gImageGenerationStatusSerializer;

  static BuiltSet<GImageGenerationStatus> get values =>
      _$gImageGenerationStatusValues;

  static GImageGenerationStatus valueOf(String name) =>
      _$gImageGenerationStatusValueOf(name);
}

class GSubscriptionState extends EnumClass {
  const GSubscriptionState._(String name) : super(name);

  static const GSubscriptionState ACTIVE = _$gSubscriptionStateACTIVE;

  static const GSubscriptionState GRACE = _$gSubscriptionStateGRACE;

  static const GSubscriptionState PENDING_SYNC =
      _$gSubscriptionStatePENDING_SYNC;

  static const GSubscriptionState EXPIRED = _$gSubscriptionStateEXPIRED;

  static const GSubscriptionState REVOKED = _$gSubscriptionStateREVOKED;

  static Serializer<GSubscriptionState> get serializer =>
      _$gSubscriptionStateSerializer;

  static BuiltSet<GSubscriptionState> get values => _$gSubscriptionStateValues;

  static GSubscriptionState valueOf(String name) =>
      _$gSubscriptionStateValueOf(name);
}

class GPlanCode extends EnumClass {
  const GPlanCode._(String name) : super(name);

  static const GPlanCode FREE = _$gPlanCodeFREE;

  static const GPlanCode STANDARD_MONTHLY = _$gPlanCodeSTANDARD_MONTHLY;

  static const GPlanCode PRO_MONTHLY = _$gPlanCodePRO_MONTHLY;

  static Serializer<GPlanCode> get serializer => _$gPlanCodeSerializer;

  static BuiltSet<GPlanCode> get values => _$gPlanCodeValues;

  static GPlanCode valueOf(String name) => _$gPlanCodeValueOf(name);
}

class GEntitlementBundle extends EnumClass {
  const GEntitlementBundle._(String name) : super(name);

  static const GEntitlementBundle FREE_BASIC = _$gEntitlementBundleFREE_BASIC;

  static const GEntitlementBundle PREMIUM_GENERATION =
      _$gEntitlementBundlePREMIUM_GENERATION;

  static Serializer<GEntitlementBundle> get serializer =>
      _$gEntitlementBundleSerializer;

  static BuiltSet<GEntitlementBundle> get values => _$gEntitlementBundleValues;

  static GEntitlementBundle valueOf(String name) =>
      _$gEntitlementBundleValueOf(name);
}

class GFrequencyLevel extends EnumClass {
  const GFrequencyLevel._(String name) : super(name);

  static const GFrequencyLevel OFTEN = _$gFrequencyLevelOFTEN;

  static const GFrequencyLevel SOMETIMES = _$gFrequencyLevelSOMETIMES;

  static const GFrequencyLevel RARELY = _$gFrequencyLevelRARELY;

  static const GFrequencyLevel HARDLY_EVER = _$gFrequencyLevelHARDLY_EVER;

  static Serializer<GFrequencyLevel> get serializer =>
      _$gFrequencyLevelSerializer;

  static BuiltSet<GFrequencyLevel> get values => _$gFrequencyLevelValues;

  static GFrequencyLevel valueOf(String name) => _$gFrequencyLevelValueOf(name);
}

class GSophisticationLevel extends EnumClass {
  const GSophisticationLevel._(String name) : super(name);

  static const GSophisticationLevel VERY_BASIC =
      _$gSophisticationLevelVERY_BASIC;

  static const GSophisticationLevel BASIC = _$gSophisticationLevelBASIC;

  static const GSophisticationLevel INTERMEDIATE =
      _$gSophisticationLevelINTERMEDIATE;

  static const GSophisticationLevel ADVANCED = _$gSophisticationLevelADVANCED;

  static Serializer<GSophisticationLevel> get serializer =>
      _$gSophisticationLevelSerializer;

  static BuiltSet<GSophisticationLevel> get values =>
      _$gSophisticationLevelValues;

  static GSophisticationLevel valueOf(String name) =>
      _$gSophisticationLevelValueOf(name);
}

class GProficiencyLevel extends EnumClass {
  const GProficiencyLevel._(String name) : super(name);

  static const GProficiencyLevel LEARNING = _$gProficiencyLevelLEARNING;

  static const GProficiencyLevel LEARNED = _$gProficiencyLevelLEARNED;

  static const GProficiencyLevel INTERNALIZED = _$gProficiencyLevelINTERNALIZED;

  static const GProficiencyLevel FLUENT = _$gProficiencyLevelFLUENT;

  static Serializer<GProficiencyLevel> get serializer =>
      _$gProficiencyLevelSerializer;

  static BuiltSet<GProficiencyLevel> get values => _$gProficiencyLevelValues;

  static GProficiencyLevel valueOf(String name) =>
      _$gProficiencyLevelValueOf(name);
}

class GAcceptanceOutcome extends EnumClass {
  const GAcceptanceOutcome._(String name) : super(name);

  static const GAcceptanceOutcome ACCEPTED = _$gAcceptanceOutcomeACCEPTED;

  static const GAcceptanceOutcome REUSED_EXISTING =
      _$gAcceptanceOutcomeREUSED_EXISTING;

  static Serializer<GAcceptanceOutcome> get serializer =>
      _$gAcceptanceOutcomeSerializer;

  static BuiltSet<GAcceptanceOutcome> get values => _$gAcceptanceOutcomeValues;

  static GAcceptanceOutcome valueOf(String name) =>
      _$gAcceptanceOutcomeValueOf(name);
}

class GCommandErrorCategory extends EnumClass {
  const GCommandErrorCategory._(String name) : super(name);

  static const GCommandErrorCategory VALIDATION_FAILED =
      _$gCommandErrorCategoryVALIDATION_FAILED;

  static const GCommandErrorCategory TARGET_MISSING =
      _$gCommandErrorCategoryTARGET_MISSING;

  static const GCommandErrorCategory TARGET_NOT_READY =
      _$gCommandErrorCategoryTARGET_NOT_READY;

  static const GCommandErrorCategory DISPATCH_FAILED =
      _$gCommandErrorCategoryDISPATCH_FAILED;

  static const GCommandErrorCategory DOWNSTREAM_UNAVAILABLE =
      _$gCommandErrorCategoryDOWNSTREAM_UNAVAILABLE;

  static const GCommandErrorCategory DOWNSTREAM_AUTH_FAILED =
      _$gCommandErrorCategoryDOWNSTREAM_AUTH_FAILED;

  static Serializer<GCommandErrorCategory> get serializer =>
      _$gCommandErrorCategorySerializer;

  static BuiltSet<GCommandErrorCategory> get values =>
      _$gCommandErrorCategoryValues;

  static GCommandErrorCategory valueOf(String name) =>
      _$gCommandErrorCategoryValueOf(name);
}

class GSessionStateCode extends EnumClass {
  const GSessionStateCode._(String name) : super(name);

  static const GSessionStateCode ACTIVE = _$gSessionStateCodeACTIVE;

  static const GSessionStateCode INACTIVE = _$gSessionStateCodeINACTIVE;

  static const GSessionStateCode REVOKED = _$gSessionStateCodeREVOKED;

  static Serializer<GSessionStateCode> get serializer =>
      _$gSessionStateCodeSerializer;

  static BuiltSet<GSessionStateCode> get values => _$gSessionStateCodeValues;

  static GSessionStateCode valueOf(String name) =>
      _$gSessionStateCodeValueOf(name);
}

abstract class GRegisterVocabularyExpressionInput
    implements
        Built<GRegisterVocabularyExpressionInput,
            GRegisterVocabularyExpressionInputBuilder> {
  GRegisterVocabularyExpressionInput._();

  factory GRegisterVocabularyExpressionInput(
      [void Function(GRegisterVocabularyExpressionInputBuilder b)
          updates]) = _$GRegisterVocabularyExpressionInput;

  String get text;
  String get idempotencyKey;
  static Serializer<GRegisterVocabularyExpressionInput> get serializer =>
      _$gRegisterVocabularyExpressionInputSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GRegisterVocabularyExpressionInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRegisterVocabularyExpressionInput? fromJson(
          Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GRegisterVocabularyExpressionInput.serializer,
        json,
      );
}

abstract class GRequestGenerationInput
    implements Built<GRequestGenerationInput, GRequestGenerationInputBuilder> {
  GRequestGenerationInput._();

  factory GRequestGenerationInput(
          [void Function(GRequestGenerationInputBuilder b) updates]) =
      _$GRequestGenerationInput;

  String get vocabularyExpression;
  String get idempotencyKey;
  static Serializer<GRequestGenerationInput> get serializer =>
      _$gRequestGenerationInputSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GRequestGenerationInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRequestGenerationInput? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GRequestGenerationInput.serializer,
        json,
      );
}

abstract class GRetryGenerationInput
    implements Built<GRetryGenerationInput, GRetryGenerationInputBuilder> {
  GRetryGenerationInput._();

  factory GRetryGenerationInput(
          [void Function(GRetryGenerationInputBuilder b) updates]) =
      _$GRetryGenerationInput;

  String get vocabularyExpression;
  GGenerationTargetKind get target;
  String get idempotencyKey;
  static Serializer<GRetryGenerationInput> get serializer =>
      _$gRetryGenerationInputSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GRetryGenerationInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRetryGenerationInput? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GRetryGenerationInput.serializer,
        json,
      );
}

abstract class GRequestPurchaseInput
    implements Built<GRequestPurchaseInput, GRequestPurchaseInputBuilder> {
  GRequestPurchaseInput._();

  factory GRequestPurchaseInput(
          [void Function(GRequestPurchaseInputBuilder b) updates]) =
      _$GRequestPurchaseInput;

  GPlanCode get planCode;
  String get idempotencyKey;
  static Serializer<GRequestPurchaseInput> get serializer =>
      _$gRequestPurchaseInputSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GRequestPurchaseInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRequestPurchaseInput? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GRequestPurchaseInput.serializer,
        json,
      );
}

abstract class GRequestRestorePurchaseInput
    implements
        Built<GRequestRestorePurchaseInput,
            GRequestRestorePurchaseInputBuilder> {
  GRequestRestorePurchaseInput._();

  factory GRequestRestorePurchaseInput(
          [void Function(GRequestRestorePurchaseInputBuilder b) updates]) =
      _$GRequestRestorePurchaseInput;

  String get idempotencyKey;
  static Serializer<GRequestRestorePurchaseInput> get serializer =>
      _$gRequestRestorePurchaseInputSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GRequestRestorePurchaseInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRequestRestorePurchaseInput? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GRequestRestorePurchaseInput.serializer,
        json,
      );
}

const Map<String, Set<String>> possibleTypesMap = {};
