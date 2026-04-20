use command_api::{
    accept_register_command, InMemoryCommandStore, InMemoryDispatchPort,
    EXPLANATION_STATE_NOT_STARTED, EXPLANATION_STATE_QUEUED,
};

use crate::support::{active_actor, command};

#[test]
fn accept_new_command_commits_registration_and_dispatches_when_requested() {
    let actor = active_actor();
    let store = InMemoryCommandStore::default();
    let dispatcher = InMemoryDispatchPort::default();
    let request = command(&actor, "req-accepted", "fresh term", true);

    let result =
        accept_register_command(&request, &store, &dispatcher).expect("command should be accepted");

    assert_eq!(result.acceptance, "accepted");
    assert_eq!(result.state.registration, "registered");
    assert_eq!(result.state.explanation, EXPLANATION_STATE_QUEUED);
    assert_eq!(dispatcher.recorded_requests().len(), 1);
    assert_eq!(
        store
            .registration_for("actor:learner", "fresh term")
            .expect("registration should be committed")
            .explanation_state,
        EXPLANATION_STATE_QUEUED
    );
}

#[test]
fn accept_new_command_can_skip_dispatch() {
    let actor = active_actor();
    let store = InMemoryCommandStore::default();
    let dispatcher = InMemoryDispatchPort::default();
    let request = command(&actor, "req-no-dispatch", "silent term", false);

    let result =
        accept_register_command(&request, &store, &dispatcher).expect("command should be accepted");

    assert_eq!(result.acceptance, "accepted");
    assert_eq!(result.state.explanation, EXPLANATION_STATE_NOT_STARTED);
    assert!(result.message.contains("without explanation dispatch"));
    assert!(!result.message.contains("/commands/"));
    assert!(dispatcher.recorded_requests().is_empty());
}

#[test]
fn accept_new_command_uses_human_readable_message() {
    let actor = active_actor();
    let store = InMemoryCommandStore::default();
    let dispatcher = InMemoryDispatchPort::default();
    let request = command(&actor, "req-message", "spoken term", true);

    let result =
        accept_register_command(&request, &store, &dispatcher).expect("command should be accepted");

    assert_eq!(
        result.message,
        "registration accepted and queued for explanation dispatch"
    );
    assert!(!result
        .message
        .contains("/commands/register-vocabulary-expression"));
}

#[test]
fn same_request_replays_without_new_dispatch() {
    let actor = active_actor();
    let store = InMemoryCommandStore::default();
    let dispatcher = InMemoryDispatchPort::default();
    let request = command(&actor, "req-replay", "coffee", true);

    let first =
        accept_register_command(&request, &store, &dispatcher).expect("first command succeeds");
    let replay =
        accept_register_command(&request, &store, &dispatcher).expect("replay should succeed");

    assert!(!first.replayed_by_idempotency);
    assert!(replay.replayed_by_idempotency);
    assert_eq!(dispatcher.recorded_requests().len(), 1);
}

#[test]
fn same_key_different_request_returns_conflict() {
    let actor = active_actor();
    let store = InMemoryCommandStore::default();
    let dispatcher = InMemoryDispatchPort::default();

    let accepted = command(&actor, "req-conflict", "coffee", true);
    accept_register_command(&accepted, &store, &dispatcher).expect("first command succeeds");

    let conflicting = command(&actor, "req-conflict", "tea", true);
    let error = accept_register_command(&conflicting, &store, &dispatcher)
        .expect_err("same key with different request must fail");

    assert_eq!(error.code, "idempotency-conflict");
    assert_eq!(dispatcher.recorded_requests().len(), 1);
}

#[test]
fn duplicate_registration_reuses_existing_and_can_restart() {
    let actor = active_actor();
    let store = InMemoryCommandStore::default();
    let dispatcher = InMemoryDispatchPort::default();

    let first = command(&actor, "req-first", "restartable term", false);
    accept_register_command(&first, &store, &dispatcher).expect("initial command succeeds");

    let duplicate = command(&actor, "req-second", "restartable term", true);
    let result =
        accept_register_command(&duplicate, &store, &dispatcher).expect("duplicate should reuse");

    assert_eq!(result.acceptance, "reused-existing");
    assert_eq!(result.state.explanation, EXPLANATION_STATE_QUEUED);
    assert_eq!(
        result
            .duplicate_reuse
            .expect("duplicate reuse details should be present")
            .restart_decision,
        "restart-accepted"
    );
    assert_eq!(dispatcher.recorded_requests().len(), 1);
}

#[test]
fn duplicate_registration_with_false_suppresses_restart() {
    let actor = active_actor();
    let store = InMemoryCommandStore::default();
    let dispatcher = InMemoryDispatchPort::default();

    let first = command(&actor, "req-first", "queued term", true);
    accept_register_command(&first, &store, &dispatcher).expect("initial command succeeds");

    let duplicate = command(&actor, "req-second", "queued term", false);
    let result =
        accept_register_command(&duplicate, &store, &dispatcher).expect("duplicate should reuse");

    assert_eq!(result.acceptance, "reused-existing");
    assert_eq!(result.state.explanation, EXPLANATION_STATE_QUEUED);
    assert_eq!(
        result
            .duplicate_reuse
            .expect("duplicate reuse details should be present")
            .restart_decision,
        "restart-suppressed"
    );
    assert_eq!(dispatcher.recorded_requests().len(), 1);
}

#[test]
fn dispatch_failure_does_not_commit_registration_or_idempotency() {
    let actor = active_actor();
    let store = InMemoryCommandStore::default();
    let dispatcher = InMemoryDispatchPort::default();
    let request = command(&actor, "dispatch-fail-001", "rollback term", true);

    let error = accept_register_command(&request, &store, &dispatcher)
        .expect_err("dispatch marker should fail");

    assert_eq!(error.code, "dispatch-failed");
    assert!(store
        .registration_for("actor:learner", "rollback term")
        .is_none());
    assert!(store
        .idempotency_result_for("actor:learner", "dispatch-fail-001")
        .is_none());
    assert_eq!(dispatcher.recorded_requests().len(), 1);
}
