use query_api::{
    CatalogReadResponse, CatalogVisibility, CollectionState, ProjectionFreshness,
    VocabularyCatalogItem, WorkflowState,
};

#[test]
fn workflow_state_status_reasons_cover_all_variants() {
    assert_eq!(WorkflowState::Queued.status_reason(false), "explanation is queued");
    assert_eq!(WorkflowState::Running.status_reason(false), "explanation is running");
    assert_eq!(
        WorkflowState::RetryScheduled.status_reason(false),
        "explanation is waiting for retry"
    );
    assert_eq!(
        WorkflowState::Succeeded.status_reason(false),
        "completed explanation is not yet visible"
    );
    assert_eq!(
        WorkflowState::Succeeded.status_reason(true),
        "completed explanation is available"
    );
    assert_eq!(
        WorkflowState::TimedOut.status_reason(false),
        "explanation timed out before completion"
    );
    assert_eq!(
        WorkflowState::FailedFinal.status_reason(false),
        "explanation failed without additional retries"
    );
    assert_eq!(
        WorkflowState::DeadLettered.status_reason(false),
        "explanation moved to dead-letter handling"
    );
}

#[test]
fn catalog_models_serialize_with_expected_shape() {
    let response = CatalogReadResponse {
        items: vec![
            VocabularyCatalogItem {
                vocabulary_expression: "vocabulary:coffee".to_owned(),
                registration_state: "registered".to_owned(),
                explanation_state: WorkflowState::Succeeded,
                visibility: CatalogVisibility::CompletedSummary,
                completed_summary: Some("summary".to_owned()),
                status_reason: None,
            },
            VocabularyCatalogItem {
                vocabulary_expression: "vocabulary:orbit".to_owned(),
                registration_state: "registered".to_owned(),
                explanation_state: WorkflowState::Queued,
                visibility: CatalogVisibility::StatusOnly,
                completed_summary: None,
                status_reason: Some("queued".to_owned()),
            },
        ],
        collection_state: CollectionState::Populated,
        projection_freshness: ProjectionFreshness::Eventual,
    };

    let json = serde_json::to_string(&response).expect("serialization should succeed");

    assert!(json.contains("\"collectionState\":\"populated\""));
    assert!(json.contains("\"projectionFreshness\":\"eventual\""));
    assert!(json.contains("\"visibility\":\"completed-summary\""));
    assert!(json.contains("\"visibility\":\"status-only\""));
    assert!(json.contains("\"completedSummary\":\"summary\""));
    assert!(json.contains("\"statusReason\":\"queued\""));
}
