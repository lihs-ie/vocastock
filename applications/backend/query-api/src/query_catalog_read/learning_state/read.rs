use shared_auth::{TokenVerificationPort, VerifiedActorContext};

use super::model::{LearningStateView, ProficiencyLevel};
use super::source::LearningStateSource;
use crate::runtime::authorization::extract_bearer_token;

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum LearningStateError {
    MissingToken,
    InvalidToken,
    ReauthRequired,
    MissingIdentifier,
}

pub fn read_learning_state(
    actor_context: &VerifiedActorContext,
    vocabulary_expression: &str,
    source: &dyn LearningStateSource,
) -> Result<Option<LearningStateView>, LearningStateError> {
    if !actor_context.is_active() {
        return Err(LearningStateError::ReauthRequired);
    }

    let record = match source.record_for(actor_context, vocabulary_expression) {
        Some(record) => record,
        None => return Ok(None),
    };

    let proficiency = match ProficiencyLevel::parse(&record.proficiency) {
        Some(level) => level,
        None => return Ok(None),
    };

    Ok(Some(LearningStateView {
        vocabulary_expression: record.vocabulary_expression,
        proficiency,
        created_at: record.created_at,
        updated_at: record.updated_at,
    }))
}

pub fn read_learning_state_from_authorization_header(
    authorization_header: Option<&str>,
    vocabulary_expression: Option<&str>,
    verifier: &(impl TokenVerificationPort + ?Sized),
    source: &dyn LearningStateSource,
) -> Result<Option<LearningStateView>, LearningStateError> {
    let vocabulary_expression = vocabulary_expression
        .filter(|value| !value.is_empty())
        .ok_or(LearningStateError::MissingIdentifier)?;

    let bearer_token = extract_bearer_token(authorization_header).map_err(|error| match error {
        shared_auth::TokenVerificationError::MissingToken => LearningStateError::MissingToken,
        shared_auth::TokenVerificationError::InvalidToken => LearningStateError::InvalidToken,
        shared_auth::TokenVerificationError::ReauthRequired => LearningStateError::ReauthRequired,
    })?;
    let actor_context = verifier.verify(bearer_token).map_err(|error| match error {
        shared_auth::TokenVerificationError::MissingToken => LearningStateError::MissingToken,
        shared_auth::TokenVerificationError::InvalidToken => LearningStateError::InvalidToken,
        shared_auth::TokenVerificationError::ReauthRequired => LearningStateError::ReauthRequired,
    })?;

    read_learning_state(&actor_context, vocabulary_expression, source)
}
