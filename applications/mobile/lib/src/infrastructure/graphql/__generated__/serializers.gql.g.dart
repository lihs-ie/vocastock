// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializers.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializers _$serializers =
    (Serializers().toBuilder()
          ..add(FetchPolicy.serializer)
          ..add(GAcceptanceOutcome.serializer)
          ..add(GActorHandoffStatusQueryData.serializer)
          ..add(GActorHandoffStatusQueryData_actorHandoffStatus.serializer)
          ..add(GActorHandoffStatusQueryReq.serializer)
          ..add(GActorHandoffStatusQueryVars.serializer)
          ..add(GAuthProvider.serializer)
          ..add(GCommandErrorCategory.serializer)
          ..add(GDateTime.serializer)
          ..add(GEntitlementBundle.serializer)
          ..add(GExplanationDetailQueryData.serializer)
          ..add(GExplanationDetailQueryData_explanationDetail.serializer)
          ..add(
            GExplanationDetailQueryData_explanationDetail_pronunciation
                .serializer,
          )
          ..add(GExplanationDetailQueryData_explanationDetail_senses.serializer)
          ..add(
            GExplanationDetailQueryData_explanationDetail_senses_collocations
                .serializer,
          )
          ..add(
            GExplanationDetailQueryData_explanationDetail_senses_examples
                .serializer,
          )
          ..add(
            GExplanationDetailQueryData_explanationDetail_similarities
                .serializer,
          )
          ..add(GExplanationDetailQueryReq.serializer)
          ..add(GExplanationDetailQueryVars.serializer)
          ..add(GExplanationGenerationStatus.serializer)
          ..add(GFrequencyLevel.serializer)
          ..add(GGenerationTargetKind.serializer)
          ..add(GImageDetailQueryData.serializer)
          ..add(GImageDetailQueryData_imageDetail.serializer)
          ..add(GImageDetailQueryReq.serializer)
          ..add(GImageDetailQueryVars.serializer)
          ..add(GImageGenerationStatus.serializer)
          ..add(GLearningStateQueryData.serializer)
          ..add(GLearningStateQueryData_learningState.serializer)
          ..add(GLearningStateQueryReq.serializer)
          ..add(GLearningStateQueryVars.serializer)
          ..add(GPlanCode.serializer)
          ..add(GProficiencyLevel.serializer)
          ..add(GRegisterVocabularyExpressionInput.serializer)
          ..add(GRegisterVocabularyExpressionMutationData.serializer)
          ..add(
            GRegisterVocabularyExpressionMutationData_registerVocabularyExpression
                .serializer,
          )
          ..add(
            GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message
                .serializer,
          )
          ..add(GRegisterVocabularyExpressionMutationReq.serializer)
          ..add(GRegisterVocabularyExpressionMutationVars.serializer)
          ..add(GRegistrationStatus.serializer)
          ..add(GRequestExplanationGenerationMutationData.serializer)
          ..add(
            GRequestExplanationGenerationMutationData_requestExplanationGeneration
                .serializer,
          )
          ..add(
            GRequestExplanationGenerationMutationData_requestExplanationGeneration_message
                .serializer,
          )
          ..add(GRequestExplanationGenerationMutationReq.serializer)
          ..add(GRequestExplanationGenerationMutationVars.serializer)
          ..add(GRequestGenerationInput.serializer)
          ..add(GRequestImageGenerationMutationData.serializer)
          ..add(
            GRequestImageGenerationMutationData_requestImageGeneration
                .serializer,
          )
          ..add(
            GRequestImageGenerationMutationData_requestImageGeneration_message
                .serializer,
          )
          ..add(GRequestImageGenerationMutationReq.serializer)
          ..add(GRequestImageGenerationMutationVars.serializer)
          ..add(GRequestPurchaseInput.serializer)
          ..add(GRequestPurchaseMutationData.serializer)
          ..add(GRequestPurchaseMutationData_requestPurchase.serializer)
          ..add(GRequestPurchaseMutationData_requestPurchase_message.serializer)
          ..add(GRequestPurchaseMutationReq.serializer)
          ..add(GRequestPurchaseMutationVars.serializer)
          ..add(GRequestRestorePurchaseInput.serializer)
          ..add(GRequestRestorePurchaseMutationData.serializer)
          ..add(
            GRequestRestorePurchaseMutationData_requestRestorePurchase
                .serializer,
          )
          ..add(
            GRequestRestorePurchaseMutationData_requestRestorePurchase_message
                .serializer,
          )
          ..add(GRequestRestorePurchaseMutationReq.serializer)
          ..add(GRequestRestorePurchaseMutationVars.serializer)
          ..add(GRetryGenerationInput.serializer)
          ..add(GRetryGenerationMutationData.serializer)
          ..add(GRetryGenerationMutationData_retryGeneration.serializer)
          ..add(GRetryGenerationMutationData_retryGeneration_message.serializer)
          ..add(GRetryGenerationMutationReq.serializer)
          ..add(GRetryGenerationMutationVars.serializer)
          ..add(GSessionStateCode.serializer)
          ..add(GSophisticationLevel.serializer)
          ..add(GSubscriptionState.serializer)
          ..add(GSubscriptionStatusQueryData.serializer)
          ..add(GSubscriptionStatusQueryData_subscriptionStatus.serializer)
          ..add(
            GSubscriptionStatusQueryData_subscriptionStatus_allowance
                .serializer,
          )
          ..add(GSubscriptionStatusQueryReq.serializer)
          ..add(GSubscriptionStatusQueryVars.serializer)
          ..add(GULID.serializer)
          ..add(GVocabularyCatalogQueryData.serializer)
          ..add(GVocabularyCatalogQueryData_vocabularyCatalog.serializer)
          ..add(
            GVocabularyCatalogQueryData_vocabularyCatalog_entries.serializer,
          )
          ..add(GVocabularyCatalogQueryReq.serializer)
          ..add(GVocabularyCatalogQueryVars.serializer)
          ..add(GVocabularyExpressionDetailQueryData.serializer)
          ..add(
            GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail
                .serializer,
          )
          ..add(GVocabularyExpressionDetailQueryReq.serializer)
          ..add(GVocabularyExpressionDetailQueryVars.serializer)
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(
                GExplanationDetailQueryData_explanationDetail_senses_examples,
              ),
            ]),
            () =>
                ListBuilder<
                  GExplanationDetailQueryData_explanationDetail_senses_examples
                >(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(
                GExplanationDetailQueryData_explanationDetail_senses_collocations,
              ),
            ]),
            () =>
                ListBuilder<
                  GExplanationDetailQueryData_explanationDetail_senses_collocations
                >(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(
                GExplanationDetailQueryData_explanationDetail_similarities,
              ),
            ]),
            () =>
                ListBuilder<
                  GExplanationDetailQueryData_explanationDetail_similarities
                >(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(
                GExplanationDetailQueryData_explanationDetail_senses,
              ),
            ]),
            () =>
                ListBuilder<
                  GExplanationDetailQueryData_explanationDetail_senses
                >(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(
                GVocabularyCatalogQueryData_vocabularyCatalog_entries,
              ),
            ]),
            () =>
                ListBuilder<
                  GVocabularyCatalogQueryData_vocabularyCatalog_entries
                >(),
          ))
        .build();

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
