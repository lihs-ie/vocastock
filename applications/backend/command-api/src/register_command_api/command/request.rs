use serde::Deserialize;
use shared_auth::VerifiedActorContext;

#[derive(Clone, Debug, Eq, PartialEq, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct RegisterVocabularyCommandEnvelope {
    pub command: String,
    pub actor: String,
    pub idempotency_key: String,
    pub body: RegisterVocabularyBody,
}

#[derive(Clone, Debug, Eq, PartialEq, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct RegisterVocabularyBody {
    pub text: String,
    #[serde(default)]
    pub start_explanation: Option<bool>,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct RegisterVocabularyExpressionCommand {
    pub actor: VerifiedActorContext,
    pub idempotency_key: String,
    pub normalized_text: String,
    pub start_explanation: bool,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum RequestValidationError {
    InvalidJson,
    UnsupportedCommand,
    MissingActor,
    OwnershipMismatch,
    MissingIdempotencyKey,
    MissingText,
    InvalidText,
}

impl RequestValidationError {
    pub fn code(&self) -> &'static str {
        match self {
            Self::OwnershipMismatch => "ownership-mismatch",
            Self::InvalidJson
            | Self::UnsupportedCommand
            | Self::MissingActor
            | Self::MissingIdempotencyKey
            | Self::MissingText
            | Self::InvalidText => "validation-failed",
        }
    }

    pub fn message(&self) -> &'static str {
        match self {
            Self::InvalidJson => "request body must be valid JSON",
            Self::UnsupportedCommand => "unsupported command",
            Self::MissingActor => "actor handoff is required",
            Self::OwnershipMismatch => "actor handoff does not match bearer token",
            Self::MissingIdempotencyKey => "idempotencyKey is required",
            Self::MissingText => "body.text is required",
            Self::InvalidText => "body.text contains invalid characters",
        }
    }
}

pub fn parse_register_command(
    body: &str,
    actor_context: &VerifiedActorContext,
) -> Result<RegisterVocabularyExpressionCommand, RequestValidationError> {
    let envelope: RegisterVocabularyCommandEnvelope =
        serde_json::from_str(body).map_err(|_| RequestValidationError::InvalidJson)?;

    if envelope.command != "registerVocabularyExpression" {
        return Err(RequestValidationError::UnsupportedCommand);
    }

    let claimed_actor = envelope.actor.trim();
    if claimed_actor.is_empty() {
        return Err(RequestValidationError::MissingActor);
    }

    if claimed_actor != actor_context.actor().as_str() {
        return Err(RequestValidationError::OwnershipMismatch);
    }

    let idempotency_key = envelope.idempotency_key.trim();
    if idempotency_key.is_empty() {
        return Err(RequestValidationError::MissingIdempotencyKey);
    }

    let raw_text = envelope.body.text.as_str();
    let normalized_text = normalize_text(raw_text).ok_or_else(|| {
        if raw_text.trim().is_empty() {
            RequestValidationError::MissingText
        } else {
            RequestValidationError::InvalidText
        }
    })?;

    Ok(RegisterVocabularyExpressionCommand {
        actor: actor_context.clone(),
        idempotency_key: idempotency_key.to_owned(),
        normalized_text,
        start_explanation: envelope.body.start_explanation.unwrap_or(true),
    })
}

pub fn normalize_text(raw_text: &str) -> Option<String> {
    if raw_text
        .chars()
        .any(|character| character.is_control() && !character.is_whitespace())
    {
        return None;
    }

    let collapsed = raw_text.split_whitespace().collect::<Vec<_>>().join(" ");
    if collapsed.is_empty() {
        return None;
    }

    Some(collapsed.to_lowercase())
}
