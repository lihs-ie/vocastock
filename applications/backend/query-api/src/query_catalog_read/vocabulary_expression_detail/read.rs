use shared_auth::{self, TokenVerificationPort, VerifiedActorContext};

use super::model::{GenerationStatus, RegistrationStatus, VocabularyExpressionEntryView};
use super::source::{VocabularyExpressionDetailRecord, VocabularyExpressionDetailSource};
use crate::runtime::authorization::extract_bearer_token;

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum VocabularyExpressionDetailError {
    Auth(shared_auth::TokenVerificationError),
    InactiveSession,
    MissingIdentifier,
}

impl VocabularyExpressionDetailError {
    pub fn user_message(&self) -> &'static str {
        match self {
            Self::Auth(error) => error.message(),
            Self::InactiveSession => "session is not active",
            Self::MissingIdentifier => "identifier is required",
        }
    }
}

pub fn read_vocabulary_expression_detail(
    actor_context: &VerifiedActorContext,
    identifier: &str,
    source: &(impl VocabularyExpressionDetailSource + ?Sized),
) -> Result<Option<VocabularyExpressionEntryView>, VocabularyExpressionDetailError> {
    if !actor_context.is_active() {
        return Err(VocabularyExpressionDetailError::InactiveSession);
    }
    if identifier.trim().is_empty() {
        return Err(VocabularyExpressionDetailError::MissingIdentifier);
    }

    Ok(source.record_for(actor_context, identifier).map(map_record))
}

pub fn read_vocabulary_expression_detail_from_authorization_header(
    authorization_header: Option<&str>,
    identifier: &str,
    verifier: &(impl TokenVerificationPort + ?Sized),
    source: &(impl VocabularyExpressionDetailSource + ?Sized),
) -> Result<Option<VocabularyExpressionEntryView>, VocabularyExpressionDetailError> {
    let bearer_token = extract_bearer_token(authorization_header)
        .map_err(VocabularyExpressionDetailError::Auth)?;
    let actor_context = verifier
        .verify(bearer_token)
        .map_err(VocabularyExpressionDetailError::Auth)?;

    read_vocabulary_expression_detail(&actor_context, identifier, source)
}

fn map_record(record: VocabularyExpressionDetailRecord) -> VocabularyExpressionEntryView {
    VocabularyExpressionEntryView {
        identifier: record.identifier,
        text: record.text,
        registration_status: RegistrationStatus::parse(record.registration_status.as_str()),
        explanation_status: GenerationStatus::parse(record.explanation_status.as_str()),
        image_status: GenerationStatus::parse(record.image_status.as_str()),
        current_explanation: record.current_explanation,
        current_image: record.current_image,
        registered_at: record.registered_at,
    }
}
