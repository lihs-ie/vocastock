// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:vocastock_mobile/src/infrastructure/graphql/__generated__/schema.schema.gql.dart'
    as _i2;
import 'package:vocastock_mobile/src/infrastructure/graphql/__generated__/serializers.gql.dart'
    as _i1;

part 'learning_state.data.gql.g.dart';

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

abstract class GLearningStatesQueryData
    implements
        Built<GLearningStatesQueryData, GLearningStatesQueryDataBuilder> {
  GLearningStatesQueryData._();

  factory GLearningStatesQueryData(
          [void Function(GLearningStatesQueryDataBuilder b) updates]) =
      _$GLearningStatesQueryData;

  static void _initializeBuilder(GLearningStatesQueryDataBuilder b) =>
      b..G__typename = 'Query';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  BuiltList<GLearningStatesQueryData_learningStates> get learningStates;
  static Serializer<GLearningStatesQueryData> get serializer =>
      _$gLearningStatesQueryDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GLearningStatesQueryData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GLearningStatesQueryData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GLearningStatesQueryData.serializer,
        json,
      );
}

abstract class GLearningStatesQueryData_learningStates
    implements
        Built<GLearningStatesQueryData_learningStates,
            GLearningStatesQueryData_learningStatesBuilder> {
  GLearningStatesQueryData_learningStates._();

  factory GLearningStatesQueryData_learningStates(
      [void Function(GLearningStatesQueryData_learningStatesBuilder b)
          updates]) = _$GLearningStatesQueryData_learningStates;

  static void _initializeBuilder(
          GLearningStatesQueryData_learningStatesBuilder b) =>
      b..G__typename = 'LearningState';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get vocabularyExpression;
  _i2.GProficiencyLevel get proficiency;
  static Serializer<GLearningStatesQueryData_learningStates> get serializer =>
      _$gLearningStatesQueryDataLearningStatesSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GLearningStatesQueryData_learningStates.serializer,
        this,
      ) as Map<String, dynamic>);

  static GLearningStatesQueryData_learningStates? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GLearningStatesQueryData_learningStates.serializer,
        json,
      );
}
