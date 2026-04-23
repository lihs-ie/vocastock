// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart' show StandardJsonPlugin;
import 'package:ferry_exec/ferry_exec.dart';
import 'package:gql_code_builder_serializers/gql_code_builder_serializers.dart'
    show OperationSerializer;
import 'package:vocastock_mobile/src/infrastructure/graphql/__generated__/schema.schema.gql.dart'
    show
        GAcceptanceOutcome,
        GAuthProvider,
        GCommandErrorCategory,
        GDateTime,
        GEntitlementBundle,
        GExplanationGenerationStatus,
        GFrequencyLevel,
        GGenerationTargetKind,
        GImageGenerationStatus,
        GPlanCode,
        GProficiencyLevel,
        GRegisterVocabularyExpressionInput,
        GRegistrationStatus,
        GRequestGenerationInput,
        GRequestPurchaseInput,
        GRequestRestorePurchaseInput,
        GRetryGenerationInput,
        GSessionStateCode,
        GSophisticationLevel,
        GSubscriptionState,
        GULID;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/actor_handoff.data.gql.dart'
    show
        GActorHandoffStatusQueryData,
        GActorHandoffStatusQueryData_actorHandoffStatus,
        GLearningStateQueryData,
        GLearningStateQueryData_learningState;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/actor_handoff.req.gql.dart'
    show GActorHandoffStatusQueryReq, GLearningStateQueryReq;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/actor_handoff.var.gql.dart'
    show GActorHandoffStatusQueryVars, GLearningStateQueryVars;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/commands.data.gql.dart'
    show
        GRegisterVocabularyExpressionMutationData,
        GRegisterVocabularyExpressionMutationData_registerVocabularyExpression,
        GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message,
        GRequestExplanationGenerationMutationData,
        GRequestExplanationGenerationMutationData_requestExplanationGeneration,
        GRequestExplanationGenerationMutationData_requestExplanationGeneration_message,
        GRequestImageGenerationMutationData,
        GRequestImageGenerationMutationData_requestImageGeneration,
        GRequestImageGenerationMutationData_requestImageGeneration_message,
        GRetryGenerationMutationData,
        GRetryGenerationMutationData_retryGeneration,
        GRetryGenerationMutationData_retryGeneration_message;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/commands.req.gql.dart'
    show
        GRegisterVocabularyExpressionMutationReq,
        GRequestExplanationGenerationMutationReq,
        GRequestImageGenerationMutationReq,
        GRetryGenerationMutationReq;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/commands.var.gql.dart'
    show
        GRegisterVocabularyExpressionMutationVars,
        GRequestExplanationGenerationMutationVars,
        GRequestImageGenerationMutationVars,
        GRetryGenerationMutationVars;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/completed_details.data.gql.dart'
    show
        GExplanationDetailQueryData,
        GExplanationDetailQueryData_explanationDetail,
        GExplanationDetailQueryData_explanationDetail_pronunciation,
        GExplanationDetailQueryData_explanationDetail_senses,
        GExplanationDetailQueryData_explanationDetail_senses_collocations,
        GExplanationDetailQueryData_explanationDetail_senses_examples,
        GExplanationDetailQueryData_explanationDetail_similarities,
        GImageDetailQueryData,
        GImageDetailQueryData_imageDetail;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/completed_details.req.gql.dart'
    show GExplanationDetailQueryReq, GImageDetailQueryReq;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/completed_details.var.gql.dart'
    show GExplanationDetailQueryVars, GImageDetailQueryVars;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/learning_state.data.gql.dart'
    show GLearningStatesQueryData, GLearningStatesQueryData_learningStates;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/learning_state.req.gql.dart'
    show GLearningStatesQueryReq;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/learning_state.var.gql.dart'
    show GLearningStatesQueryVars;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/subscription.data.gql.dart'
    show
        GRequestPurchaseMutationData,
        GRequestPurchaseMutationData_requestPurchase,
        GRequestPurchaseMutationData_requestPurchase_message,
        GRequestRestorePurchaseMutationData,
        GRequestRestorePurchaseMutationData_requestRestorePurchase,
        GRequestRestorePurchaseMutationData_requestRestorePurchase_message,
        GSubscriptionStatusQueryData,
        GSubscriptionStatusQueryData_subscriptionStatus,
        GSubscriptionStatusQueryData_subscriptionStatus_allowance;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/subscription.req.gql.dart'
    show
        GRequestPurchaseMutationReq,
        GRequestRestorePurchaseMutationReq,
        GSubscriptionStatusQueryReq;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/subscription.var.gql.dart'
    show
        GRequestPurchaseMutationVars,
        GRequestRestorePurchaseMutationVars,
        GSubscriptionStatusQueryVars;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/vocabulary_catalog.data.gql.dart'
    show
        GVocabularyCatalogQueryData,
        GVocabularyCatalogQueryData_vocabularyCatalog,
        GVocabularyCatalogQueryData_vocabularyCatalog_entries,
        GVocabularyExpressionDetailQueryData,
        GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/vocabulary_catalog.req.gql.dart'
    show GVocabularyCatalogQueryReq, GVocabularyExpressionDetailQueryReq;
