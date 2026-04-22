use serde_json::Value;
use shared_auth::VerifiedActorContext;
use shared_firestore::{
    execute_get, percent_encode_path, production_adapters_enabled, read_nullable_string_field,
    read_string_field, resolve_emulator_host, resolve_project_id,
};

use super::source::{ImageDetailRecord, ImageDetailSource};

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct FirestoreImageDetailSource {
    emulator_host: String,
    project_id: String,
}

impl FirestoreImageDetailSource {
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
}

impl ImageDetailSource for FirestoreImageDetailSource {
    fn record_for(
        &self,
        actor_context: &VerifiedActorContext,
        identifier: &str,
    ) -> Option<ImageDetailRecord> {
        let path = format!(
            "/v1/projects/{}/databases/(default)/documents/actors/{}/images/{}",
            self.project_id,
            percent_encode_path(actor_context.actor().as_str()),
            percent_encode_path(identifier),
        );
        let body = execute_get(self.emulator_host.as_str(), path.as_str()).ok()?;
        let payload = serde_json::from_str::<Value>(body.as_str()).ok()?;
        parse_image_document(&payload)
    }
}

/// Lift the Firestore REST document envelope into the image record.
/// Exposed for integration testing against canned payloads.
pub fn parse_image_document(payload: &Value) -> Option<ImageDetailRecord> {
    let fields = payload.get("fields")?.as_object()?;
    let identifier = read_string_field(fields, "id")?;
    let explanation = read_string_field(fields, "explanation").unwrap_or_default();
    let asset_reference = read_string_field(fields, "assetReference").unwrap_or_default();
    let description = read_string_field(fields, "description").unwrap_or_default();
    let sense_identifier = read_nullable_string_field(fields, "senseIdentifier").unwrap_or(None);
    let sense_label = read_nullable_string_field(fields, "senseLabel").unwrap_or(None);

    Some(ImageDetailRecord {
        identifier,
        explanation,
        asset_reference,
        description,
        sense_identifier,
        sense_label,
    })
}
