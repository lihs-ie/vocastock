use shared_auth::VerifiedActorContext;
use shared_firestore::{
    percent_encode_path, production_adapters_enabled, read_string_field, resolve_emulator_host,
    resolve_project_id,
};

use super::source::{LearningStateRecord, LearningStateSource};

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct FirestoreLearningStateSource {
    emulator_host: String,
    project_id: String,
}

impl FirestoreLearningStateSource {
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

impl LearningStateSource for FirestoreLearningStateSource {
    fn record_for(
        &self,
        actor_context: &VerifiedActorContext,
        vocabulary_expression: &str,
    ) -> Option<LearningStateRecord> {
        let path = format!(
            "/v1/projects/{}/databases/(default)/documents/actors/{}/learningStates/{}",
            self.project_id,
            percent_encode_path(actor_context.actor().as_str()),
            percent_encode_path(vocabulary_expression),
        );
        let body = shared_firestore::execute_get(&self.emulator_host, &path).ok()?;
        let payload: serde_json::Value = serde_json::from_str(&body).ok()?;
        parse_learning_state_document(&payload)
    }
}

pub fn parse_learning_state_document(payload: &serde_json::Value) -> Option<LearningStateRecord> {
    let fields = payload.get("fields")?.as_object()?;
    let vocabulary_expression = read_string_field(fields, "vocabularyExpression")
        .or_else(|| read_string_field(fields, "id"))?;
    let proficiency = read_string_field(fields, "proficiency")?;
    let created_at = read_string_field(fields, "createdAt").unwrap_or_default();
    let updated_at = read_string_field(fields, "updatedAt").unwrap_or_default();

    Some(LearningStateRecord {
        vocabulary_expression,
        proficiency,
        created_at,
        updated_at,
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_fully_populated_document() {
        let payload = serde_json::json!({
            "name": "projects/demo-vocastock/databases/(default)/documents/actors/actor/learningStates/vocab-0000",
            "fields": {
                "id": {"stringValue": "stub-vocab-0000"},
                "vocabularyExpression": {"stringValue": "stub-vocab-0000"},
                "proficiency": {"stringValue": "learned"},
                "createdAt": {"stringValue": "2026-04-05T10:00:00.000Z"},
                "updatedAt": {"stringValue": "2026-04-20T08:30:00.000Z"}
            }
        });
        let record = parse_learning_state_document(&payload).unwrap();
        assert_eq!(record.vocabulary_expression, "stub-vocab-0000");
        assert_eq!(record.proficiency, "learned");
        assert_eq!(record.created_at, "2026-04-05T10:00:00.000Z");
        assert_eq!(record.updated_at, "2026-04-20T08:30:00.000Z");
    }

    #[test]
    fn returns_none_when_proficiency_missing() {
        let payload = serde_json::json!({
            "fields": {
                "id": {"stringValue": "vocab-0000"},
                "createdAt": {"stringValue": "2026-04-05T10:00:00.000Z"}
            }
        });
        assert!(parse_learning_state_document(&payload).is_none());
    }
}
