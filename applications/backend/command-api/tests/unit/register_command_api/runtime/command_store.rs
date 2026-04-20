use command_api::{
    AcceptanceOutcome, AcceptedCommandFields, AcceptedCommandResult, InMemoryCommandStore,
    StateSummary, StoreDecision, TargetReference, EXPLANATION_STATE_NOT_STARTED,
    EXPLANATION_STATE_QUEUED,
};

use crate::support::{active_actor, command, other_actor};

#[test]
fn new_registration_plan_uses_normalized_text_and_dispatch_rule() {
    let actor = active_actor();
    let store = InMemoryCommandStore::default();

    let with_dispatch = store.plan(&command(&actor, "req-1", "coffee", true));
    let without_dispatch = store.plan(&command(&actor, "req-2", "tea", false));

    match with_dispatch {
        StoreDecision::AcceptNew(plan) => {
            assert_eq!(plan.vocabulary_expression, "vocabulary:coffee");
            assert_eq!(plan.explanation_state, EXPLANATION_STATE_QUEUED);
            assert!(plan.dispatch_required);
        }
        other => panic!("unexpected decision: {:?}", other),
    }

    match without_dispatch {
        StoreDecision::AcceptNew(plan) => {
            assert_eq!(plan.vocabulary_expression, "vocabulary:tea");
            assert_eq!(plan.explanation_state, EXPLANATION_STATE_NOT_STARTED);
            assert!(!plan.dispatch_required);
        }
        other => panic!("unexpected decision: {:?}", other),
    }
}

#[test]
fn commit_and_replay_are_actor_scoped() {
    let actor = active_actor();
    let store = InMemoryCommandStore::default();
    let accepted_command = command(&actor, "req-scope", "coffee", true);
    let result = AcceptedCommandResult::new(
        AcceptanceOutcome::Accepted,
        AcceptedCommandFields {
            target: TargetReference {
                vocabulary_expression: "vocabulary:coffee".to_owned(),
            },
            state: StateSummary {
                registration: "registered".to_owned(),
                explanation: EXPLANATION_STATE_QUEUED.to_owned(),
            },
            status_handle: "status:actor:learner:vocabulary:coffee".to_owned(),
            message: "accepted".to_owned(),
            replayed_by_idempotency: false,
            duplicate_reuse: None,
        },
    );

    let plan = match store.plan(&accepted_command) {
        StoreDecision::AcceptNew(plan) => plan,
        other => panic!("unexpected decision: {:?}", other),
    };
    store.commit_new(&accepted_command, &plan, &result);

    let replay = store.plan(&accepted_command);
    let other_actor_request = command(&other_actor(), "req-scope", "coffee", true);
    let other_actor_plan = store.plan(&other_actor_request);

    match replay {
        StoreDecision::ReplayExisting(replayed) => {
            assert_eq!(replayed.acceptance, "accepted");
        }
        other => panic!("unexpected replay decision: {:?}", other),
    }

    match other_actor_plan {
        StoreDecision::AcceptNew(_) => {}
        other => panic!("actor scope should isolate idempotency, got {:?}", other),
    }
}

#[test]
fn same_key_different_request_conflicts() {
    let actor = active_actor();
    let store = InMemoryCommandStore::default();
    let initial = command(&actor, "req-conflict", "coffee", true);
    let result = AcceptedCommandResult::new(
        AcceptanceOutcome::Accepted,
        AcceptedCommandFields {
            target: TargetReference {
                vocabulary_expression: "vocabulary:coffee".to_owned(),
            },
            state: StateSummary {
                registration: "registered".to_owned(),
                explanation: EXPLANATION_STATE_QUEUED.to_owned(),
            },
            status_handle: "status:actor:learner:vocabulary:coffee".to_owned(),
            message: "accepted".to_owned(),
            replayed_by_idempotency: false,
            duplicate_reuse: None,
        },
    );
    let plan = match store.plan(&initial) {
        StoreDecision::AcceptNew(plan) => plan,
        other => panic!("unexpected decision: {:?}", other),
    };
    store.commit_new(&initial, &plan, &result);

    let conflict = store.plan(&command(&actor, "req-conflict", "tea", true));
    assert!(matches!(conflict, StoreDecision::Conflict));
}

#[test]
fn duplicate_reuse_restart_matrix_matches_contract() {
    let actor = active_actor();
    let store = InMemoryCommandStore::default();

    let silent = command(&actor, "req-silent", "restartable", false);
    let silent_result = AcceptedCommandResult::new(
        AcceptanceOutcome::Accepted,
        AcceptedCommandFields {
            target: TargetReference {
                vocabulary_expression: "vocabulary:restartable".to_owned(),
            },
            state: StateSummary {
                registration: "registered".to_owned(),
                explanation: EXPLANATION_STATE_NOT_STARTED.to_owned(),
            },
            status_handle: "status:actor:learner:vocabulary:restartable".to_owned(),
            message: "accepted".to_owned(),
            replayed_by_idempotency: false,
            duplicate_reuse: None,
        },
    );
    let silent_plan = match store.plan(&silent) {
        StoreDecision::AcceptNew(plan) => plan,
        other => panic!("unexpected decision: {:?}", other),
    };
    store.commit_new(&silent, &silent_plan, &silent_result);

    let restart = store.plan(&command(&actor, "req-restart", "restartable", true));
    match restart {
        StoreDecision::ReuseExisting(plan) => {
            assert!(plan.dispatch_required);
            assert_eq!(plan.resulting_explanation_state, EXPLANATION_STATE_QUEUED);
            assert_eq!(plan.duplicate_reuse.restart_decision, "restart-accepted");
        }
        other => panic!("unexpected reuse decision: {:?}", other),
    }
}
