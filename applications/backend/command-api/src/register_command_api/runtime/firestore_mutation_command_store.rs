//! Firestore-backed `MutationCommandStore`.
//!
//! Stores each successful mutation under
//! `/actors/{actor}/mutationIdempotency/{idempotencyKey}` with the
//! command fingerprint plus the serialized `CommandResponseEnvelope`.
//! Replays are keyed by `(commandName, payloadHash)` — a conflict on
//! the same key but different fingerprint surfaces as
//! `CommandErrorCategory::ValidationFailed`.

use serde_json::{json, Value};
use shared_firestore::{
    execute_get, execute_post, percent_encode_path, production_adapters_enabled, read_string_field,
    resolve_emulator_host, resolve_project_id, FirestoreHttpError,
};

use crate::command::CommandResponseEnvelope;

use super::mutation_command_store::{
    IdempotencyDecision, MutationCommandStore, MutationFingerprint,
};

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct FirestoreMutationCommandStore {
    emulator_host: String,
    project_id: String,
}

impl FirestoreMutationCommandStore {
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

    fn document_path(&self, actor: &str, idempotency_key: &str) -> String {
        format!(
            "/v1/projects/{}/databases/(default)/documents/actors/{}/mutationIdempotency/{}",
            self.project_id,
            percent_encode_path(actor),
            percent_encode_path(idempotency_key),
        )
    }

    fn collection_path(&self, actor: &str, idempotency_key: &str) -> String {
        format!(
            "/v1/projects/{}/databases/(default)/documents/actors/{}/mutationIdempotency?documentId={}",
            self.project_id,
            percent_encode_path(actor),
            percent_encode_path(idempotency_key),
        )
    }

    fn fetch(&self, actor: &str, idempotency_key: &str) -> Option<MutationIdempotencyDocument> {
        let path = self.document_path(actor, idempotency_key);
        let body = execute_get(self.emulator_host.as_str(), path.as_str()).ok()?;
        parse_mutation_idempotency_document(&serde_json::from_str::<Value>(body.as_str()).ok()?)
    }

    fn put(
        &self,
        actor: &str,
        idempotency_key: &str,
        document: &MutationIdempotencyDocument,
    ) -> Result<(), FirestoreHttpError> {
        let body = encode_mutation_document(document);
        match execute_post(
            self.emulator_host.as_str(),
            &self.collection_path(actor, idempotency_key),
            body.as_str(),
        ) {
            Ok(_) => Ok(()),
            Err(FirestoreHttpError::HttpStatus(409)) => {
                self.patch(actor, idempotency_key, document)
            }
            Err(error) => Err(error),
        }
    }

    fn patch(
        &self,
        actor: &str,
        idempotency_key: &str,
        document: &MutationIdempotencyDocument,
    ) -> Result<(), FirestoreHttpError> {
        let path = format!(
            "{}?updateMask.fieldPaths=commandName&updateMask.fieldPaths=payloadHash&updateMask.fieldPaths=responseJson",
            self.document_path(actor, idempotency_key),
        );
        let body = encode_mutation_document(document);
        execute_post(self.emulator_host.as_str(), path.as_str(), body.as_str()).map(|_| ())
    }
}

impl MutationCommandStore for FirestoreMutationCommandStore {
    fn idempotency_decision(
        &self,
        actor_reference: &str,
        idempotency_key: &str,
        fingerprint: &MutationFingerprint,
    ) -> IdempotencyDecision {
        let Some(document) = self.fetch(actor_reference, idempotency_key) else {
            return IdempotencyDecision::Fresh;
        };
        if document.command_name == fingerprint.command_name
            && document.payload_hash == fingerprint.payload_hash
        {
            if let Some(envelope) = document.decode_envelope() {
                return IdempotencyDecision::Replay(envelope);
            }
        }
        IdempotencyDecision::Conflict
    }

    fn commit_mutation(
        &self,
        actor_reference: &str,
        idempotency_key: &str,
        fingerprint: &MutationFingerprint,
        envelope: &CommandResponseEnvelope,
    ) {
        let document = MutationIdempotencyDocument {
            command_name: fingerprint.command_name.clone(),
            payload_hash: fingerprint.payload_hash.clone(),
            response_json: serde_json::to_string(envelope)
                .expect("CommandResponseEnvelope should serialize"),
        };
        if let Err(error) = self.put(actor_reference, idempotency_key, &document) {
            eprintln!(
                "[firestore_mutation_store] idempotency upsert failed for actor={actor_reference} key={idempotency_key} error={error:?}",
            );
        }
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct MutationIdempotencyDocument {
    pub command_name: String,
    pub payload_hash: String,
    pub response_json: String,
}

impl MutationIdempotencyDocument {
    pub fn decode_envelope(&self) -> Option<CommandResponseEnvelope> {
        serde_json::from_str(&self.response_json).ok()
    }
}

pub fn parse_mutation_idempotency_document(payload: &Value) -> Option<MutationIdempotencyDocument> {
    let fields = payload.get("fields")?.as_object()?;
    Some(MutationIdempotencyDocument {
        command_name: read_string_field(fields, "commandName")?,
        payload_hash: read_string_field(fields, "payloadHash")?,
        response_json: read_string_field(fields, "responseJson")?,
    })
}

fn encode_mutation_document(doc: &MutationIdempotencyDocument) -> String {
    json!({
        "fields": {
            "commandName": {"stringValue": doc.command_name},
            "payloadHash": {"stringValue": doc.payload_hash},
            "responseJson": {"stringValue": doc.response_json},
        }
    })
    .to_string()
}
