use serde::Serialize;

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
#[serde(rename_all = "kebab-case")]
pub enum WorkflowState {
    Queued,
    Running,
    RetryScheduled,
    Succeeded,
    TimedOut,
    FailedFinal,
    DeadLettered,
}

impl WorkflowState {
    pub fn status_reason(&self, current_explanation_available: bool) -> &'static str {
        match self {
            Self::Queued => "explanation is queued",
            Self::Running => "explanation is running",
            Self::RetryScheduled => "explanation is waiting for retry",
            Self::Succeeded if !current_explanation_available => {
                "completed explanation is not yet visible"
            }
            Self::Succeeded => "completed explanation is available",
            Self::TimedOut => "explanation timed out before completion",
            Self::FailedFinal => "explanation failed without additional retries",
            Self::DeadLettered => "explanation moved to dead-letter handling",
        }
    }
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
#[serde(rename_all = "kebab-case")]
pub enum CatalogVisibility {
    CompletedSummary,
    StatusOnly,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
#[serde(rename_all = "kebab-case")]
pub enum CollectionState {
    Empty,
    Populated,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
#[serde(rename_all = "kebab-case")]
pub enum ProjectionFreshness {
    Eventual,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct VocabularyCatalogItem {
    pub vocabulary_expression: String,
    pub registration_state: String,
    pub explanation_state: WorkflowState,
    pub visibility: CatalogVisibility,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub completed_summary: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub status_reason: Option<String>,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct CatalogReadResponse {
    pub items: Vec<VocabularyCatalogItem>,
    pub collection_state: CollectionState,
    pub projection_freshness: ProjectionFreshness,
}
