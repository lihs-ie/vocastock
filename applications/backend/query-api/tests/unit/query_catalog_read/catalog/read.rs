use query_api::{
    read_catalog, read_catalog_from_authorization_header, CatalogReadError, CatalogVisibility,
    CollectionState, InMemoryCatalogProjectionSource, ProjectionFreshness, ProjectionSourceRecord,
    WorkflowState,
};
use shared_auth::TokenVerificationError;

use crate::support::StubTokenVerifier;
use crate::support::{active_actor, custom_source, reauth_actor};

#[test]
fn empty_collection_returns_successful_empty_response() {
    let response = read_catalog(&active_actor(), &custom_source(Vec::new()))
        .expect("empty collection should still succeed");

    assert_eq!(response.collection_state, CollectionState::Empty);
    assert!(response.items.is_empty());
    assert_eq!(response.projection_freshness, ProjectionFreshness::Eventual);
}

#[test]
fn current_explanation_available_returns_completed_summary() {
    let response = read_catalog(
        &active_actor(),
        &custom_source(vec![ProjectionSourceRecord::new(
            "vocabulary:coffee",
            "registered",
            WorkflowState::Succeeded,
            true,
            Some("Warm drink summary"),
        )]),
    )
    .expect("completed catalog item should be visible");

    assert_eq!(response.collection_state, CollectionState::Populated);
    assert_eq!(response.items.len(), 1);
    assert_eq!(
        response.items[0].visibility,
        CatalogVisibility::CompletedSummary
    );
    assert_eq!(
        response.items[0].completed_summary.as_deref(),
        Some("Warm drink summary")
    );
    assert!(response.items[0].status_reason.is_none());
}

#[test]
fn succeeded_without_current_explanation_stays_status_only() {
    let response = read_catalog(
        &active_actor(),
        &custom_source(vec![ProjectionSourceRecord::new(
            "vocabulary:stale",
            "registered",
            WorkflowState::Succeeded,
            false,
            Some("Should never leak"),
        )]),
    )
    .expect("stale read should still succeed");

    assert_eq!(response.items[0].visibility, CatalogVisibility::StatusOnly);
    assert!(response.items[0].completed_summary.is_none());
    assert_eq!(
        response.items[0].status_reason.as_deref(),
        Some("completed explanation is not yet visible")
    );
}

#[test]
fn queued_and_failure_states_stay_status_only() {
    let states = [
        WorkflowState::Queued,
        WorkflowState::Running,
        WorkflowState::RetryScheduled,
        WorkflowState::TimedOut,
        WorkflowState::FailedFinal,
        WorkflowState::DeadLettered,
    ];

    for workflow_state in states {
        let response = read_catalog(
            &active_actor(),
            &custom_source(vec![ProjectionSourceRecord::new(
                "vocabulary:item",
                "registered",
                workflow_state.clone(),
                false,
                None,
            )]),
        )
        .expect("status-only states should still read");

        assert_eq!(response.items[0].visibility, CatalogVisibility::StatusOnly);
        assert!(response.items[0].completed_summary.is_none());
        assert!(response.items[0].status_reason.is_some());
    }
}

#[test]
fn active_authorization_header_reads_catalog() {
    let response = read_catalog_from_authorization_header(
        Some("Bearer valid-learner-token"),
        &StubTokenVerifier,
        &InMemoryCatalogProjectionSource::default(),
    )
    .expect("valid bearer token should read catalog");

    assert_eq!(response.collection_state, CollectionState::Populated);
    assert_eq!(
        response.items[0].vocabulary_expression,
        "vocabulary:coffee".to_owned()
    );
}

#[test]
fn missing_token_is_rejected() {
    let error = read_catalog_from_authorization_header(
        None,
        &StubTokenVerifier,
        &InMemoryCatalogProjectionSource::default(),
    )
    .expect_err("missing token must fail");

    assert_eq!(
        error,
        CatalogReadError::Auth(TokenVerificationError::MissingToken)
    );
}

#[test]
fn invalid_token_is_rejected() {
    let error = read_catalog_from_authorization_header(
        Some("Bearer not-a-valid-token"),
        &StubTokenVerifier,
        &InMemoryCatalogProjectionSource::default(),
    )
    .expect_err("invalid token must fail");

    assert_eq!(
        error,
        CatalogReadError::Auth(TokenVerificationError::InvalidToken)
    );
}

#[test]
fn reauth_required_is_rejected() {
    let error = read_catalog_from_authorization_header(
        Some("Bearer reauth-token"),
        &StubTokenVerifier,
        &InMemoryCatalogProjectionSource::default(),
    )
    .expect_err("reauth token must fail");

    assert_eq!(
        error,
        CatalogReadError::Auth(TokenVerificationError::ReauthRequired)
    );
}

#[test]
fn non_active_sessions_are_rejected() {
    let error = read_catalog(&reauth_actor(), &InMemoryCatalogProjectionSource::default())
        .expect_err("non-active session must fail");

    assert_eq!(error, CatalogReadError::InactiveSession);
}
