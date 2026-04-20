use query_api::{
    CatalogProjectionSource, InMemoryCatalogProjectionSource, ProjectionSourceRecord, WorkflowState,
};

use crate::support::{active_actor, empty_actor, other_actor};

#[test]
fn projection_source_record_new_maps_fields() {
    let record = ProjectionSourceRecord::new(
        "vocabulary:test",
        "registered",
        WorkflowState::Succeeded,
        true,
        Some("summary"),
    );

    assert_eq!(record.vocabulary_expression, "vocabulary:test");
    assert_eq!(record.registration_state, "registered");
    assert_eq!(record.latest_workflow_state, WorkflowState::Succeeded);
    assert!(record.current_explanation_available);
    assert_eq!(record.completed_summary.as_deref(), Some("summary"));
}

#[test]
fn default_source_returns_seeded_records_by_actor() {
    let source = InMemoryCatalogProjectionSource::default();

    assert_eq!(source.records_for_actor(&active_actor()).len(), 4);
    assert!(source.records_for_actor(&empty_actor()).is_empty());
    assert_eq!(source.records_for_actor(&other_actor()).len(), 1);
}

#[test]
fn default_source_returns_empty_for_unknown_actor() {
    let source = InMemoryCatalogProjectionSource::default();
    let records = source.records_for_actor(&crate::support::custom_actor("actor:missing"));

    assert!(records.is_empty());
}
