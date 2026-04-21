//! Firestore-backed `CatalogProjectionSource` that reads the
//! `/actors/{uid}/vocabularyExpressions` subtree populated by
//! `firebase/seed/seed.mjs`.
//!
//! The implementation intentionally uses a hand-rolled TCP client
//! (matching the pattern in
//! `applications/backend/graphql-gateway/src/gateway_routing/downstream/relay_client.rs`)
//! so this crate does not pull in tokio / reqwest transitive
//! dependencies. Only the Firestore emulator REST surface is
//! supported today; production deployments will need signed requests +
//! TLS that a future `shared-firestore` crate can encapsulate.

use std::env;
use std::io::{Read, Write};
use std::net::TcpStream;
use std::time::Duration;

use serde_json::Value;
use shared_auth::VerifiedActorContext;

use super::model::WorkflowState;
use super::source::{CatalogProjectionSource, ProjectionSourceRecord};

/// Environment variable the Firestore emulator exports
/// (e.g. `127.0.0.1:18080`).
pub const FIRESTORE_EMULATOR_HOST_ENV: &str = "FIRESTORE_EMULATOR_HOST";

/// Opt-in flag that switches the catalog source from the in-memory
/// fixture to the Firestore-backed reader. Keeps the existing feature
/// tests — which export `FIRESTORE_EMULATOR_HOST` purely for downstream
/// containers — bound to the fixture path.
pub const PRODUCTION_ADAPTERS_ENV: &str = "VOCAS_PRODUCTION_ADAPTERS";

/// Default demo project ID; production wiring should override via env.
pub const DEFAULT_PROJECT_ID: &str = "demo-vocastock";

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
        let host = env::var(FIRESTORE_EMULATOR_HOST_ENV).ok()?;
        let host = host.trim().to_owned();
        if host.is_empty() {
            return None;
        }
        let project_id = env::var("FIREBASE_PROJECT")
            .ok()
            .filter(|value| !value.trim().is_empty())
            .unwrap_or_else(|| DEFAULT_PROJECT_ID.to_owned());
        Some(Self {
            emulator_host: host,
            project_id,
        })
    }

    pub fn new(emulator_host: impl Into<String>, project_id: impl Into<String>) -> Self {
        Self {
            emulator_host: emulator_host.into(),
            project_id: project_id.into(),
        }
    }
}

fn production_adapters_enabled() -> bool {
    env::var(PRODUCTION_ADAPTERS_ENV)
        .ok()
        .map(|value| matches!(value.trim(), "true" | "1" | "yes"))
        .unwrap_or(false)
}

impl CatalogProjectionSource for FirestoreCatalogProjectionSource {
    fn records_for_actor(
        &self,
        actor_context: &VerifiedActorContext,
    ) -> Vec<ProjectionSourceRecord> {
        let uid = actor_uid_from_context(actor_context);
        let path = format!(
            "/v1/projects/{}/databases/(default)/documents/actors/{}/vocabularyExpressions",
            self.project_id,
            percent_encode_path(uid.as_str()),
        );
        let Ok(body) = execute_get(self.emulator_host.as_str(), path.as_str()) else {
            return Vec::new();
        };
        parse_vocabulary_listing(body.as_str())
    }
}

fn actor_uid_from_context(actor_context: &VerifiedActorContext) -> String {
    // `actor_context.actor()` is the canonical subject id. The seed data
    // keys each actor subtree by the Firebase Auth UID (identical to
    // the verified actor reference for the emulator).
    actor_context.actor().as_str().to_owned()
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
        .filter_map(|doc| parse_vocabulary_document(doc))
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

fn read_string_field(
    fields: &serde_json::Map<String, Value>,
    key: &str,
) -> Option<String> {
    fields
        .get(key)
        .and_then(|field| field.as_object())
        .and_then(|object| object.get("stringValue"))
        .and_then(Value::as_str)
        .map(str::to_owned)
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

fn execute_get(host_port: &str, path: &str) -> Result<String, ()> {
    let (host, port) = parse_host_port(host_port).ok_or(())?;
    let mut stream = TcpStream::connect((host.as_str(), port)).map_err(|_| ())?;
    stream.set_read_timeout(Some(Duration::from_secs(3))).map_err(|_| ())?;
    stream.set_write_timeout(Some(Duration::from_secs(3))).map_err(|_| ())?;

    let request = format!(
        "GET {path} HTTP/1.1\r\nHost: {host}:{port}\r\nConnection: close\r\n\r\n"
    );
    stream.write_all(request.as_bytes()).map_err(|_| ())?;
    stream.flush().map_err(|_| ())?;

    let mut response = String::new();
    stream.read_to_string(&mut response).map_err(|_| ())?;
    let (_head, body) = response.split_once("\r\n\r\n").ok_or(())?;
    Ok(body.to_owned())
}

fn parse_host_port(host_port: &str) -> Option<(String, u16)> {
    let (host, port) = host_port.split_once(':')?;
    let port = port.parse::<u16>().ok()?;
    Some((host.trim().to_owned(), port))
}

fn percent_encode_path(raw: &str) -> String {
    let mut buffer = String::with_capacity(raw.len());
    for byte in raw.as_bytes() {
        match byte {
            b'A'..=b'Z' | b'a'..=b'z' | b'0'..=b'9' | b'-' | b'_' | b'.' | b'~' => {
                buffer.push(*byte as char);
            }
            _ => buffer.push_str(&format!("%{byte:02X}")),
        }
    }
    buffer
}
