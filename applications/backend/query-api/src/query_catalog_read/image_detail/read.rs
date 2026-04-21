use shared_auth::{self, TokenVerificationPort, VerifiedActorContext};

use super::model::ImageDetailView;
use super::source::{ImageDetailRecord, ImageDetailSource};
use crate::runtime::authorization::extract_bearer_token;

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum ImageDetailError {
    Auth(shared_auth::TokenVerificationError),
    InactiveSession,
    MissingIdentifier,
}

impl ImageDetailError {
    pub fn user_message(&self) -> &'static str {
        match self {
            Self::Auth(error) => error.message(),
            Self::InactiveSession => "session is not active",
            Self::MissingIdentifier => "identifier is required",
        }
    }
}

pub fn read_image_detail(
    actor_context: &VerifiedActorContext,
    identifier: &str,
    source: &(impl ImageDetailSource + ?Sized),
) -> Result<Option<ImageDetailView>, ImageDetailError> {
    if !actor_context.is_active() {
        return Err(ImageDetailError::InactiveSession);
    }
    if identifier.trim().is_empty() {
        return Err(ImageDetailError::MissingIdentifier);
    }

    Ok(source.record_for(actor_context, identifier).map(map_record))
}

pub fn read_image_detail_from_authorization_header(
    authorization_header: Option<&str>,
    identifier: &str,
    verifier: &(impl TokenVerificationPort + ?Sized),
    source: &(impl ImageDetailSource + ?Sized),
) -> Result<Option<ImageDetailView>, ImageDetailError> {
    let bearer_token =
        extract_bearer_token(authorization_header).map_err(ImageDetailError::Auth)?;
    let actor_context = verifier
        .verify(bearer_token)
        .map_err(ImageDetailError::Auth)?;

    read_image_detail(&actor_context, identifier, source)
}

fn map_record(record: ImageDetailRecord) -> ImageDetailView {
    ImageDetailView {
        identifier: record.identifier,
        explanation: record.explanation,
        asset_reference: record.asset_reference,
        description: record.description,
        sense_identifier: record.sense_identifier,
        sense_label: record.sense_label,
    }
}
