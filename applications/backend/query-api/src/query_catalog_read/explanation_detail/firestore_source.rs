use serde_json::{Map, Value};
use shared_auth::VerifiedActorContext;

use super::source::{
    CollocationRecord, ExplanationDetailRecord, ExplanationDetailSource, PronunciationRecord,
    SenseExampleRecord, SenseRecord, SimilarityRecord,
};
use crate::catalog::firestore_http::{
    execute_get, percent_encode_path, production_adapters_enabled, resolve_emulator_host,
    resolve_project_id,
};
use crate::catalog::firestore_value::{
    read_array_field, read_integer_field, read_map_field, read_nullable_string_field,
    read_string_field, value_as_map,
};

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct FirestoreExplanationDetailSource {
    emulator_host: String,
    project_id: String,
}

impl FirestoreExplanationDetailSource {
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

impl ExplanationDetailSource for FirestoreExplanationDetailSource {
    fn record_for(
        &self,
        actor_context: &VerifiedActorContext,
        identifier: &str,
    ) -> Option<ExplanationDetailRecord> {
        let path = format!(
            "/v1/projects/{}/databases/(default)/documents/actors/{}/explanations/{}",
            self.project_id,
            percent_encode_path(actor_context.actor().as_str()),
            percent_encode_path(identifier),
        );
        let body = execute_get(self.emulator_host.as_str(), path.as_str()).ok()?;
        let payload = serde_json::from_str::<Value>(body.as_str()).ok()?;
        parse_explanation_document(&payload)
    }
}

/// Lift the Firestore REST document envelope into the explanation
/// record. Exposed for integration testing against canned payloads.
pub fn parse_explanation_document(payload: &Value) -> Option<ExplanationDetailRecord> {
    let fields = payload.get("fields")?.as_object()?;
    let identifier = read_string_field(fields, "id")?;
    let vocabulary_expression = read_string_field(fields, "vocabularyExpression")?;
    let text = read_string_field(fields, "text")?;
    let pronunciation = parse_pronunciation(fields).unwrap_or(PronunciationRecord {
        weak: String::new(),
        strong: String::new(),
    });
    let frequency =
        read_string_field(fields, "frequency").unwrap_or_else(|| "sometimes".to_owned());
    let sophistication =
        read_string_field(fields, "sophistication").unwrap_or_else(|| "basic".to_owned());
    let etymology = read_string_field(fields, "etymology").unwrap_or_default();
    let similarities = parse_similarities(fields);
    let senses = parse_senses(fields);

    Some(ExplanationDetailRecord {
        identifier,
        vocabulary_expression,
        text,
        pronunciation,
        frequency,
        sophistication,
        etymology,
        similarities,
        senses,
    })
}

fn parse_pronunciation(fields: &Map<String, Value>) -> Option<PronunciationRecord> {
    let pronunciation = read_map_field(fields, "pronunciation")?;
    Some(PronunciationRecord {
        weak: read_string_field(pronunciation, "weak").unwrap_or_default(),
        strong: read_string_field(pronunciation, "strong").unwrap_or_default(),
    })
}

fn parse_similarities(fields: &Map<String, Value>) -> Vec<SimilarityRecord> {
    let Some(values) = read_array_field(fields, "similarities") else {
        return Vec::new();
    };
    values
        .iter()
        .filter_map(|value| {
            let entry = value_as_map(value)?;
            Some(SimilarityRecord {
                value: read_string_field(entry, "value").unwrap_or_default(),
                meaning: read_string_field(entry, "meaning").unwrap_or_default(),
                comparison: read_string_field(entry, "comparison").unwrap_or_default(),
            })
        })
        .collect()
}

fn parse_senses(fields: &Map<String, Value>) -> Vec<SenseRecord> {
    let Some(values) = read_array_field(fields, "senses") else {
        return Vec::new();
    };
    values
        .iter()
        .filter_map(|value| {
            let entry = value_as_map(value)?;
            Some(SenseRecord {
                identifier: read_string_field(entry, "identifier").unwrap_or_default(),
                order: read_integer_field(entry, "order").unwrap_or_default(),
                label: read_string_field(entry, "label").unwrap_or_default(),
                situation: read_string_field(entry, "situation").unwrap_or_default(),
                nuance: read_string_field(entry, "nuance").unwrap_or_default(),
                examples: parse_examples(entry),
                collocations: parse_collocations(entry),
            })
        })
        .collect()
}

fn parse_examples(fields: &Map<String, Value>) -> Vec<SenseExampleRecord> {
    let Some(values) = read_array_field(fields, "examples") else {
        return Vec::new();
    };
    values
        .iter()
        .filter_map(|value| {
            let entry = value_as_map(value)?;
            Some(SenseExampleRecord {
                value: read_string_field(entry, "value").unwrap_or_default(),
                meaning: read_string_field(entry, "meaning").unwrap_or_default(),
                pronunciation: read_nullable_string_field(entry, "pronunciation").unwrap_or(None),
            })
        })
        .collect()
}

fn parse_collocations(fields: &Map<String, Value>) -> Vec<CollocationRecord> {
    let Some(values) = read_array_field(fields, "collocations") else {
        return Vec::new();
    };
    values
        .iter()
        .filter_map(|value| {
            let entry = value_as_map(value)?;
            Some(CollocationRecord {
                value: read_string_field(entry, "value").unwrap_or_default(),
                meaning: read_string_field(entry, "meaning").unwrap_or_default(),
            })
        })
        .collect()
}
