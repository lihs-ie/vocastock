use command_api::{
    fingerprint_for, parse_request_explanation_generation, parse_request_image_generation,
    parse_request_purchase, parse_request_restore_purchase, parse_retry_generation, DispatchKind,
    GenerationTargetKind, MutationCommand, MutationRequestError, PlanCode,
};

use crate::support::active_actor;

#[test]
fn parse_request_explanation_generation_accepts_matching_actor() {
    let body = "{\"actor\":\"actor:learner\",\"idempotencyKey\":\"k1\",\"vocabularyExpression\":\"vocabulary:run\"}";
    let command =
        parse_request_explanation_generation(body, &active_actor()).expect("valid request");
    assert_eq!(command.idempotency_key, "k1");
    assert_eq!(command.vocabulary_expression, "vocabulary:run");
    let dispatch = command.dispatch_request();
    assert_eq!(dispatch.kind, DispatchKind::ExplanationGeneration);
    assert_eq!(dispatch.target_vocabulary_expression, "vocabulary:run");
}

#[test]
fn parse_request_explanation_generation_rejects_ownership_mismatch() {
    let body = "{\"actor\":\"actor:other\",\"idempotencyKey\":\"k1\",\"vocabularyExpression\":\"vocabulary:run\"}";
    let error =
        parse_request_explanation_generation(body, &active_actor()).expect_err("mismatch rejected");
    assert_eq!(error, MutationRequestError::OwnershipMismatch);
}

#[test]
fn parse_request_explanation_generation_rejects_missing_fields() {
    assert_eq!(
        parse_request_explanation_generation("{}", &active_actor()).unwrap_err(),
        MutationRequestError::InvalidJson,
    );
    let missing_actor = "{\"actor\":\"\",\"idempotencyKey\":\"k\",\"vocabularyExpression\":\"v\"}";
    assert_eq!(
        parse_request_explanation_generation(missing_actor, &active_actor()).unwrap_err(),
        MutationRequestError::MissingActor,
    );
    let missing_key =
        "{\"actor\":\"actor:learner\",\"idempotencyKey\":\" \",\"vocabularyExpression\":\"v\"}";
    assert_eq!(
        parse_request_explanation_generation(missing_key, &active_actor()).unwrap_err(),
        MutationRequestError::MissingIdempotencyKey,
    );
    let missing_vocab =
        "{\"actor\":\"actor:learner\",\"idempotencyKey\":\"k\",\"vocabularyExpression\":\"\"}";
    assert_eq!(
        parse_request_explanation_generation(missing_vocab, &active_actor()).unwrap_err(),
        MutationRequestError::MissingVocabularyExpression,
    );
}

#[test]
fn parse_request_image_generation_builds_image_kind_dispatch() {
    let body = "{\"actor\":\"actor:learner\",\"idempotencyKey\":\"k2\",\"vocabularyExpression\":\"vocabulary:tea\"}";
    let command = parse_request_image_generation(body, &active_actor()).expect("valid request");
    assert_eq!(
        command.dispatch_request().kind,
        DispatchKind::ImageGeneration
    );
    assert!(command.sense_identifier.is_none());
    assert!(command.dispatch_request().sense_identifier.is_none());
}

#[test]
fn parse_request_image_generation_accepts_optional_sense_identifier() {
    let body = "{\"actor\":\"actor:learner\",\"idempotencyKey\":\"k2-sense\",\"vocabularyExpression\":\"vocabulary:tea\",\"senseIdentifier\":\"sense-001\"}";
    let command = parse_request_image_generation(body, &active_actor()).expect("valid request");
    assert_eq!(command.sense_identifier.as_deref(), Some("sense-001"));
    assert_eq!(
        command.dispatch_request().sense_identifier.as_deref(),
        Some("sense-001"),
    );
}

#[test]
fn parse_request_image_generation_treats_empty_sense_identifier_as_none() {
    let body = "{\"actor\":\"actor:learner\",\"idempotencyKey\":\"k2-empty\",\"vocabularyExpression\":\"vocabulary:tea\",\"senseIdentifier\":\"\"}";
    let command = parse_request_image_generation(body, &active_actor()).expect("valid request");
    assert!(command.sense_identifier.is_none());
    assert!(command.dispatch_request().sense_identifier.is_none());
}

