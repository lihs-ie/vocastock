// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.schema.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GAuthProvider _$gAuthProviderBASIC = const GAuthProvider._('BASIC');
const GAuthProvider _$gAuthProviderGOOGLE = const GAuthProvider._('GOOGLE');

GAuthProvider _$gAuthProviderValueOf(String name) {
  switch (name) {
    case 'BASIC':
      return _$gAuthProviderBASIC;
    case 'GOOGLE':
      return _$gAuthProviderGOOGLE;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GAuthProvider> _$gAuthProviderValues = BuiltSet<GAuthProvider>(
  const <GAuthProvider>[_$gAuthProviderBASIC, _$gAuthProviderGOOGLE],
);

const GRegistrationStatus _$gRegistrationStatusACTIVE =
    const GRegistrationStatus._('ACTIVE');
const GRegistrationStatus _$gRegistrationStatusARCHIVED =
    const GRegistrationStatus._('ARCHIVED');

GRegistrationStatus _$gRegistrationStatusValueOf(String name) {
  switch (name) {
    case 'ACTIVE':
      return _$gRegistrationStatusACTIVE;
    case 'ARCHIVED':
      return _$gRegistrationStatusARCHIVED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GRegistrationStatus> _$gRegistrationStatusValues =
    BuiltSet<GRegistrationStatus>(const <GRegistrationStatus>[
      _$gRegistrationStatusACTIVE,
      _$gRegistrationStatusARCHIVED,
    ]);

const GGenerationTargetKind _$gGenerationTargetKindEXPLANATION =
    const GGenerationTargetKind._('EXPLANATION');
const GGenerationTargetKind _$gGenerationTargetKindIMAGE =
    const GGenerationTargetKind._('IMAGE');

GGenerationTargetKind _$gGenerationTargetKindValueOf(String name) {
  switch (name) {
    case 'EXPLANATION':
      return _$gGenerationTargetKindEXPLANATION;
    case 'IMAGE':
      return _$gGenerationTargetKindIMAGE;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GGenerationTargetKind> _$gGenerationTargetKindValues =
    BuiltSet<GGenerationTargetKind>(const <GGenerationTargetKind>[
      _$gGenerationTargetKindEXPLANATION,
      _$gGenerationTargetKindIMAGE,
    ]);

const GExplanationGenerationStatus _$gExplanationGenerationStatusPENDING =
    const GExplanationGenerationStatus._('PENDING');
const GExplanationGenerationStatus _$gExplanationGenerationStatusRUNNING =
    const GExplanationGenerationStatus._('RUNNING');
const GExplanationGenerationStatus
_$gExplanationGenerationStatusRETRY_SCHEDULED =
    const GExplanationGenerationStatus._('RETRY_SCHEDULED');
const GExplanationGenerationStatus _$gExplanationGenerationStatusTIMED_OUT =
    const GExplanationGenerationStatus._('TIMED_OUT');
const GExplanationGenerationStatus _$gExplanationGenerationStatusSUCCEEDED =
    const GExplanationGenerationStatus._('SUCCEEDED');
const GExplanationGenerationStatus _$gExplanationGenerationStatusFAILED_FINAL =
    const GExplanationGenerationStatus._('FAILED_FINAL');
const GExplanationGenerationStatus _$gExplanationGenerationStatusDEAD_LETTERED =
    const GExplanationGenerationStatus._('DEAD_LETTERED');

GExplanationGenerationStatus _$gExplanationGenerationStatusValueOf(
  String name,
) {
  switch (name) {
    case 'PENDING':
      return _$gExplanationGenerationStatusPENDING;
    case 'RUNNING':
      return _$gExplanationGenerationStatusRUNNING;
    case 'RETRY_SCHEDULED':
      return _$gExplanationGenerationStatusRETRY_SCHEDULED;
    case 'TIMED_OUT':
      return _$gExplanationGenerationStatusTIMED_OUT;
    case 'SUCCEEDED':
      return _$gExplanationGenerationStatusSUCCEEDED;
    case 'FAILED_FINAL':
      return _$gExplanationGenerationStatusFAILED_FINAL;
    case 'DEAD_LETTERED':
      return _$gExplanationGenerationStatusDEAD_LETTERED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GExplanationGenerationStatus>
_$gExplanationGenerationStatusValues =
    BuiltSet<GExplanationGenerationStatus>(const <GExplanationGenerationStatus>[
      _$gExplanationGenerationStatusPENDING,
      _$gExplanationGenerationStatusRUNNING,
      _$gExplanationGenerationStatusRETRY_SCHEDULED,
      _$gExplanationGenerationStatusTIMED_OUT,
      _$gExplanationGenerationStatusSUCCEEDED,
      _$gExplanationGenerationStatusFAILED_FINAL,
      _$gExplanationGenerationStatusDEAD_LETTERED,
    ]);

const GImageGenerationStatus _$gImageGenerationStatusPENDING =
    const GImageGenerationStatus._('PENDING');
const GImageGenerationStatus _$gImageGenerationStatusRUNNING =
    const GImageGenerationStatus._('RUNNING');
const GImageGenerationStatus _$gImageGenerationStatusRETRY_SCHEDULED =
    const GImageGenerationStatus._('RETRY_SCHEDULED');
const GImageGenerationStatus _$gImageGenerationStatusTIMED_OUT =
    const GImageGenerationStatus._('TIMED_OUT');
const GImageGenerationStatus _$gImageGenerationStatusSUCCEEDED =
    const GImageGenerationStatus._('SUCCEEDED');
const GImageGenerationStatus _$gImageGenerationStatusFAILED_FINAL =
    const GImageGenerationStatus._('FAILED_FINAL');
const GImageGenerationStatus _$gImageGenerationStatusDEAD_LETTERED =
    const GImageGenerationStatus._('DEAD_LETTERED');

GImageGenerationStatus _$gImageGenerationStatusValueOf(String name) {
  switch (name) {
    case 'PENDING':
      return _$gImageGenerationStatusPENDING;
    case 'RUNNING':
      return _$gImageGenerationStatusRUNNING;
    case 'RETRY_SCHEDULED':
      return _$gImageGenerationStatusRETRY_SCHEDULED;
    case 'TIMED_OUT':
      return _$gImageGenerationStatusTIMED_OUT;
    case 'SUCCEEDED':
      return _$gImageGenerationStatusSUCCEEDED;
    case 'FAILED_FINAL':
      return _$gImageGenerationStatusFAILED_FINAL;
    case 'DEAD_LETTERED':
      return _$gImageGenerationStatusDEAD_LETTERED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GImageGenerationStatus> _$gImageGenerationStatusValues =
    BuiltSet<GImageGenerationStatus>(const <GImageGenerationStatus>[
      _$gImageGenerationStatusPENDING,
      _$gImageGenerationStatusRUNNING,
      _$gImageGenerationStatusRETRY_SCHEDULED,
      _$gImageGenerationStatusTIMED_OUT,
      _$gImageGenerationStatusSUCCEEDED,
      _$gImageGenerationStatusFAILED_FINAL,
      _$gImageGenerationStatusDEAD_LETTERED,
    ]);

const GSubscriptionState _$gSubscriptionStateACTIVE =
    const GSubscriptionState._('ACTIVE');
const GSubscriptionState _$gSubscriptionStateGRACE = const GSubscriptionState._(
  'GRACE',
);
const GSubscriptionState _$gSubscriptionStatePENDING_SYNC =
    const GSubscriptionState._('PENDING_SYNC');
const GSubscriptionState _$gSubscriptionStateEXPIRED =
    const GSubscriptionState._('EXPIRED');
const GSubscriptionState _$gSubscriptionStateREVOKED =
    const GSubscriptionState._('REVOKED');

GSubscriptionState _$gSubscriptionStateValueOf(String name) {
  switch (name) {
    case 'ACTIVE':
      return _$gSubscriptionStateACTIVE;
    case 'GRACE':
      return _$gSubscriptionStateGRACE;
    case 'PENDING_SYNC':
      return _$gSubscriptionStatePENDING_SYNC;
    case 'EXPIRED':
      return _$gSubscriptionStateEXPIRED;
    case 'REVOKED':
      return _$gSubscriptionStateREVOKED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GSubscriptionState> _$gSubscriptionStateValues =
    BuiltSet<GSubscriptionState>(const <GSubscriptionState>[
      _$gSubscriptionStateACTIVE,
      _$gSubscriptionStateGRACE,
      _$gSubscriptionStatePENDING_SYNC,
      _$gSubscriptionStateEXPIRED,
      _$gSubscriptionStateREVOKED,
    ]);

const GPlanCode _$gPlanCodeFREE = const GPlanCode._('FREE');
const GPlanCode _$gPlanCodeSTANDARD_MONTHLY = const GPlanCode._(
  'STANDARD_MONTHLY',
);
const GPlanCode _$gPlanCodePRO_MONTHLY = const GPlanCode._('PRO_MONTHLY');

GPlanCode _$gPlanCodeValueOf(String name) {
  switch (name) {
    case 'FREE':
      return _$gPlanCodeFREE;
    case 'STANDARD_MONTHLY':
      return _$gPlanCodeSTANDARD_MONTHLY;
    case 'PRO_MONTHLY':
      return _$gPlanCodePRO_MONTHLY;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GPlanCode> _$gPlanCodeValues = BuiltSet<GPlanCode>(
  const <GPlanCode>[
    _$gPlanCodeFREE,
    _$gPlanCodeSTANDARD_MONTHLY,
    _$gPlanCodePRO_MONTHLY,
  ],
);

const GEntitlementBundle _$gEntitlementBundleFREE_BASIC =
    const GEntitlementBundle._('FREE_BASIC');
const GEntitlementBundle _$gEntitlementBundlePREMIUM_GENERATION =
    const GEntitlementBundle._('PREMIUM_GENERATION');

GEntitlementBundle _$gEntitlementBundleValueOf(String name) {
  switch (name) {
    case 'FREE_BASIC':
      return _$gEntitlementBundleFREE_BASIC;
    case 'PREMIUM_GENERATION':
      return _$gEntitlementBundlePREMIUM_GENERATION;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GEntitlementBundle> _$gEntitlementBundleValues =
    BuiltSet<GEntitlementBundle>(const <GEntitlementBundle>[
      _$gEntitlementBundleFREE_BASIC,
      _$gEntitlementBundlePREMIUM_GENERATION,
    ]);

const GFrequencyLevel _$gFrequencyLevelOFTEN = const GFrequencyLevel._('OFTEN');
const GFrequencyLevel _$gFrequencyLevelSOMETIMES = const GFrequencyLevel._(
  'SOMETIMES',
);
const GFrequencyLevel _$gFrequencyLevelRARELY = const GFrequencyLevel._(
  'RARELY',
);
const GFrequencyLevel _$gFrequencyLevelHARDLY_EVER = const GFrequencyLevel._(
  'HARDLY_EVER',
);

GFrequencyLevel _$gFrequencyLevelValueOf(String name) {
  switch (name) {
    case 'OFTEN':
      return _$gFrequencyLevelOFTEN;
    case 'SOMETIMES':
      return _$gFrequencyLevelSOMETIMES;
    case 'RARELY':
      return _$gFrequencyLevelRARELY;
    case 'HARDLY_EVER':
      return _$gFrequencyLevelHARDLY_EVER;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GFrequencyLevel> _$gFrequencyLevelValues =
    BuiltSet<GFrequencyLevel>(const <GFrequencyLevel>[
      _$gFrequencyLevelOFTEN,
      _$gFrequencyLevelSOMETIMES,
      _$gFrequencyLevelRARELY,
      _$gFrequencyLevelHARDLY_EVER,
    ]);

const GSophisticationLevel _$gSophisticationLevelVERY_BASIC =
    const GSophisticationLevel._('VERY_BASIC');
const GSophisticationLevel _$gSophisticationLevelBASIC =
    const GSophisticationLevel._('BASIC');
const GSophisticationLevel _$gSophisticationLevelINTERMEDIATE =
    const GSophisticationLevel._('INTERMEDIATE');
const GSophisticationLevel _$gSophisticationLevelADVANCED =
    const GSophisticationLevel._('ADVANCED');

GSophisticationLevel _$gSophisticationLevelValueOf(String name) {
  switch (name) {
    case 'VERY_BASIC':
      return _$gSophisticationLevelVERY_BASIC;
    case 'BASIC':
      return _$gSophisticationLevelBASIC;
    case 'INTERMEDIATE':
      return _$gSophisticationLevelINTERMEDIATE;
    case 'ADVANCED':
      return _$gSophisticationLevelADVANCED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GSophisticationLevel> _$gSophisticationLevelValues =
    BuiltSet<GSophisticationLevel>(const <GSophisticationLevel>[
      _$gSophisticationLevelVERY_BASIC,
      _$gSophisticationLevelBASIC,
      _$gSophisticationLevelINTERMEDIATE,
      _$gSophisticationLevelADVANCED,
    ]);

const GProficiencyLevel _$gProficiencyLevelLEARNING = const GProficiencyLevel._(
  'LEARNING',
);
const GProficiencyLevel _$gProficiencyLevelLEARNED = const GProficiencyLevel._(
  'LEARNED',
);
const GProficiencyLevel _$gProficiencyLevelINTERNALIZED =
    const GProficiencyLevel._('INTERNALIZED');
const GProficiencyLevel _$gProficiencyLevelFLUENT = const GProficiencyLevel._(
  'FLUENT',
);

GProficiencyLevel _$gProficiencyLevelValueOf(String name) {
  switch (name) {
    case 'LEARNING':
      return _$gProficiencyLevelLEARNING;
    case 'LEARNED':
      return _$gProficiencyLevelLEARNED;
    case 'INTERNALIZED':
      return _$gProficiencyLevelINTERNALIZED;
    case 'FLUENT':
      return _$gProficiencyLevelFLUENT;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GProficiencyLevel> _$gProficiencyLevelValues =
    BuiltSet<GProficiencyLevel>(const <GProficiencyLevel>[
      _$gProficiencyLevelLEARNING,
      _$gProficiencyLevelLEARNED,
      _$gProficiencyLevelINTERNALIZED,
      _$gProficiencyLevelFLUENT,
    ]);

const GAcceptanceOutcome _$gAcceptanceOutcomeACCEPTED =
    const GAcceptanceOutcome._('ACCEPTED');
const GAcceptanceOutcome _$gAcceptanceOutcomeREUSED_EXISTING =
    const GAcceptanceOutcome._('REUSED_EXISTING');

GAcceptanceOutcome _$gAcceptanceOutcomeValueOf(String name) {
  switch (name) {
    case 'ACCEPTED':
      return _$gAcceptanceOutcomeACCEPTED;
    case 'REUSED_EXISTING':
      return _$gAcceptanceOutcomeREUSED_EXISTING;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GAcceptanceOutcome> _$gAcceptanceOutcomeValues =
    BuiltSet<GAcceptanceOutcome>(const <GAcceptanceOutcome>[
      _$gAcceptanceOutcomeACCEPTED,
      _$gAcceptanceOutcomeREUSED_EXISTING,
    ]);

const GCommandErrorCategory _$gCommandErrorCategoryVALIDATION_FAILED =
    const GCommandErrorCategory._('VALIDATION_FAILED');
const GCommandErrorCategory _$gCommandErrorCategoryTARGET_MISSING =
    const GCommandErrorCategory._('TARGET_MISSING');
const GCommandErrorCategory _$gCommandErrorCategoryTARGET_NOT_READY =
    const GCommandErrorCategory._('TARGET_NOT_READY');
const GCommandErrorCategory _$gCommandErrorCategoryDISPATCH_FAILED =
    const GCommandErrorCategory._('DISPATCH_FAILED');
const GCommandErrorCategory _$gCommandErrorCategoryDOWNSTREAM_UNAVAILABLE =
    const GCommandErrorCategory._('DOWNSTREAM_UNAVAILABLE');
const GCommandErrorCategory _$gCommandErrorCategoryDOWNSTREAM_AUTH_FAILED =
    const GCommandErrorCategory._('DOWNSTREAM_AUTH_FAILED');

GCommandErrorCategory _$gCommandErrorCategoryValueOf(String name) {
  switch (name) {
    case 'VALIDATION_FAILED':
      return _$gCommandErrorCategoryVALIDATION_FAILED;
    case 'TARGET_MISSING':
      return _$gCommandErrorCategoryTARGET_MISSING;
    case 'TARGET_NOT_READY':
      return _$gCommandErrorCategoryTARGET_NOT_READY;
    case 'DISPATCH_FAILED':
      return _$gCommandErrorCategoryDISPATCH_FAILED;
    case 'DOWNSTREAM_UNAVAILABLE':
      return _$gCommandErrorCategoryDOWNSTREAM_UNAVAILABLE;
    case 'DOWNSTREAM_AUTH_FAILED':
      return _$gCommandErrorCategoryDOWNSTREAM_AUTH_FAILED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GCommandErrorCategory> _$gCommandErrorCategoryValues =
    BuiltSet<GCommandErrorCategory>(const <GCommandErrorCategory>[
      _$gCommandErrorCategoryVALIDATION_FAILED,
      _$gCommandErrorCategoryTARGET_MISSING,
      _$gCommandErrorCategoryTARGET_NOT_READY,
      _$gCommandErrorCategoryDISPATCH_FAILED,
      _$gCommandErrorCategoryDOWNSTREAM_UNAVAILABLE,
      _$gCommandErrorCategoryDOWNSTREAM_AUTH_FAILED,
    ]);

const GSessionStateCode _$gSessionStateCodeACTIVE = const GSessionStateCode._(
  'ACTIVE',
);
const GSessionStateCode _$gSessionStateCodeINACTIVE = const GSessionStateCode._(
  'INACTIVE',
);
const GSessionStateCode _$gSessionStateCodeREVOKED = const GSessionStateCode._(
  'REVOKED',
);

GSessionStateCode _$gSessionStateCodeValueOf(String name) {
  switch (name) {
    case 'ACTIVE':
      return _$gSessionStateCodeACTIVE;
    case 'INACTIVE':
      return _$gSessionStateCodeINACTIVE;
    case 'REVOKED':
      return _$gSessionStateCodeREVOKED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GSessionStateCode> _$gSessionStateCodeValues =
    BuiltSet<GSessionStateCode>(const <GSessionStateCode>[
      _$gSessionStateCodeACTIVE,
      _$gSessionStateCodeINACTIVE,
      _$gSessionStateCodeREVOKED,
    ]);

Serializer<GAuthProvider> _$gAuthProviderSerializer =
    _$GAuthProviderSerializer();
Serializer<GRegistrationStatus> _$gRegistrationStatusSerializer =
    _$GRegistrationStatusSerializer();
Serializer<GGenerationTargetKind> _$gGenerationTargetKindSerializer =
    _$GGenerationTargetKindSerializer();
Serializer<GExplanationGenerationStatus>
_$gExplanationGenerationStatusSerializer =
    _$GExplanationGenerationStatusSerializer();
Serializer<GImageGenerationStatus> _$gImageGenerationStatusSerializer =
    _$GImageGenerationStatusSerializer();
Serializer<GSubscriptionState> _$gSubscriptionStateSerializer =
    _$GSubscriptionStateSerializer();
Serializer<GPlanCode> _$gPlanCodeSerializer = _$GPlanCodeSerializer();
Serializer<GEntitlementBundle> _$gEntitlementBundleSerializer =
    _$GEntitlementBundleSerializer();
Serializer<GFrequencyLevel> _$gFrequencyLevelSerializer =
    _$GFrequencyLevelSerializer();
Serializer<GSophisticationLevel> _$gSophisticationLevelSerializer =
    _$GSophisticationLevelSerializer();
Serializer<GProficiencyLevel> _$gProficiencyLevelSerializer =
    _$GProficiencyLevelSerializer();
Serializer<GAcceptanceOutcome> _$gAcceptanceOutcomeSerializer =
    _$GAcceptanceOutcomeSerializer();
Serializer<GCommandErrorCategory> _$gCommandErrorCategorySerializer =
    _$GCommandErrorCategorySerializer();
Serializer<GSessionStateCode> _$gSessionStateCodeSerializer =
    _$GSessionStateCodeSerializer();
Serializer<GRegisterVocabularyExpressionInput>
_$gRegisterVocabularyExpressionInputSerializer =
    _$GRegisterVocabularyExpressionInputSerializer();
Serializer<GRequestGenerationInput> _$gRequestGenerationInputSerializer =
    _$GRequestGenerationInputSerializer();
Serializer<GRetryGenerationInput> _$gRetryGenerationInputSerializer =
    _$GRetryGenerationInputSerializer();
Serializer<GRequestPurchaseInput> _$gRequestPurchaseInputSerializer =
    _$GRequestPurchaseInputSerializer();
Serializer<GRequestRestorePurchaseInput>
_$gRequestRestorePurchaseInputSerializer =
    _$GRequestRestorePurchaseInputSerializer();

class _$GAuthProviderSerializer implements PrimitiveSerializer<GAuthProvider> {
  @override
  final Iterable<Type> types = const <Type>[GAuthProvider];
  @override
  final String wireName = 'GAuthProvider';

  @override
  Object serialize(
    Serializers serializers,
    GAuthProvider object, {
    FullType specifiedType = FullType.unspecified,
  }) => object.name;

  @override
  GAuthProvider deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => GAuthProvider.valueOf(serialized as String);
}

class _$GRegistrationStatusSerializer
    implements PrimitiveSerializer<GRegistrationStatus> {
  @override
  final Iterable<Type> types = const <Type>[GRegistrationStatus];
  @override
  final String wireName = 'GRegistrationStatus';

  @override
  Object serialize(
    Serializers serializers,
    GRegistrationStatus object, {
    FullType specifiedType = FullType.unspecified,
  }) => object.name;

  @override
  GRegistrationStatus deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => GRegistrationStatus.valueOf(serialized as String);
}

class _$GGenerationTargetKindSerializer
    implements PrimitiveSerializer<GGenerationTargetKind> {
  @override
  final Iterable<Type> types = const <Type>[GGenerationTargetKind];
  @override
  final String wireName = 'GGenerationTargetKind';

  @override
  Object serialize(
    Serializers serializers,
    GGenerationTargetKind object, {
    FullType specifiedType = FullType.unspecified,
  }) => object.name;

  @override
  GGenerationTargetKind deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => GGenerationTargetKind.valueOf(serialized as String);
}

class _$GExplanationGenerationStatusSerializer
    implements PrimitiveSerializer<GExplanationGenerationStatus> {
  @override
  final Iterable<Type> types = const <Type>[GExplanationGenerationStatus];
  @override
  final String wireName = 'GExplanationGenerationStatus';

  @override
  Object serialize(
    Serializers serializers,
    GExplanationGenerationStatus object, {
    FullType specifiedType = FullType.unspecified,
  }) => object.name;

  @override
  GExplanationGenerationStatus deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => GExplanationGenerationStatus.valueOf(serialized as String);
}

class _$GImageGenerationStatusSerializer
    implements PrimitiveSerializer<GImageGenerationStatus> {
  @override
  final Iterable<Type> types = const <Type>[GImageGenerationStatus];
  @override
  final String wireName = 'GImageGenerationStatus';

  @override
  Object serialize(
    Serializers serializers,
    GImageGenerationStatus object, {
    FullType specifiedType = FullType.unspecified,
  }) => object.name;

  @override
  GImageGenerationStatus deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => GImageGenerationStatus.valueOf(serialized as String);
}

class _$GSubscriptionStateSerializer
    implements PrimitiveSerializer<GSubscriptionState> {
  @override
  final Iterable<Type> types = const <Type>[GSubscriptionState];
  @override
  final String wireName = 'GSubscriptionState';

  @override
  Object serialize(
    Serializers serializers,
    GSubscriptionState object, {
    FullType specifiedType = FullType.unspecified,
  }) => object.name;

  @override
  GSubscriptionState deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => GSubscriptionState.valueOf(serialized as String);
}

class _$GPlanCodeSerializer implements PrimitiveSerializer<GPlanCode> {
  @override
  final Iterable<Type> types = const <Type>[GPlanCode];
  @override
  final String wireName = 'GPlanCode';

  @override
  Object serialize(
    Serializers serializers,
    GPlanCode object, {
    FullType specifiedType = FullType.unspecified,
  }) => object.name;

  @override
  GPlanCode deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => GPlanCode.valueOf(serialized as String);
}

class _$GEntitlementBundleSerializer
    implements PrimitiveSerializer<GEntitlementBundle> {
  @override
  final Iterable<Type> types = const <Type>[GEntitlementBundle];
  @override
  final String wireName = 'GEntitlementBundle';

  @override
  Object serialize(
    Serializers serializers,
    GEntitlementBundle object, {
    FullType specifiedType = FullType.unspecified,
  }) => object.name;

  @override
  GEntitlementBundle deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => GEntitlementBundle.valueOf(serialized as String);
}

class _$GFrequencyLevelSerializer
    implements PrimitiveSerializer<GFrequencyLevel> {
  @override
  final Iterable<Type> types = const <Type>[GFrequencyLevel];
  @override
  final String wireName = 'GFrequencyLevel';

  @override
  Object serialize(
    Serializers serializers,
    GFrequencyLevel object, {
    FullType specifiedType = FullType.unspecified,
  }) => object.name;

  @override
  GFrequencyLevel deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => GFrequencyLevel.valueOf(serialized as String);
}

class _$GSophisticationLevelSerializer
    implements PrimitiveSerializer<GSophisticationLevel> {
  @override
  final Iterable<Type> types = const <Type>[GSophisticationLevel];
  @override
  final String wireName = 'GSophisticationLevel';

  @override
  Object serialize(
    Serializers serializers,
    GSophisticationLevel object, {
    FullType specifiedType = FullType.unspecified,
  }) => object.name;

  @override
  GSophisticationLevel deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => GSophisticationLevel.valueOf(serialized as String);
}

class _$GProficiencyLevelSerializer
    implements PrimitiveSerializer<GProficiencyLevel> {
  @override
  final Iterable<Type> types = const <Type>[GProficiencyLevel];
  @override
  final String wireName = 'GProficiencyLevel';

  @override
  Object serialize(
    Serializers serializers,
    GProficiencyLevel object, {
    FullType specifiedType = FullType.unspecified,
  }) => object.name;

  @override
  GProficiencyLevel deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => GProficiencyLevel.valueOf(serialized as String);
}

class _$GAcceptanceOutcomeSerializer
    implements PrimitiveSerializer<GAcceptanceOutcome> {
  @override
  final Iterable<Type> types = const <Type>[GAcceptanceOutcome];
  @override
  final String wireName = 'GAcceptanceOutcome';

  @override
  Object serialize(
    Serializers serializers,
    GAcceptanceOutcome object, {
    FullType specifiedType = FullType.unspecified,
  }) => object.name;

  @override
  GAcceptanceOutcome deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => GAcceptanceOutcome.valueOf(serialized as String);
}

class _$GCommandErrorCategorySerializer
    implements PrimitiveSerializer<GCommandErrorCategory> {
  @override
  final Iterable<Type> types = const <Type>[GCommandErrorCategory];
  @override
  final String wireName = 'GCommandErrorCategory';

  @override
  Object serialize(
    Serializers serializers,
    GCommandErrorCategory object, {
    FullType specifiedType = FullType.unspecified,
  }) => object.name;

  @override
  GCommandErrorCategory deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => GCommandErrorCategory.valueOf(serialized as String);
}

class _$GSessionStateCodeSerializer
    implements PrimitiveSerializer<GSessionStateCode> {
  @override
  final Iterable<Type> types = const <Type>[GSessionStateCode];
  @override
  final String wireName = 'GSessionStateCode';

  @override
  Object serialize(
    Serializers serializers,
    GSessionStateCode object, {
    FullType specifiedType = FullType.unspecified,
  }) => object.name;

  @override
  GSessionStateCode deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => GSessionStateCode.valueOf(serialized as String);
}

class _$GRegisterVocabularyExpressionInputSerializer
    implements StructuredSerializer<GRegisterVocabularyExpressionInput> {
  @override
  final Iterable<Type> types = const [
    GRegisterVocabularyExpressionInput,
    _$GRegisterVocabularyExpressionInput,
  ];
  @override
  final String wireName = 'GRegisterVocabularyExpressionInput';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GRegisterVocabularyExpressionInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'text',
      serializers.serialize(object.text, specifiedType: const FullType(String)),
      'idempotencyKey',
      serializers.serialize(
        object.idempotencyKey,
        specifiedType: const FullType(String),
      ),
    ];

    return result;
  }

  @override
  GRegisterVocabularyExpressionInput deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GRegisterVocabularyExpressionInputBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'text':
          result.text =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'idempotencyKey':
          result.idempotencyKey =
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

class _$GRequestGenerationInputSerializer
    implements StructuredSerializer<GRequestGenerationInput> {
  @override
  final Iterable<Type> types = const [
    GRequestGenerationInput,
    _$GRequestGenerationInput,
  ];
  @override
  final String wireName = 'GRequestGenerationInput';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GRequestGenerationInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'vocabularyExpression',
      serializers.serialize(
        object.vocabularyExpression,
        specifiedType: const FullType(String),
      ),
      'idempotencyKey',
      serializers.serialize(
        object.idempotencyKey,
        specifiedType: const FullType(String),
      ),
    ];

    return result;
  }

  @override
  GRequestGenerationInput deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GRequestGenerationInputBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'vocabularyExpression':
          result.vocabularyExpression =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'idempotencyKey':
          result.idempotencyKey =
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

class _$GRetryGenerationInputSerializer
    implements StructuredSerializer<GRetryGenerationInput> {
  @override
  final Iterable<Type> types = const [
    GRetryGenerationInput,
    _$GRetryGenerationInput,
  ];
  @override
  final String wireName = 'GRetryGenerationInput';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GRetryGenerationInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'vocabularyExpression',
      serializers.serialize(
        object.vocabularyExpression,
        specifiedType: const FullType(String),
      ),
      'target',
      serializers.serialize(
        object.target,
        specifiedType: const FullType(GGenerationTargetKind),
      ),
      'idempotencyKey',
      serializers.serialize(
        object.idempotencyKey,
        specifiedType: const FullType(String),
      ),
    ];

    return result;
  }

  @override
  GRetryGenerationInput deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GRetryGenerationInputBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'vocabularyExpression':
          result.vocabularyExpression =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'target':
          result.target =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(GGenerationTargetKind),
                  )!
                  as GGenerationTargetKind;
          break;
        case 'idempotencyKey':
          result.idempotencyKey =
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

class _$GRequestPurchaseInputSerializer
    implements StructuredSerializer<GRequestPurchaseInput> {
  @override
  final Iterable<Type> types = const [
    GRequestPurchaseInput,
    _$GRequestPurchaseInput,
  ];
  @override
  final String wireName = 'GRequestPurchaseInput';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GRequestPurchaseInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'planCode',
      serializers.serialize(
        object.planCode,
        specifiedType: const FullType(GPlanCode),
      ),
      'idempotencyKey',
      serializers.serialize(
        object.idempotencyKey,
        specifiedType: const FullType(String),
      ),
    ];

    return result;
  }

  @override
  GRequestPurchaseInput deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GRequestPurchaseInputBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'planCode':
          result.planCode =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(GPlanCode),
                  )!
                  as GPlanCode;
          break;
        case 'idempotencyKey':
          result.idempotencyKey =
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

class _$GRequestRestorePurchaseInputSerializer
    implements StructuredSerializer<GRequestRestorePurchaseInput> {
  @override
  final Iterable<Type> types = const [
    GRequestRestorePurchaseInput,
    _$GRequestRestorePurchaseInput,
  ];
  @override
  final String wireName = 'GRequestRestorePurchaseInput';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GRequestRestorePurchaseInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'idempotencyKey',
      serializers.serialize(
        object.idempotencyKey,
        specifiedType: const FullType(String),
      ),
    ];

    return result;
  }

  @override
  GRequestRestorePurchaseInput deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GRequestRestorePurchaseInputBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'idempotencyKey':
          result.idempotencyKey =
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

class _$GDateTime extends GDateTime {
  @override
  final String value;

  factory _$GDateTime([void Function(GDateTimeBuilder)? updates]) =>
      (GDateTimeBuilder()..update(updates))._build();

  _$GDateTime._({required this.value}) : super._();
  @override
  GDateTime rebuild(void Function(GDateTimeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GDateTimeBuilder toBuilder() => GDateTimeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GDateTime && value == other.value;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'GDateTime',
    )..add('value', value)).toString();
  }
}

class GDateTimeBuilder implements Builder<GDateTime, GDateTimeBuilder> {
  _$GDateTime? _$v;

  String? _value;
  String? get value => _$this._value;
  set value(String? value) => _$this._value = value;

  GDateTimeBuilder();

  GDateTimeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _value = $v.value;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GDateTime other) {
    _$v = other as _$GDateTime;
  }

  @override
  void update(void Function(GDateTimeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GDateTime build() => _build();

  _$GDateTime _build() {
    final _$result =
        _$v ??
        _$GDateTime._(
          value: BuiltValueNullFieldError.checkNotNull(
            value,
            r'GDateTime',
            'value',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GULID extends GULID {
  @override
  final String value;

  factory _$GULID([void Function(GULIDBuilder)? updates]) =>
      (GULIDBuilder()..update(updates))._build();

  _$GULID._({required this.value}) : super._();
  @override
  GULID rebuild(void Function(GULIDBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GULIDBuilder toBuilder() => GULIDBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GULID && value == other.value;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'GULID',
    )..add('value', value)).toString();
  }
}

class GULIDBuilder implements Builder<GULID, GULIDBuilder> {
  _$GULID? _$v;

  String? _value;
  String? get value => _$this._value;
  set value(String? value) => _$this._value = value;

  GULIDBuilder();

  GULIDBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _value = $v.value;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GULID other) {
    _$v = other as _$GULID;
  }

  @override
  void update(void Function(GULIDBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GULID build() => _build();

  _$GULID _build() {
    final _$result =
        _$v ??
        _$GULID._(
          value: BuiltValueNullFieldError.checkNotNull(
            value,
            r'GULID',
            'value',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GRegisterVocabularyExpressionInput
    extends GRegisterVocabularyExpressionInput {
  @override
  final String text;
  @override
  final String idempotencyKey;

  factory _$GRegisterVocabularyExpressionInput([
    void Function(GRegisterVocabularyExpressionInputBuilder)? updates,
  ]) => (GRegisterVocabularyExpressionInputBuilder()..update(updates))._build();

  _$GRegisterVocabularyExpressionInput._({
    required this.text,
    required this.idempotencyKey,
  }) : super._();
  @override
  GRegisterVocabularyExpressionInput rebuild(
    void Function(GRegisterVocabularyExpressionInputBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GRegisterVocabularyExpressionInputBuilder toBuilder() =>
      GRegisterVocabularyExpressionInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRegisterVocabularyExpressionInput &&
        text == other.text &&
        idempotencyKey == other.idempotencyKey;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, text.hashCode);
    _$hash = $jc(_$hash, idempotencyKey.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GRegisterVocabularyExpressionInput')
          ..add('text', text)
          ..add('idempotencyKey', idempotencyKey))
        .toString();
  }
}

class GRegisterVocabularyExpressionInputBuilder
    implements
        Builder<
          GRegisterVocabularyExpressionInput,
          GRegisterVocabularyExpressionInputBuilder
        > {
  _$GRegisterVocabularyExpressionInput? _$v;

  String? _text;
  String? get text => _$this._text;
  set text(String? text) => _$this._text = text;

  String? _idempotencyKey;
  String? get idempotencyKey => _$this._idempotencyKey;
  set idempotencyKey(String? idempotencyKey) =>
      _$this._idempotencyKey = idempotencyKey;

  GRegisterVocabularyExpressionInputBuilder();

  GRegisterVocabularyExpressionInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _text = $v.text;
      _idempotencyKey = $v.idempotencyKey;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRegisterVocabularyExpressionInput other) {
    _$v = other as _$GRegisterVocabularyExpressionInput;
  }

  @override
  void update(
    void Function(GRegisterVocabularyExpressionInputBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GRegisterVocabularyExpressionInput build() => _build();

  _$GRegisterVocabularyExpressionInput _build() {
    final _$result =
        _$v ??
        _$GRegisterVocabularyExpressionInput._(
          text: BuiltValueNullFieldError.checkNotNull(
            text,
            r'GRegisterVocabularyExpressionInput',
            'text',
          ),
          idempotencyKey: BuiltValueNullFieldError.checkNotNull(
            idempotencyKey,
            r'GRegisterVocabularyExpressionInput',
            'idempotencyKey',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GRequestGenerationInput extends GRequestGenerationInput {
  @override
  final String vocabularyExpression;
  @override
  final String idempotencyKey;

  factory _$GRequestGenerationInput([
    void Function(GRequestGenerationInputBuilder)? updates,
  ]) => (GRequestGenerationInputBuilder()..update(updates))._build();

  _$GRequestGenerationInput._({
    required this.vocabularyExpression,
    required this.idempotencyKey,
  }) : super._();
  @override
  GRequestGenerationInput rebuild(
    void Function(GRequestGenerationInputBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GRequestGenerationInputBuilder toBuilder() =>
      GRequestGenerationInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRequestGenerationInput &&
        vocabularyExpression == other.vocabularyExpression &&
        idempotencyKey == other.idempotencyKey;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, vocabularyExpression.hashCode);
    _$hash = $jc(_$hash, idempotencyKey.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GRequestGenerationInput')
          ..add('vocabularyExpression', vocabularyExpression)
          ..add('idempotencyKey', idempotencyKey))
        .toString();
  }
}

class GRequestGenerationInputBuilder
    implements
        Builder<GRequestGenerationInput, GRequestGenerationInputBuilder> {
  _$GRequestGenerationInput? _$v;

  String? _vocabularyExpression;
  String? get vocabularyExpression => _$this._vocabularyExpression;
  set vocabularyExpression(String? vocabularyExpression) =>
      _$this._vocabularyExpression = vocabularyExpression;

  String? _idempotencyKey;
  String? get idempotencyKey => _$this._idempotencyKey;
  set idempotencyKey(String? idempotencyKey) =>
      _$this._idempotencyKey = idempotencyKey;

  GRequestGenerationInputBuilder();

  GRequestGenerationInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _vocabularyExpression = $v.vocabularyExpression;
      _idempotencyKey = $v.idempotencyKey;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRequestGenerationInput other) {
    _$v = other as _$GRequestGenerationInput;
  }

  @override
  void update(void Function(GRequestGenerationInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GRequestGenerationInput build() => _build();

  _$GRequestGenerationInput _build() {
    final _$result =
        _$v ??
        _$GRequestGenerationInput._(
          vocabularyExpression: BuiltValueNullFieldError.checkNotNull(
            vocabularyExpression,
            r'GRequestGenerationInput',
            'vocabularyExpression',
          ),
          idempotencyKey: BuiltValueNullFieldError.checkNotNull(
            idempotencyKey,
            r'GRequestGenerationInput',
            'idempotencyKey',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GRetryGenerationInput extends GRetryGenerationInput {
  @override
  final String vocabularyExpression;
  @override
  final GGenerationTargetKind target;
  @override
  final String idempotencyKey;

  factory _$GRetryGenerationInput([
    void Function(GRetryGenerationInputBuilder)? updates,
  ]) => (GRetryGenerationInputBuilder()..update(updates))._build();

  _$GRetryGenerationInput._({
    required this.vocabularyExpression,
    required this.target,
    required this.idempotencyKey,
  }) : super._();
  @override
  GRetryGenerationInput rebuild(
    void Function(GRetryGenerationInputBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GRetryGenerationInputBuilder toBuilder() =>
      GRetryGenerationInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRetryGenerationInput &&
        vocabularyExpression == other.vocabularyExpression &&
        target == other.target &&
        idempotencyKey == other.idempotencyKey;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, vocabularyExpression.hashCode);
    _$hash = $jc(_$hash, target.hashCode);
    _$hash = $jc(_$hash, idempotencyKey.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GRetryGenerationInput')
          ..add('vocabularyExpression', vocabularyExpression)
          ..add('target', target)
          ..add('idempotencyKey', idempotencyKey))
        .toString();
  }
}

class GRetryGenerationInputBuilder
    implements Builder<GRetryGenerationInput, GRetryGenerationInputBuilder> {
  _$GRetryGenerationInput? _$v;

  String? _vocabularyExpression;
  String? get vocabularyExpression => _$this._vocabularyExpression;
  set vocabularyExpression(String? vocabularyExpression) =>
      _$this._vocabularyExpression = vocabularyExpression;

  GGenerationTargetKind? _target;
  GGenerationTargetKind? get target => _$this._target;
  set target(GGenerationTargetKind? target) => _$this._target = target;

  String? _idempotencyKey;
  String? get idempotencyKey => _$this._idempotencyKey;
  set idempotencyKey(String? idempotencyKey) =>
      _$this._idempotencyKey = idempotencyKey;

  GRetryGenerationInputBuilder();

  GRetryGenerationInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _vocabularyExpression = $v.vocabularyExpression;
      _target = $v.target;
      _idempotencyKey = $v.idempotencyKey;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRetryGenerationInput other) {
    _$v = other as _$GRetryGenerationInput;
  }

  @override
  void update(void Function(GRetryGenerationInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GRetryGenerationInput build() => _build();

  _$GRetryGenerationInput _build() {
    final _$result =
        _$v ??
        _$GRetryGenerationInput._(
          vocabularyExpression: BuiltValueNullFieldError.checkNotNull(
            vocabularyExpression,
            r'GRetryGenerationInput',
            'vocabularyExpression',
          ),
          target: BuiltValueNullFieldError.checkNotNull(
            target,
            r'GRetryGenerationInput',
            'target',
          ),
          idempotencyKey: BuiltValueNullFieldError.checkNotNull(
            idempotencyKey,
            r'GRetryGenerationInput',
            'idempotencyKey',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GRequestPurchaseInput extends GRequestPurchaseInput {
  @override
  final GPlanCode planCode;
  @override
  final String idempotencyKey;

  factory _$GRequestPurchaseInput([
    void Function(GRequestPurchaseInputBuilder)? updates,
  ]) => (GRequestPurchaseInputBuilder()..update(updates))._build();

  _$GRequestPurchaseInput._({
    required this.planCode,
    required this.idempotencyKey,
  }) : super._();
  @override
  GRequestPurchaseInput rebuild(
    void Function(GRequestPurchaseInputBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GRequestPurchaseInputBuilder toBuilder() =>
      GRequestPurchaseInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRequestPurchaseInput &&
        planCode == other.planCode &&
        idempotencyKey == other.idempotencyKey;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, planCode.hashCode);
    _$hash = $jc(_$hash, idempotencyKey.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GRequestPurchaseInput')
          ..add('planCode', planCode)
          ..add('idempotencyKey', idempotencyKey))
        .toString();
  }
}

class GRequestPurchaseInputBuilder
    implements Builder<GRequestPurchaseInput, GRequestPurchaseInputBuilder> {
  _$GRequestPurchaseInput? _$v;

  GPlanCode? _planCode;
  GPlanCode? get planCode => _$this._planCode;
  set planCode(GPlanCode? planCode) => _$this._planCode = planCode;

  String? _idempotencyKey;
  String? get idempotencyKey => _$this._idempotencyKey;
  set idempotencyKey(String? idempotencyKey) =>
      _$this._idempotencyKey = idempotencyKey;

  GRequestPurchaseInputBuilder();

  GRequestPurchaseInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _planCode = $v.planCode;
      _idempotencyKey = $v.idempotencyKey;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRequestPurchaseInput other) {
    _$v = other as _$GRequestPurchaseInput;
  }

  @override
  void update(void Function(GRequestPurchaseInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GRequestPurchaseInput build() => _build();

  _$GRequestPurchaseInput _build() {
    final _$result =
        _$v ??
        _$GRequestPurchaseInput._(
          planCode: BuiltValueNullFieldError.checkNotNull(
            planCode,
            r'GRequestPurchaseInput',
            'planCode',
          ),
          idempotencyKey: BuiltValueNullFieldError.checkNotNull(
            idempotencyKey,
            r'GRequestPurchaseInput',
            'idempotencyKey',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GRequestRestorePurchaseInput extends GRequestRestorePurchaseInput {
  @override
  final String idempotencyKey;

  factory _$GRequestRestorePurchaseInput([
    void Function(GRequestRestorePurchaseInputBuilder)? updates,
  ]) => (GRequestRestorePurchaseInputBuilder()..update(updates))._build();

  _$GRequestRestorePurchaseInput._({required this.idempotencyKey}) : super._();
  @override
  GRequestRestorePurchaseInput rebuild(
    void Function(GRequestRestorePurchaseInputBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GRequestRestorePurchaseInputBuilder toBuilder() =>
      GRequestRestorePurchaseInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRequestRestorePurchaseInput &&
        idempotencyKey == other.idempotencyKey;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, idempotencyKey.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'GRequestRestorePurchaseInput',
    )..add('idempotencyKey', idempotencyKey)).toString();
  }
}

class GRequestRestorePurchaseInputBuilder
    implements
        Builder<
          GRequestRestorePurchaseInput,
          GRequestRestorePurchaseInputBuilder
        > {
  _$GRequestRestorePurchaseInput? _$v;

  String? _idempotencyKey;
  String? get idempotencyKey => _$this._idempotencyKey;
  set idempotencyKey(String? idempotencyKey) =>
      _$this._idempotencyKey = idempotencyKey;

  GRequestRestorePurchaseInputBuilder();

  GRequestRestorePurchaseInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _idempotencyKey = $v.idempotencyKey;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRequestRestorePurchaseInput other) {
    _$v = other as _$GRequestRestorePurchaseInput;
  }

  @override
  void update(void Function(GRequestRestorePurchaseInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GRequestRestorePurchaseInput build() => _build();

  _$GRequestRestorePurchaseInput _build() {
    final _$result =
        _$v ??
        _$GRequestRestorePurchaseInput._(
          idempotencyKey: BuiltValueNullFieldError.checkNotNull(
            idempotencyKey,
            r'GRequestRestorePurchaseInput',
            'idempotencyKey',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
