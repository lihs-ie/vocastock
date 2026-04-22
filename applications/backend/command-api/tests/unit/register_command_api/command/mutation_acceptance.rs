use command_api::{
    accept_mutation_command, fingerprint_for, parse_request_explanation_generation,
    success_envelope, AcceptanceOutcomeCode, CommandErrorCategory, UserFacingMessage,
};

use crate::support::{active_actor, DispatchPortTestDouble, MutationCommandStoreTestDouble};

#[test]
fn fresh_command_dispatches_and_commits() {
    let store = MutationCommandStoreTestDouble::default();
    let dispatcher = DispatchPortTestDouble::accepting();
    let command = parse_request_explanation_generation(
        "{\"actor\":\"actor:learner\",\"idempotencyKey\":\"k1\",\"vocabularyExpression\":\"vocabulary:run\"}",
        &active_actor(),
    )
    .unwrap();

    let envelope = accept_mutation_command(&command, &store, &dispatcher);

    assert!(envelope.accepted);
    assert_eq!(envelope.outcome, Some(AcceptanceOutcomeCode::Accepted));
    assert_eq!(
        envelope.message.key,
        "command.explanation_generation_queued"
    );
    assert_eq!(dispatcher.dispatched().len(), 1);
    assert_eq!(store.commits().len(), 1);
}

#[test]
fn dispatch_failure_reports_dispatch_failed_without_commit() {
    let store = MutationCommandStoreTestDouble::default();
    let dispatcher = DispatchPortTestDouble::failing();
    let command = parse_request_explanation_generation(
        "{\"actor\":\"actor:learner\",\"idempotencyKey\":\"k2\",\"vocabularyExpression\":\"vocabulary:run\"}",
        &active_actor(),
    )
    .unwrap();

    let envelope = accept_mutation_command(&command, &store, &dispatcher);

    assert!(!envelope.accepted);
    assert_eq!(
        envelope.error_category,
        Some(CommandErrorCategory::DispatchFailed)
    );
    assert_eq!(envelope.message.key, "command.dispatch_failed");
    assert_eq!(dispatcher.dispatched().len(), 1);
    assert!(
        store.commits().is_empty(),
        "dispatch failure must not commit an idempotency record"
    );
}

#[test]
fn matching_replay_returns_stored_envelope_without_dispatch() {
    let command = parse_request_explanation_generation(
        "{\"actor\":\"actor:learner\",\"idempotencyKey\":\"k3\",\"vocabularyExpression\":\"vocabulary:run\"}",
        &active_actor(),
    )
    .unwrap();
    let stored = success_envelope(&command);
    let store = MutationCommandStoreTestDouble::with_existing(
        "actor:learner",
        "k3",
        fingerprint_for(&command),
        stored.clone(),
    );
    let dispatcher = DispatchPortTestDouble::accepting();

    let envelope = accept_mutation_command(&command, &store, &dispatcher);

    assert_eq!(envelope, stored);
    assert!(
        dispatcher.dispatched().is_empty(),
        "replay must not re-dispatch downstream"
    );
}

#[test]
fn conflicting_fingerprint_returns_validation_failed() {
    let command = parse_request_explanation_generation(
        "{\"actor\":\"actor:learner\",\"idempotencyKey\":\"k4\",\"vocabularyExpression\":\"vocabulary:run\"}",
        &active_actor(),
    )
    .unwrap();
    let conflicting_envelope = command_api::CommandResponseEnvelope::accepted(
        AcceptanceOutcomeCode::Accepted,
        UserFacingMessage::new("command.explanation_generation_queued", "accepted"),
    );
    // Store the envelope against a different fingerprint to simulate a
    // previously committed request with the same key but diverging payload.
    let store = MutationCommandStoreTestDouble::with_existing(
        "actor:learner",
        "k4",
        command_api::MutationFingerprint::new(
            "requestExplanationGeneration",
            "vocab=vocabulary:other",
        ),
        conflicting_envelope,
    );
    let dispatcher = DispatchPortTestDouble::accepting();

    let envelope = accept_mutation_command(&command, &store, &dispatcher);

    assert!(!envelope.accepted);
    assert_eq!(
        envelope.error_category,
        Some(CommandErrorCategory::ValidationFailed)
    );
    assert_eq!(envelope.message.key, "command.idempotency_conflict");
    assert!(dispatcher.dispatched().is_empty());
}
