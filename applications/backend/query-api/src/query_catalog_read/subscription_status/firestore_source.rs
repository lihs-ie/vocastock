use serde_json::Value;
use shared_auth::VerifiedActorContext;

use super::source::{AllowanceRecord, SubscriptionRecord, SubscriptionStatusSource};
use crate::catalog::firestore_http::{
    execute_get, percent_encode_path, production_adapters_enabled, resolve_emulator_host,
    resolve_project_id,
};
use crate::catalog::firestore_value::{read_integer_field, read_map_field, read_string_field};

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct FirestoreSubscriptionStatusSource {
    emulator_host: String,
    project_id: String,
}

impl FirestoreSubscriptionStatusSource {
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

impl SubscriptionStatusSource for FirestoreSubscriptionStatusSource {
    fn record_for(&self, actor_context: &VerifiedActorContext) -> Option<SubscriptionRecord> {
        let path = format!(
            "/v1/projects/{}/databases/(default)/documents/actors/{}/subscription/current",
            self.project_id,
            percent_encode_path(actor_context.actor().as_str()),
        );
        let body = execute_get(self.emulator_host.as_str(), path.as_str()).ok()?;
        let payload = serde_json::from_str::<Value>(body.as_str()).ok()?;
        parse_subscription_document(&payload)
    }
}

/// Lift the Firestore REST document envelope into the subscription
/// record. Exposed for integration testing against canned payloads.
pub fn parse_subscription_document(payload: &Value) -> Option<SubscriptionRecord> {
    let fields = payload.get("fields")?.as_object()?;
    let state = read_string_field(fields, "state")?;
    let plan = read_string_field(fields, "plan")?;
    let entitlement = read_string_field(fields, "entitlement")?;
    let allowance_fields = read_map_field(fields, "allowance")?;
    let remaining_explanation_generations =
        read_integer_field(allowance_fields, "remainingExplanationGenerations").unwrap_or(0);
    let remaining_image_generations =
        read_integer_field(allowance_fields, "remainingImageGenerations").unwrap_or(0);

    Some(SubscriptionRecord {
        state,
        plan,
        entitlement,
        allowance: AllowanceRecord {
            remaining_explanation_generations,
            remaining_image_generations,
        },
    })
}
