//! Deterministic in-memory CatalogProjectionSource used by the query-api
//! unit suite. Lives under `tests/support/` so the production binary
//! never links the synthetic fixture corpus.

use std::collections::BTreeMap;

use query_api::{CatalogProjectionSource, ProjectionSourceRecord, WorkflowState};
use shared_auth::VerifiedActorContext;

#[derive(Clone, Debug)]
pub struct InMemoryCatalogProjectionSource {
    actor_records: BTreeMap<String, Vec<ProjectionSourceRecord>>,
}

impl Default for InMemoryCatalogProjectionSource {
    fn default() -> Self {
        let mut actor_records = BTreeMap::new();
        actor_records.insert(
            "actor:learner".to_owned(),
            vec![
                ProjectionSourceRecord::new(
                    "vocabulary:coffee",
                    "registered",
                    WorkflowState::Succeeded,
                    true,
                    Some("A warm drink often linked to study breaks."),
                ),
                ProjectionSourceRecord::new(
                    "vocabulary:orbit",
                    "registered",
                    WorkflowState::Queued,
                    false,
                    None,
                ),
                ProjectionSourceRecord::new(
                    "vocabulary:stale",
                    "registered",
                    WorkflowState::Succeeded,
                    false,
                    None,
                ),
                ProjectionSourceRecord::new(
                    "vocabulary:ember",
                    "registered",
                    WorkflowState::DeadLettered,
                    false,
                    None,
                ),
            ],
        );
        actor_records.insert("actor:empty".to_owned(), Vec::new());
        actor_records.insert(
            "actor:other".to_owned(),
            vec![ProjectionSourceRecord::new(
                "vocabulary:cadence",
                "registered",
                WorkflowState::Running,
                false,
                None,
            )],
        );

        Self { actor_records }
    }
}

impl InMemoryCatalogProjectionSource {
    pub fn from_actor_records(
        actor_records: BTreeMap<String, Vec<ProjectionSourceRecord>>,
    ) -> Self {
        Self { actor_records }
    }
}

impl CatalogProjectionSource for InMemoryCatalogProjectionSource {
    fn records_for_actor(
        &self,
        actor_context: &VerifiedActorContext,
    ) -> Vec<ProjectionSourceRecord> {
        self.actor_records
            .get(actor_context.actor().as_str())
            .cloned()
            .unwrap_or_default()
    }
}
