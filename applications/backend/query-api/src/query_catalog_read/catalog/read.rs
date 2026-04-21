use shared_auth::{self, TokenVerificationPort, VerifiedActorContext};

use super::model::{
    CatalogReadResponse, CatalogVisibility, CollectionState, ProjectionFreshness,
    VocabularyCatalogItem,
};
use super::source::{CatalogProjectionSource, ProjectionSourceRecord};

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum CatalogReadError {
    Auth(shared_auth::TokenVerificationError),
    InactiveSession,
}

impl CatalogReadError {
    pub fn user_message(&self) -> &'static str {
        match self {
            Self::Auth(error) => error.message(),
            Self::InactiveSession => "session is not active",
        }
    }
}

pub fn read_catalog(
    actor_context: &VerifiedActorContext,
    source: &(impl CatalogProjectionSource + ?Sized),
) -> Result<CatalogReadResponse, CatalogReadError> {
    if !actor_context.is_active() {
        return Err(CatalogReadError::InactiveSession);
    }

    let items = source
        .records_for_actor(actor_context)
        .into_iter()
        .map(map_projection_record)
        .collect::<Vec<_>>();

    let collection_state = if items.is_empty() {
        CollectionState::Empty
    } else {
        CollectionState::Populated
    };

    Ok(CatalogReadResponse {
        items,
        collection_state,
        projection_freshness: ProjectionFreshness::Eventual,
    })
}

pub fn read_catalog_from_authorization_header(
    authorization_header: Option<&str>,
    verifier: &impl TokenVerificationPort,
    source: &(impl CatalogProjectionSource + ?Sized),
) -> Result<CatalogReadResponse, CatalogReadError> {
    let bearer_token = extract_bearer_token(authorization_header)?;
    let actor_context = verifier
        .verify(bearer_token)
        .map_err(CatalogReadError::Auth)?;

    read_catalog(&actor_context, source)
}

fn extract_bearer_token(authorization_header: Option<&str>) -> Result<&str, CatalogReadError> {
    let header_value = authorization_header
        .map(str::trim)
        .filter(|value| !value.is_empty())
        .ok_or(CatalogReadError::Auth(
            shared_auth::TokenVerificationError::MissingToken,
        ))?;

    let (scheme, token) = header_value.split_once(' ').ok_or(CatalogReadError::Auth(
        shared_auth::TokenVerificationError::InvalidToken,
    ))?;

    if !scheme.eq_ignore_ascii_case("bearer") || token.trim().is_empty() {
        return Err(CatalogReadError::Auth(
            shared_auth::TokenVerificationError::InvalidToken,
        ));
    }

    Ok(token.trim())
}

fn map_projection_record(record: ProjectionSourceRecord) -> VocabularyCatalogItem {
    let visibility = completed_visibility(&record);
    let status_reason = if visibility == CatalogVisibility::StatusOnly {
        Some(
            record
                .latest_workflow_state
                .status_reason(record.current_explanation_available)
                .to_owned(),
        )
    } else {
        None
    };
    let completed_summary = if visibility == CatalogVisibility::CompletedSummary {
        record.completed_summary.clone()
    } else {
        None
    };

    VocabularyCatalogItem {
        vocabulary_expression: record.vocabulary_expression,
        registration_state: record.registration_state,
        explanation_state: record.latest_workflow_state,
        visibility,
        completed_summary,
        status_reason,
    }
}

fn completed_visibility(record: &ProjectionSourceRecord) -> CatalogVisibility {
    if record.current_explanation_available && record.completed_summary.is_some() {
        CatalogVisibility::CompletedSummary
    } else {
        CatalogVisibility::StatusOnly
    }
}