#[test]
fn parse_request_image_generation_trims_whitespace_only_sense_identifier_to_none() {
    let body = "{\"actor\":\"actor:learner\",\"idempotencyKey\":\"k2-ws\",\"vocabularyExpression\":\"vocabulary:tea\",\"senseIdentifier\":\"   \"}";
    let command = parse_request_image_generation(body, &active_actor()).expect("valid request");
    assert!(command.sense_identifier.is_none());
}

#[test]
fn parse_retry_generation_preserves_target_and_marks_retry_kind() {
    let body = "{\"actor\":\"actor:learner\",\"idempotencyKey\":\"k3\",\"vocabularyExpression\":\"vocabulary:run\",\"target\":\"EXPLANATION\"}";
    let command = parse_retry_generation(body, &active_actor()).expect("valid retry");
    assert_eq!(command.target, GenerationTargetKind::Explanation);
    let dispatch = command.dispatch_request();
    assert_eq!(dispatch.kind, DispatchKind::Retry);
    assert_eq!(dispatch.retry_target.as_deref(), Some("EXPLANATION"));
    assert!(dispatch.restart_requested);
}

#[test]
fn parse_retry_generation_rejects_unknown_target() {
    let body = "{\"actor\":\"actor:learner\",\"idempotencyKey\":\"k\",\"vocabularyExpression\":\"v\",\"target\":\"VIDEO\"}";
    let error = parse_retry_generation(body, &active_actor()).expect_err("bad target");
    assert_eq!(error, MutationRequestError::InvalidGenerationTarget);
}

#[test]
fn parse_request_purchase_resolves_plan_code_enum() {
    let body =
        "{\"actor\":\"actor:learner\",\"idempotencyKey\":\"k4\",\"planCode\":\"STANDARD_MONTHLY\"}";
    let command = parse_request_purchase(body, &active_actor()).expect("valid purchase");
    assert_eq!(command.plan_code, PlanCode::StandardMonthly);
    let dispatch = command.dispatch_request();
    assert_eq!(dispatch.kind, DispatchKind::Purchase);
    assert_eq!(dispatch.plan_code.as_deref(), Some("STANDARD_MONTHLY"));
}

#[test]
fn parse_request_purchase_rejects_empty_or_unknown_plan() {
    let empty = "{\"actor\":\"actor:learner\",\"idempotencyKey\":\"k\",\"planCode\":\"\"}";
    assert_eq!(
        parse_request_purchase(empty, &active_actor()).unwrap_err(),
        MutationRequestError::MissingPlanCode,
    );
    let unknown =
        "{\"actor\":\"actor:learner\",\"idempotencyKey\":\"k\",\"planCode\":\"PLATINUM\"}";
    assert_eq!(
        parse_request_purchase(unknown, &active_actor()).unwrap_err(),
        MutationRequestError::InvalidPlanCode,
    );
}

#[test]
fn parse_request_restore_purchase_requires_actor_and_key_only() {
    let body = "{\"actor\":\"actor:learner\",\"idempotencyKey\":\"k5\"}";
    let command = parse_request_restore_purchase(body, &active_actor()).expect("valid restore");
    assert_eq!(
        command.dispatch_request().kind,
        DispatchKind::RestorePurchase
    );
}

#[test]
fn fingerprint_for_differs_across_commands() {
    let explanation = parse_request_explanation_generation(
        "{\"actor\":\"actor:learner\",\"idempotencyKey\":\"k\",\"vocabularyExpression\":\"v\"}",
        &active_actor(),
    )
    .unwrap();
    let image = parse_request_image_generation(
        "{\"actor\":\"actor:learner\",\"idempotencyKey\":\"k\",\"vocabularyExpression\":\"v\"}",
        &active_actor(),
    )
    .unwrap();

    let fp_explanation = fingerprint_for(&explanation);
    let fp_image = fingerprint_for(&image);

    assert_ne!(fp_explanation.command_name, fp_image.command_name);
    // Same payload_hash because both hash `vocab=v`; the command_name is what
    // distinguishes replays.
    assert_eq!(fp_explanation.payload_hash, fp_image.payload_hash);
}
