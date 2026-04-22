//! Firestore-backed implementation of `CommandStore` for the
//! `registerVocabularyExpression` write path.
//!
//! Document layout (mirrors the existing in-memory fingerprint keys):
//!
//! - `/actors/{actor}/registrations/{normalizedText}`: latest
//!   registration / explanation state
//! - `/actors/{actor}/commandIdempotency/{idempotencyKey}`: serialized
//!   `AcceptedCommandResult` plus the fingerprint used for replay
//!   detection

use serde_json::{json, Value};
use shared_firestore::{
    execute_get, execute_post, percent_encode_path, production_adapters_enabled, read_string_field,
    resolve_emulator_host, resolve_project_id, FirestoreHttpError,
};

use crate::command::{
    AcceptedCommandResult, DuplicateReuseResult, RegisterVocabularyExpressionCommand,
};

use super::command_store::{
    CommandStore, PlannedNewRegistration, PlannedReuseRegistration, StoreDecision,
    StoredRegistration,
};
use super::service_contract::{
    vocabulary_expression_for, EXPLANATION_STATE_FAILED_FINAL, EXPLANATION_STATE_NOT_STARTED,
    EXPLANATION_STATE_QUEUED, REGISTERED_STATE,
};

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct FirestoreCommandStore {
    emulator_host: String,
    project_id: String,
}

impl FirestoreCommandStore {
    pub fn from_env() -> Option<Self> {
        if !production_adapters_enabled() {
            return None;
        }
        Some(Self {
            emulator_host: resolve_emulator_host()?,
            project_id: resolve_project_id(),
        })
    }

    pub fn new(emulator_host: impl Into<String>, project_id: impl Into<String>) -> Self {
        Self {
            emulator_host: emulator_host.into(),
            project_id: project_id.into(),
        }
    }

    fn registration_document_path(&self, actor: &str, normalized_text: &str) -> String {
        format!(
            "/v1/projects/{}/databases/(default)/documents/actors/{}/registrations/{}",
            self.project_id,
            percent_encode_path(actor),
            percent_encode_path(normalized_text),
        )
    }

    fn idempotency_document_path(&self, actor: &str, idempotency_key: &str) -> String {
        format!(
            "/v1/projects/{}/databases/(default)/documents/actors/{}/commandIdempotency/{}",
            self.project_id,
            percent_encode_path(actor),
            percent_encode_path(idempotency_key),
        )
    }

    fn idempotency_collection_path(&self, actor: &str) -> String {
        format!(
            "/v1/projects/{}/databases/(default)/documents/actors/{}/commandIdempotency?documentId=",
            self.project_id,
            percent_encode_path(actor),
        )
    }

    fn registration_collection_path(&self, actor: &str) -> String {
        format!(
            "/v1/projects/{}/databases/(default)/documents/actors/{}/registrations?documentId=",
            self.project_id,
            percent_encode_path(actor),
        )
    }

    fn fetch_registration(&self, actor: &str, normalized_text: &str) -> Option<StoredRegistration> {
        let path = self.registration_document_path(actor, normalized_text);
        let body = execute_get(self.emulator_host.as_str(), path.as_str()).ok()?;
        parse_registration_document(&serde_json::from_str::<Value>(body.as_str()).ok()?)
    }

    fn fetch_idempotency(&self, actor: &str, idempotency_key: &str) -> Option<IdempotencyDocument> {
        let path = self.idempotency_document_path(actor, idempotency_key);
        let body = execute_get(self.emulator_host.as_str(), path.as_str()).ok()?;
        parse_idempotency_document(&serde_json::from_str::<Value>(body.as_str()).ok()?)
    }

    fn put_idempotency(
        &self,
        actor: &str,
        idempotency_key: &str,
        doc: &IdempotencyDocument,
    ) -> Result<(), FirestoreHttpError> {
        let path = format!(
            "{}{}",
            self.idempotency_collection_path(actor),
            percent_encode_path(idempotency_key)
        );
        let body = encode_idempotency_document(doc);
        match execute_post(self.emulator_host.as_str(), path.as_str(), body.as_str()) {
            Ok(_) => Ok(()),
            // Firestore returns 409 when the document already exists —
            // for `commit_new` that is a programming error (the plan
            // promised a fresh write); for `commit_reuse` we explicitly
            // overwrite via PATCH instead.
            Err(FirestoreHttpError::HttpStatus(409)) => {
                self.patch_idempotency(actor, idempotency_key, doc)
            }
            Err(error) => Err(error),
        }
    }

    fn patch_idempotency(
        &self,
        actor: &str,
        idempotency_key: &str,
        doc: &IdempotencyDocument,
    ) -> Result<(), FirestoreHttpError> {
        let path = format!(
            "{}?updateMask.fieldPaths=commandName&updateMask.fieldPaths=fingerprintHash&updateMask.fieldPaths=startExplanation&updateMask.fieldPaths=responseJson",
            self.idempotency_document_path(actor, idempotency_key),
        );
        let body = encode_idempotency_fields(doc);
        // Firestore patch goes via POST with updateMask query params.
        execute_post(self.emulator_host.as_str(), path.as_str(), body.as_str()).map(|_| ())
    }

