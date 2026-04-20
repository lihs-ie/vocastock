use query_api::{
    CatalogReadError, CatalogVisibility, CollectionState, InMemoryCatalogProjectionSource,
    ProjectionFreshness, ProjectionSourceRecord, StubTokenVerifier, WorkflowState, ROOT_MESSAGE,
    SERVICE_NAME, VOCABULARY_CATALOG_PATH,
};

#[test]
fn crate_root_reexports_catalog_contracts() {
    assert_eq!(SERVICE_NAME, "query-api");
    assert_eq!(VOCABULARY_CATALOG_PATH, "/vocabulary-catalog");
    assert!(ROOT_MESSAGE.contains("completed summaries"));

    let _source = InMemoryCatalogProjectionSource::default();
    let _verifier = StubTokenVerifier;
    let _record = ProjectionSourceRecord::new(
        "vocabulary:test",
        "registered",
        WorkflowState::Queued,
        false,
        None,
    );

    assert_eq!(CatalogVisibility::StatusOnly, CatalogVisibility::StatusOnly);
    assert_eq!(CollectionState::Empty, CollectionState::Empty);
    assert_eq!(ProjectionFreshness::Eventual, ProjectionFreshness::Eventual);
    assert_eq!(
        CatalogReadError::InactiveSession,
        CatalogReadError::InactiveSession
    );
}
