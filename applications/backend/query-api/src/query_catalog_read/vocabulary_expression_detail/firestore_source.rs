use serde_json::Value;
use shared_auth::VerifiedActorContext;
use shared_firestore::{
    execute_get, percent_encode_path, production_adapters_enabled, read_nullable_string_field,
    read_string_field, resolve_emulator_host, resolve_project_id,
};

use super::source::{VocabularyExpressionDetailRecord, VocabularyExpressionDetailSource};

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct FirestoreVocabularyExpressionDetailSource {
    emulator_host: String,
    project_id: String,
}

impl FirestoreVocabularyExpressionDetailSource {
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

impl VocabularyExpressionDetailSource for FirestoreVocabularyExpressionDetailSource {
    fn record_for(
        &self,
        actor_context: &VerifiedActorContext,
        identifier: &str,
    ) -> Option<VocabularyExpressionDetailRecord> {
        let path = format!(
            "/v1/projects/{}/databases/(default)/documents/actors/{}/vocabularyExpressions/{}",
            self.project_id,
            percent_encode_path(actor_context.actor().as_str()),
            percent_encode_path(identifier),
        );
        let body = execute_get(self.emulator_host.as_str(), path.as_str()).ok()?;
        let payload = serde_json::from_str::<Value>(body.as_str()).ok()?;
        parse_vocabulary_expression_document(&payload)
    }
}

/// Lift the Firestore REST document envelope into the detail record.
/// Exposed for integration testing against canned payloads.
pub fn parse_vocabulary_expression_document(
    payload: &Value,
) -> Option<VocabularyExpressionDetailRecord> {
    let fields = payload.get("fields")?.as_object()?;
    let identifier = read_string_field(fields, "id")?;
    let text = read_string_field(fields, "text")?;
    let registration_status =
        read_string_field(fields, "registrationStatus").unwrap_or_else(|| "active".to_owned());
    let explanation_status =
        read_string_field(fields, "explanationStatus").unwrap_or_else(|| "pending".to_owned());
    let image_status =
        read_string_field(fields, "imageStatus").unwrap_or_else(|| "pending".to_owned());
    let current_explanation =
        read_nullable_string_field(fields, "currentExplanation").unwrap_or(None);
    let current_image = read_nullable_string_field(fields, "currentImage").unwrap_or(None);
    let registered_at = read_string_field(fields, "registeredAt").unwrap_or_default();

    Some(VocabularyExpressionDetailRecord {
        identifier,
        text,
        registration_status,
        explanation_status,
        image_status,
        current_explanation,
        current_image,
        registered_at,
    })
}
