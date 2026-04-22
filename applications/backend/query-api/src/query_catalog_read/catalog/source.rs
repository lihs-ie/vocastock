use shared_auth::VerifiedActorContext;

use super::model::WorkflowState;

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
    fn records_for_actor(
        &self,
        actor_context: &VerifiedActorContext,
    ) -> Vec<ProjectionSourceRecord>;
}
