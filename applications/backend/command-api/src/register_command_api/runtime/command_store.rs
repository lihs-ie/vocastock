use std::collections::BTreeMap;
use std::sync::Mutex;

use crate::command::{
    AcceptedCommandResult, DuplicateReuseResult, RegisterVocabularyExpressionCommand,
};

use super::{
    vocabulary_expression_for, EXPLANATION_STATE_FAILED_FINAL, EXPLANATION_STATE_NOT_STARTED,
    EXPLANATION_STATE_QUEUED, REGISTERED_STATE,
};

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct StoredRegistration {
    pub vocabulary_expression: String,
    pub registration_state: String,
    pub explanation_state: String,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct PlannedNewRegistration {
    pub vocabulary_expression: String,
    pub explanation_state: String,
    pub dispatch_required: bool,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct PlannedReuseRegistration {
    pub existing_registration: StoredRegistration,
    pub resulting_explanation_state: String,
    pub duplicate_reuse: DuplicateReuseResult,
    pub dispatch_required: bool,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum StoreDecision {
    AcceptNew(PlannedNewRegistration),
    ReplayExisting(AcceptedCommandResult),
    ReuseExisting(PlannedReuseRegistration),
    Conflict,
}

#[derive(Clone, Debug, Eq, PartialEq)]
struct RequestFingerprint {
    normalized_text: String,
    start_explanation: bool,
}

#[derive(Clone, Debug, Eq, PartialEq)]
struct StoredIdempotencyRecord {
    fingerprint: RequestFingerprint,
    result: AcceptedCommandResult,
}

#[derive(Default)]
struct StoreState {
    registrations: BTreeMap<String, StoredRegistration>,
    idempotency_records: BTreeMap<String, StoredIdempotencyRecord>,
}

/// Port for the register-vocabulary-expression authoritative write
/// path. Implementations may be backed by in-memory fixtures (unit
/// tests, local dev) or Firestore (production adapters).
pub trait CommandStore {
    fn plan(&self, command: &RegisterVocabularyExpressionCommand) -> StoreDecision;
    fn commit_new(
        &self,
        command: &RegisterVocabularyExpressionCommand,
        plan: &PlannedNewRegistration,
        result: &AcceptedCommandResult,
    );
    fn commit_reuse(
        &self,
        command: &RegisterVocabularyExpressionCommand,
        plan: &PlannedReuseRegistration,
        result: &AcceptedCommandResult,
    );
}

#[derive(Default)]
pub struct InMemoryCommandStore {
    state: Mutex<StoreState>,
}

impl InMemoryCommandStore {
    pub fn plan(&self, command: &RegisterVocabularyExpressionCommand) -> StoreDecision {
        let state = self.state.lock().expect("command store lock poisoned");
        let actor_reference = command.actor.actor().as_str();
        let fingerprint = fingerprint_for(command);
        let idempotency_key =
            scoped_idempotency_key(actor_reference, command.idempotency_key.as_str());

        if let Some(record) = state.idempotency_records.get(idempotency_key.as_str()) {
            if record.fingerprint == fingerprint {
                return StoreDecision::ReplayExisting(record.result.clone());
            }

            return StoreDecision::Conflict;
        }

        let registration_key =
            scoped_registration_key(actor_reference, command.normalized_text.as_str());
        if let Some(existing_registration) = state.registrations.get(registration_key.as_str()) {
            let (dispatch_required, resulting_explanation_state, duplicate_reuse) =
                duplicate_reuse_plan(existing_registration, command.start_explanation);

            return StoreDecision::ReuseExisting(PlannedReuseRegistration {
                existing_registration: existing_registration.clone(),
                resulting_explanation_state,
                duplicate_reuse,
                dispatch_required,
            });
        }

        StoreDecision::AcceptNew(PlannedNewRegistration {
            vocabulary_expression: vocabulary_expression_for(command.normalized_text.as_str()),
            explanation_state: if command.start_explanation {
                EXPLANATION_STATE_QUEUED.to_owned()
            } else {
                EXPLANATION_STATE_NOT_STARTED.to_owned()
            },
            dispatch_required: command.start_explanation,
        })
    }

    pub fn commit_new(
        &self,
        command: &RegisterVocabularyExpressionCommand,
        plan: &PlannedNewRegistration,
        result: &AcceptedCommandResult,
    ) {
        let mut state = self.state.lock().expect("command store lock poisoned");
        let actor_reference = command.actor.actor().as_str();

        state.registrations.insert(
            scoped_registration_key(actor_reference, command.normalized_text.as_str()),
            StoredRegistration {
                vocabulary_expression: plan.vocabulary_expression.clone(),
                registration_state: REGISTERED_STATE.to_owned(),
                explanation_state: plan.explanation_state.clone(),
            },
        );
        state.idempotency_records.insert(
            scoped_idempotency_key(actor_reference, command.idempotency_key.as_str()),
            StoredIdempotencyRecord {
                fingerprint: fingerprint_for(command),
                result: result.clone(),
            },
        );
    }

    pub fn commit_reuse(
        &self,
        command: &RegisterVocabularyExpressionCommand,
        plan: &PlannedReuseRegistration,
        result: &AcceptedCommandResult,
    ) {
        let mut state = self.state.lock().expect("command store lock poisoned");
        let actor_reference = command.actor.actor().as_str();
        let registration_key =
            scoped_registration_key(actor_reference, command.normalized_text.as_str());

        state.registrations.insert(
            registration_key,
            StoredRegistration {
                vocabulary_expression: plan.existing_registration.vocabulary_expression.clone(),
                registration_state: plan.existing_registration.registration_state.clone(),
                explanation_state: plan.resulting_explanation_state.clone(),
            },
        );
        state.idempotency_records.insert(
            scoped_idempotency_key(actor_reference, command.idempotency_key.as_str()),
            StoredIdempotencyRecord {
                fingerprint: fingerprint_for(command),
                result: result.clone(),
            },
        );
    }

    pub fn registration_for(
        &self,
        actor_reference: &str,
        normalized_text: &str,
    ) -> Option<StoredRegistration> {
        self.state
            .lock()
            .expect("command store lock poisoned")
            .registrations
            .get(scoped_registration_key(actor_reference, normalized_text).as_str())
            .cloned()
    }

    pub fn idempotency_result_for(
        &self,
        actor_reference: &str,
        idempotency_key: &str,
    ) -> Option<AcceptedCommandResult> {
        self.state
            .lock()
            .expect("command store lock poisoned")
            .idempotency_records
            .get(scoped_idempotency_key(actor_reference, idempotency_key).as_str())
            .map(|record| record.result.clone())
    }
}

impl CommandStore for InMemoryCommandStore {
    fn plan(&self, command: &RegisterVocabularyExpressionCommand) -> StoreDecision {
        Self::plan(self, command)
    }

    fn commit_new(
        &self,
        command: &RegisterVocabularyExpressionCommand,
        plan: &PlannedNewRegistration,
        result: &AcceptedCommandResult,
    ) {
        Self::commit_new(self, command, plan, result)
    }

    fn commit_reuse(
        &self,
        command: &RegisterVocabularyExpressionCommand,
        plan: &PlannedReuseRegistration,
        result: &AcceptedCommandResult,
    ) {
        Self::commit_reuse(self, command, plan, result)
    }
}

fn fingerprint_for(command: &RegisterVocabularyExpressionCommand) -> RequestFingerprint {
    RequestFingerprint {
        normalized_text: command.normalized_text.clone(),
        start_explanation: command.start_explanation,
    }
}

fn scoped_registration_key(actor_reference: &str, normalized_text: &str) -> String {
    scoped_key(actor_reference, normalized_text)
}

fn scoped_idempotency_key(actor_reference: &str, idempotency_key: &str) -> String {
    scoped_key(actor_reference, idempotency_key)
}

fn scoped_key(actor_reference: &str, value: &str) -> String {
    format!(
        "{}|{}",
        length_prefixed(actor_reference),
        length_prefixed(value)
    )
}

fn length_prefixed(value: &str) -> String {
    format!("{}:{value}", value.len())
}

fn duplicate_reuse_plan(
    existing_registration: &StoredRegistration,
    start_explanation: bool,
) -> (bool, String, DuplicateReuseResult) {
    if !start_explanation {
        return (
            false,
            existing_registration.explanation_state.clone(),
            DuplicateReuseResult {
                registration_state: existing_registration.registration_state.clone(),
                explanation_state: existing_registration.explanation_state.clone(),
                restart_decision: "restart-suppressed".to_owned(),
                restart_condition: "startExplanation was explicitly disabled".to_owned(),
            },
        );
    }

    if matches!(
        existing_registration.explanation_state.as_str(),
        EXPLANATION_STATE_NOT_STARTED | EXPLANATION_STATE_FAILED_FINAL
    ) {
        return (
            true,
            EXPLANATION_STATE_QUEUED.to_owned(),
            DuplicateReuseResult {
                registration_state: existing_registration.registration_state.clone(),
                explanation_state: existing_registration.explanation_state.clone(),
                restart_decision: "restart-accepted".to_owned(),
                restart_condition: "existing explanation can be restarted".to_owned(),
            },
        );
    }

    (
        false,
        existing_registration.explanation_state.clone(),
        DuplicateReuseResult {
            registration_state: existing_registration.registration_state.clone(),
            explanation_state: existing_registration.explanation_state.clone(),
            restart_decision: "restart-suppressed".to_owned(),
            restart_condition: "existing explanation does not need restart".to_owned(),
        },
    )
}