    fn put_registration(
        &self,
        actor: &str,
        normalized_text: &str,
        registration: &StoredRegistration,
    ) -> Result<(), FirestoreHttpError> {
        let path = format!(
            "{}{}",
            self.registration_collection_path(actor),
            percent_encode_path(normalized_text)
        );
        let body = encode_registration_document(registration);
        match execute_post(self.emulator_host.as_str(), path.as_str(), body.as_str()) {
            Ok(_) => Ok(()),
            Err(FirestoreHttpError::HttpStatus(409)) => {
                self.patch_registration(actor, normalized_text, registration)
            }
            Err(error) => Err(error),
        }
    }

    fn patch_registration(
        &self,
        actor: &str,
        normalized_text: &str,
        registration: &StoredRegistration,
    ) -> Result<(), FirestoreHttpError> {
        let path = format!(
            "{}?updateMask.fieldPaths=vocabularyExpression&updateMask.fieldPaths=registrationState&updateMask.fieldPaths=explanationState",
            self.registration_document_path(actor, normalized_text),
        );
        let body = encode_registration_fields(registration);
        execute_post(self.emulator_host.as_str(), path.as_str(), body.as_str()).map(|_| ())
    }
}

impl CommandStore for FirestoreCommandStore {
    fn plan(&self, command: &RegisterVocabularyExpressionCommand) -> StoreDecision {
        let actor = command.actor.actor().as_str();

        if let Some(existing) = self.fetch_idempotency(actor, command.idempotency_key.as_str()) {
            if existing
                .matches_fingerprint(command.normalized_text.as_str(), command.start_explanation)
            {
                if let Some(result) = existing.decode_result() {
                    return StoreDecision::ReplayExisting(result);
                }
            }
            return StoreDecision::Conflict;
        }

        if let Some(existing_registration) =
            self.fetch_registration(actor, command.normalized_text.as_str())
        {
            let (dispatch_required, resulting_explanation_state, duplicate_reuse) =
                duplicate_reuse_plan(&existing_registration, command.start_explanation);

            return StoreDecision::ReuseExisting(PlannedReuseRegistration {
                existing_registration,
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

    fn commit_new(
        &self,
        command: &RegisterVocabularyExpressionCommand,
        plan: &PlannedNewRegistration,
        result: &AcceptedCommandResult,
    ) {
        let actor = command.actor.actor().as_str();
        let registration = StoredRegistration {
            vocabulary_expression: plan.vocabulary_expression.clone(),
            registration_state: REGISTERED_STATE.to_owned(),
            explanation_state: plan.explanation_state.clone(),
        };
        // Best-effort: Firestore failures are logged, not surfaced. The
        // dispatch gate already ran before this point, so the invariant
        // is "accepted response <=> Firestore write attempted".
        if let Err(error) =
            self.put_registration(actor, command.normalized_text.as_str(), &registration)
        {
            eprintln!(
                "[firestore_command_store] registration upsert failed for actor={actor} text={} error={error:?}",
                command.normalized_text,
            );
        }

        let idempotency_doc = IdempotencyDocument::for_register(
            command.normalized_text.as_str(),
            command.start_explanation,
            result,
        );
        if let Err(error) =
            self.put_idempotency(actor, command.idempotency_key.as_str(), &idempotency_doc)
        {
            eprintln!(
                "[firestore_command_store] idempotency upsert failed for actor={actor} key={} error={error:?}",
                command.idempotency_key,
            );
        }
    }

    fn commit_reuse(
        &self,
        command: &RegisterVocabularyExpressionCommand,
        plan: &PlannedReuseRegistration,
        result: &AcceptedCommandResult,
    ) {
        let actor = command.actor.actor().as_str();
        let registration = StoredRegistration {
            vocabulary_expression: plan.existing_registration.vocabulary_expression.clone(),
            registration_state: plan.existing_registration.registration_state.clone(),
            explanation_state: plan.resulting_explanation_state.clone(),
        };
        if let Err(error) =
            self.put_registration(actor, command.normalized_text.as_str(), &registration)
        {
            eprintln!(
                "[firestore_command_store] registration upsert (reuse) failed for actor={actor} text={} error={error:?}",
                command.normalized_text,
            );
        }

        let idempotency_doc = IdempotencyDocument::for_register(
            command.normalized_text.as_str(),
            command.start_explanation,
            result,
        );
        if let Err(error) =
            self.put_idempotency(actor, command.idempotency_key.as_str(), &idempotency_doc)
        {
            eprintln!(
                "[firestore_command_store] idempotency upsert (reuse) failed for actor={actor} key={} error={error:?}",
                command.idempotency_key,
            );
        }
    }
}

fn duplicate_reuse_plan(
    existing: &StoredRegistration,
    start_explanation: bool,
) -> (bool, String, DuplicateReuseResult) {
    if !start_explanation {
        return (
            false,
            existing.explanation_state.clone(),
            DuplicateReuseResult {
                registration_state: existing.registration_state.clone(),
                explanation_state: existing.explanation_state.clone(),
                restart_decision: "restart-suppressed".to_owned(),
                restart_condition: "startExplanation was explicitly disabled".to_owned(),
            },
        );
    }

    if matches!(
        existing.explanation_state.as_str(),
        EXPLANATION_STATE_NOT_STARTED | EXPLANATION_STATE_FAILED_FINAL
    ) {
        return (
            true,
            EXPLANATION_STATE_QUEUED.to_owned(),
            DuplicateReuseResult {
                registration_state: existing.registration_state.clone(),
                explanation_state: existing.explanation_state.clone(),
                restart_decision: "restart-accepted".to_owned(),
                restart_condition: "existing explanation can be restarted".to_owned(),
            },
        );
    }

    (
        false,
        existing.explanation_state.clone(),
        DuplicateReuseResult {
            registration_state: existing.registration_state.clone(),
            explanation_state: existing.explanation_state.clone(),
            restart_decision: "restart-suppressed".to_owned(),
            restart_condition: "existing explanation does not need restart".to_owned(),
        },
    )
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct IdempotencyDocument {
    pub command_name: String,
    pub fingerprint_hash: String,
    pub start_explanation: bool,
    pub response_json: String,
}

impl IdempotencyDocument {
    fn for_register(
        normalized_text: &str,
        start_explanation: bool,
        result: &AcceptedCommandResult,
    ) -> Self {
        Self {
            command_name: "registerVocabularyExpression".to_owned(),
            fingerprint_hash: register_fingerprint_hash(normalized_text, start_explanation),
            start_explanation,
            response_json: serde_json::to_string(result)
                .expect("AcceptedCommandResult should serialize"),
        }
    }

    pub fn matches_fingerprint(&self, normalized_text: &str, start_explanation: bool) -> bool {
        self.command_name == "registerVocabularyExpression"
            && self.start_explanation == start_explanation
            && self.fingerprint_hash
                == register_fingerprint_hash(normalized_text, start_explanation)
    }

    pub fn decode_result(&self) -> Option<AcceptedCommandResult> {
        serde_json::from_str(&self.response_json).ok()
    }
}

fn register_fingerprint_hash(normalized_text: &str, start_explanation: bool) -> String {
    // 正規化 text と start_explanation を `|` で join しただけの
    // deterministic なキー。暗号学的強度は不要 (Firestore の document
    // key は既にスコープ分離されており、fingerprint は replay 判定専用)。
    format!("{start_explanation}|{normalized_text}")
}

pub fn parse_registration_document(payload: &Value) -> Option<StoredRegistration> {
    let fields = payload.get("fields")?.as_object()?;
    let vocabulary_expression = read_string_field(fields, "vocabularyExpression")?;
    let registration_state = read_string_field(fields, "registrationState")?;
    let explanation_state = read_string_field(fields, "explanationState")?;
    Some(StoredRegistration {
        vocabulary_expression,
        registration_state,
        explanation_state,
    })
}

pub fn parse_idempotency_document(payload: &Value) -> Option<IdempotencyDocument> {
    let fields = payload.get("fields")?.as_object()?;
    let command_name = read_string_field(fields, "commandName")?;
    let fingerprint_hash = read_string_field(fields, "fingerprintHash")?;
    let response_json = read_string_field(fields, "responseJson")?;
    let start_explanation = read_bool_field(fields, "startExplanation").unwrap_or(true);
    Some(IdempotencyDocument {
        command_name,
        fingerprint_hash,
        start_explanation,
        response_json,
    })
}

fn read_bool_field(fields: &serde_json::Map<String, Value>, key: &str) -> Option<bool> {
    fields.get(key)?.as_object()?.get("booleanValue")?.as_bool()
}

fn encode_registration_document(registration: &StoredRegistration) -> String {
    json!({
        "fields": registration_fields_payload(registration),
    })
    .to_string()
}

fn encode_registration_fields(registration: &StoredRegistration) -> String {
    json!({
        "fields": registration_fields_payload(registration),
    })
    .to_string()
}

fn registration_fields_payload(registration: &StoredRegistration) -> Value {
    json!({
        "vocabularyExpression": {"stringValue": registration.vocabulary_expression},
        "registrationState": {"stringValue": registration.registration_state},
        "explanationState": {"stringValue": registration.explanation_state},
    })
}

fn encode_idempotency_document(doc: &IdempotencyDocument) -> String {
    json!({
        "fields": idempotency_fields_payload(doc),
    })
    .to_string()
}

fn encode_idempotency_fields(doc: &IdempotencyDocument) -> String {
    json!({
        "fields": idempotency_fields_payload(doc),
    })
    .to_string()
}

fn idempotency_fields_payload(doc: &IdempotencyDocument) -> Value {
    json!({
        "commandName": {"stringValue": doc.command_name},
        "fingerprintHash": {"stringValue": doc.fingerprint_hash},
        "startExplanation": {"booleanValue": doc.start_explanation},
        "responseJson": {"stringValue": doc.response_json},
    })
}
