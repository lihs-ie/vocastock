use std::collections::BTreeMap;

use shared_auth::VerifiedActorContext;

use crate::catalog_model::WorkflowState;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct ProjectionSourceRecord {
    pub vocabulary_expression: String,
    pub registration_state: String,
    pub latest_workflow_state: WorkflowState,
    pub current_explanation_available: bool,
    pub completed_summary: Option<String>,
}

impl ProjectionSourceRecord {
    pub fn new(
        vocabulary_expression: impl Into<String>,
        registration_state: impl Into<String>,
        latest_workflow_state: WorkflowState,
        current_explanation_available: bool,
        completed_summary: Option<&str>,
    ) -> Self {
        Self {
            vocabulary_expression: vocabulary_expression.into(),
            registration_state: registration_state.into(),
            latest_workflow_state,
            current_explanation_available,
            completed_summary: completed_summary.map(str::to_owned),
        }
    }
}

pub trait CatalogProjectionSource {
    fn records_for_actor(&self, actor_context: &VerifiedActorContext) -> Vec<ProjectionSourceRecord>;
}

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
