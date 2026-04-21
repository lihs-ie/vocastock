//! Firestore-backed `CatalogProjectionSource` that reads the
//! `/actors/{uid}/vocabularyExpressions` subtree populated by
//! `firebase/seed/seed.mjs`.
//!
//! TCP / URL / env helpers live in `firestore_http`; field parsing
//! helpers live in `firestore_value`. This file only composes them into
//! the catalog-specific projection mapping.

use serde_json::Value;
use shared_auth::VerifiedActorContext;

use super::firestore_http::{
    execute_get, percent_encode_path, production_adapters_enabled, resolve_emulator_host,
    resolve_project_id,
};
use super::firestore_value::read_string_field;
use super::model::WorkflowState;
use super::source::{CatalogProjectionSource, ProjectionSourceRecord};

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct FirestoreCatalogProjectionSource {
    emulator_host: String,
    project_id: String,
}

impl FirestoreCatalogProjectionSource {
    pub fn from_env() -> Option<Self> {
        if !production_adapters_enabled() {
            return None;
        }
        let emulator_host = resolve_emulator_host()?;
        Some(Self {
            emulator_host,
            project_id: resolve_project_id(),
        })
    }

    pub fn new(emulator_host: impl Into<String>, project_id: impl Into<String>) -> Self {
        Self {
            emulator_host: emulator_host.into(),
            project_id: project_id.into(),
        }
    }
}

impl CatalogProjectionSource for FirestoreCatalogProjectionSource {
    fn records_for_actor(
        &self,
        actor_context: &VerifiedActorContext,
    ) -> Vec<ProjectionSourceRecord> {
        let uid = actor_context.actor().as_str();
        let path = format!(
            "/v1/projects/{}/databases/(default)/documents/actors/{}/vocabularyExpressions",
            self.project_id,
            percent_encode_path(uid),
        );
        let Ok(body) = execute_get(self.emulator_host.as_str(), path.as_str()) else {
            return Vec::new();
        };
        parse_vocabulary_listing(body.as_str())
    }
}

fn parse_vocabulary_listing(body: &str) -> Vec<ProjectionSourceRecord> {
    let Ok(payload) = serde_json::from_str::<Value>(body) else {
        return Vec::new();
    };
    let Some(documents) = payload.get("documents").and_then(Value::as_array) else {
        return Vec::new();
    };
    documents
        .iter()
        .filter_map(parse_vocabulary_document)
        .collect()
}

fn parse_vocabulary_document(doc: &Value) -> Option<ProjectionSourceRecord> {
    let fields = doc.get("fields")?.as_object()?;
    let id = read_string_field(fields, "id")?;
    let text = read_string_field(fields, "text")?;
    let registration_status =
        read_string_field(fields, "registrationStatus").unwrap_or_else(|| "active".to_string());
    let explanation_status =
        read_string_field(fields, "explanationStatus").unwrap_or_else(|| "pending".to_string());
    let current_explanation = read_string_field(fields, "currentExplanation");

    Some(ProjectionSourceRecord::new(
        id,
        registration_status,
        map_workflow_state(explanation_status.as_str()),
        current_explanation.is_some(),
        if current_explanation.is_some() {
            Some(text.as_str())
        } else {
            None
        },
    ))
}

fn map_workflow_state(status: &str) -> WorkflowState {
    match status {
        "running" => WorkflowState::Running,
        "retryScheduled" => WorkflowState::RetryScheduled,
        "succeeded" => WorkflowState::Succeeded,
        "timedOut" => WorkflowState::TimedOut,
        "failedFinal" => WorkflowState::FailedFinal,
        "deadLettered" => WorkflowState::DeadLettered,
        _ => WorkflowState::Queued,
    }
}