import 'package:vocastock_mobile/src/infrastructure/graphql/operations/__generated__/vocabulary_catalog.var.gql.dart'
    show GVocabularyCatalogQueryVars, GVocabularyExpressionDetailQueryVars;

part 'serializers.gql.g.dart';

final SerializersBuilder _serializersBuilder = _$serializers.toBuilder()
  ..add(OperationSerializer())
  ..addPlugin(StandardJsonPlugin());
@SerializersFor([
  GAcceptanceOutcome,
  GActorHandoffStatusQueryData,
  GActorHandoffStatusQueryData_actorHandoffStatus,
  GActorHandoffStatusQueryReq,
  GActorHandoffStatusQueryVars,
  GAuthProvider,
  GCommandErrorCategory,
  GDateTime,
  GEntitlementBundle,
  GExplanationDetailQueryData,
  GExplanationDetailQueryData_explanationDetail,
  GExplanationDetailQueryData_explanationDetail_pronunciation,
  GExplanationDetailQueryData_explanationDetail_senses,
  GExplanationDetailQueryData_explanationDetail_senses_collocations,
  GExplanationDetailQueryData_explanationDetail_senses_examples,
  GExplanationDetailQueryData_explanationDetail_similarities,
  GExplanationDetailQueryReq,
  GExplanationDetailQueryVars,
  GExplanationGenerationStatus,
  GFrequencyLevel,
  GGenerationTargetKind,
  GImageDetailQueryData,
  GImageDetailQueryData_imageDetail,
  GImageDetailQueryReq,
  GImageDetailQueryVars,
  GImageGenerationStatus,
  GLearningStateQueryData,
  GLearningStateQueryData_learningState,
  GLearningStateQueryReq,
  GLearningStateQueryVars,
  GLearningStatesQueryData,
  GLearningStatesQueryData_learningStates,
  GLearningStatesQueryReq,
  GLearningStatesQueryVars,
  GPlanCode,
  GProficiencyLevel,
  GRegisterVocabularyExpressionInput,
  GRegisterVocabularyExpressionMutationData,
  GRegisterVocabularyExpressionMutationData_registerVocabularyExpression,
  GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message,
  GRegisterVocabularyExpressionMutationReq,
  GRegisterVocabularyExpressionMutationVars,
  GRegistrationStatus,
  GRequestExplanationGenerationMutationData,
  GRequestExplanationGenerationMutationData_requestExplanationGeneration,
  GRequestExplanationGenerationMutationData_requestExplanationGeneration_message,
  GRequestExplanationGenerationMutationReq,
  GRequestExplanationGenerationMutationVars,
  GRequestGenerationInput,
  GRequestImageGenerationMutationData,
  GRequestImageGenerationMutationData_requestImageGeneration,
  GRequestImageGenerationMutationData_requestImageGeneration_message,
  GRequestImageGenerationMutationReq,
  GRequestImageGenerationMutationVars,
  GRequestPurchaseInput,
  GRequestPurchaseMutationData,
  GRequestPurchaseMutationData_requestPurchase,
  GRequestPurchaseMutationData_requestPurchase_message,
  GRequestPurchaseMutationReq,
  GRequestPurchaseMutationVars,
  GRequestRestorePurchaseInput,
  GRequestRestorePurchaseMutationData,
  GRequestRestorePurchaseMutationData_requestRestorePurchase,
  GRequestRestorePurchaseMutationData_requestRestorePurchase_message,
  GRequestRestorePurchaseMutationReq,
  GRequestRestorePurchaseMutationVars,
  GRetryGenerationInput,
  GRetryGenerationMutationData,
  GRetryGenerationMutationData_retryGeneration,
  GRetryGenerationMutationData_retryGeneration_message,
  GRetryGenerationMutationReq,
  GRetryGenerationMutationVars,
  GSessionStateCode,
  GSophisticationLevel,
  GSubscriptionState,
  GSubscriptionStatusQueryData,
  GSubscriptionStatusQueryData_subscriptionStatus,
  GSubscriptionStatusQueryData_subscriptionStatus_allowance,
  GSubscriptionStatusQueryReq,
  GSubscriptionStatusQueryVars,
  GULID,
  GVocabularyCatalogQueryData,
  GVocabularyCatalogQueryData_vocabularyCatalog,
  GVocabularyCatalogQueryData_vocabularyCatalog_entries,
  GVocabularyCatalogQueryReq,
  GVocabularyCatalogQueryVars,
  GVocabularyExpressionDetailQueryData,
  GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail,
  GVocabularyExpressionDetailQueryReq,
  GVocabularyExpressionDetailQueryVars,
])
final Serializers serializers = _serializersBuilder.build();
