// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:vocastock_mobile/src/infrastructure/graphql/__generated__/schema.schema.gql.dart'
    as _i2;
import 'package:vocastock_mobile/src/infrastructure/graphql/__generated__/serializers.gql.dart'
    as _i1;

part 'actor_handoff.data.gql.g.dart';

abstract class GActorHandoffStatusQueryData
    implements
        Built<GActorHandoffStatusQueryData,
            GActorHandoffStatusQueryDataBuilder> {
  GActorHandoffStatusQueryData._();

  factory GActorHandoffStatusQueryData(
          [void Function(GActorHandoffStatusQueryDataBuilder b) updates]) =
      _$GActorHandoffStatusQueryData;

  static void _initializeBuilder(GActorHandoffStatusQueryDataBuilder b) =>
      b..G__typename = 'Query';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GActorHandoffStatusQueryData_actorHandoffStatus get actorHandoffStatus;
  static Serializer<GActorHandoffStatusQueryData> get serializer =>
      _$gActorHandoffStatusQueryDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GActorHandoffStatusQueryData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GActorHandoffStatusQueryData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GActorHandoffStatusQueryData.serializer,
        json,
      );
}

abstract class GActorHandoffStatusQueryData_actorHandoffStatus
    implements
        Built<GActorHandoffStatusQueryData_actorHandoffStatus,
            GActorHandoffStatusQueryData_actorHandoffStatusBuilder> {
  GActorHandoffStatusQueryData_actorHandoffStatus._();

  factory GActorHandoffStatusQueryData_actorHandoffStatus(
      [void Function(GActorHandoffStatusQueryData_actorHandoffStatusBuilder b)
          updates]) = _$GActorHandoffStatusQueryData_actorHandoffStatus;

  static void _initializeBuilder(
          GActorHandoffStatusQueryData_actorHandoffStatusBuilder b) =>
      b..G__typename = 'ActorHandoffStatus';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String? get actor;
  String? get session;
  String? get authAccount;
  _i2.GSessionStateCode get sessionState;
  static Serializer<GActorHandoffStatusQueryData_actorHandoffStatus>
      get serializer =>
          _$gActorHandoffStatusQueryDataActorHandoffStatusSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GActorHandoffStatusQueryData_actorHandoffStatus.serializer,
        this,
      ) as Map<String, dynamic>);

  static GActorHandoffStatusQueryData_actorHandoffStatus? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GActorHandoffStatusQueryData_actorHandoffStatus.serializer,
        json,
      );
}

abstract class GLearningStateQueryData
    implements Built<GLearningStateQueryData, GLearningStateQueryDataBuilder> {
  GLearningStateQueryData._();

  factory GLearningStateQueryData(
          [void Function(GLearningStateQueryDataBuilder b) updates]) =
      _$GLearningStateQueryData;

  static void _initializeBuilder(GLearningStateQueryDataBuilder b) =>
      b..G__typename = 'Query';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GLearningStateQueryData_learningState? get learningState;
  static Serializer<GLearningStateQueryData> get serializer =>
      _$gLearningStateQueryDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GLearningStateQueryData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GLearningStateQueryData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GLearningStateQueryData.serializer,
        json,
      );
}

abstract class GLearningStateQueryData_learningState
    implements
        Built<GLearningStateQueryData_learningState,
            GLearningStateQueryData_learningStateBuilder> {
  GLearningStateQueryData_learningState._();

  factory GLearningStateQueryData_learningState(
      [void Function(GLearningStateQueryData_learningStateBuilder b)
          updates]) = _$GLearningStateQueryData_learningState;

  static void _initializeBuilder(
          GLearningStateQueryData_learningStateBuilder b) =>
      b..G__typename = 'LearningState';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get vocabularyExpression;
  _i2.GProficiencyLevel get proficiency;
  static Serializer<GLearningStateQueryData_learningState> get serializer =>
      _$gLearningStateQueryDataLearningStateSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GLearningStateQueryData_learningState.serializer,
        this,
      ) as Map<String, dynamic>);

  static GLearningStateQueryData_learningState? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GLearningStateQueryData_learningState.serializer,
        json,
      );
}
