use serde::Deserialize;
use shared_auth::VerifiedActorContext;

use crate::runtime::{DispatchKind, DispatchRequest};

use super::mutation_response::CommandErrorCategory;
use super::response::CommandFailure;

// ---------- Shared validation error ------------------------------------------

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum MutationRequestError {
    InvalidJson,
    MissingActor,
    OwnershipMismatch,
    MissingIdempotencyKey,
    MissingVocabularyExpression,
    InvalidGenerationTarget,
    MissingPlanCode,
    InvalidPlanCode,
}

impl MutationRequestError {
    pub fn to_command_failure(&self) -> CommandFailure {
        match self {
            Self::OwnershipMismatch => CommandFailure::ownership_mismatch(),
            _ => CommandFailure::new(self.code(), self.message(), false),
        }
    }

    pub fn to_error_category(&self) -> CommandErrorCategory {
        match self {
            Self::OwnershipMismatch => CommandErrorCategory::DownstreamAuthFailed,
            _ => CommandErrorCategory::ValidationFailed,
        }
    }

    pub fn code(&self) -> &'static str {
        match self {
            Self::OwnershipMismatch => "ownership-mismatch",
            _ => "validation-failed",
        }
    }

    pub fn message(&self) -> &'static str {
        match self {
            Self::InvalidJson => "request body must be valid JSON",
            Self::MissingActor => "actor handoff is required",
            Self::OwnershipMismatch => "actor handoff does not match bearer token",
            Self::MissingIdempotencyKey => "idempotencyKey is required",
            Self::MissingVocabularyExpression => "vocabularyExpression is required",
            Self::InvalidGenerationTarget => "target must be EXPLANATION or IMAGE",
            Self::MissingPlanCode => "planCode is required",
            Self::InvalidPlanCode => "planCode must be FREE, STANDARD_MONTHLY, or PRO_MONTHLY",
        }
    }
}

// ---------- GenerationTarget & PlanCode enums --------------------------------

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum GenerationTargetKind {
    Explanation,
    Image,
}

impl GenerationTargetKind {
    pub fn parse(raw: &str) -> Option<Self> {
        match raw {
            "EXPLANATION" | "explanation" => Some(Self::Explanation),
            "IMAGE" | "image" => Some(Self::Image),
            _ => None,
        }
    }

    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Explanation => "EXPLANATION",
            Self::Image => "IMAGE",
        }
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum PlanCode {
    Free,
    StandardMonthly,
    ProMonthly,
}

impl PlanCode {
    pub fn parse(raw: &str) -> Option<Self> {
        match raw {
            "FREE" | "free" => Some(Self::Free),
            "STANDARD_MONTHLY" | "standardMonthly" => Some(Self::StandardMonthly),
            "PRO_MONTHLY" | "proMonthly" => Some(Self::ProMonthly),
            _ => None,
        }
    }

    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Free => "FREE",
            Self::StandardMonthly => "STANDARD_MONTHLY",
            Self::ProMonthly => "PRO_MONTHLY",
        }
    }
}

// ---------- Command types ----------------------------------------------------

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct RequestExplanationGenerationCommand {
    pub actor: VerifiedActorContext,
    pub idempotency_key: String,
    pub vocabulary_expression: String,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct RequestImageGenerationCommand {
    pub actor: VerifiedActorContext,
    pub idempotency_key: String,
    pub vocabulary_expression: String,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct RetryGenerationCommand {
    pub actor: VerifiedActorContext,
    pub idempotency_key: String,
    pub vocabulary_expression: String,
    pub target: GenerationTargetKind,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct RequestPurchaseCommand {
    pub actor: VerifiedActorContext,
    pub idempotency_key: String,
    pub plan_code: PlanCode,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct RequestRestorePurchaseCommand {
    pub actor: VerifiedActorContext,
    pub idempotency_key: String,
}

// ---------- JSON envelopes ---------------------------------------------------

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
struct GenerationRequestEnvelope {
    actor: String,
    idempotency_key: String,
    vocabulary_expression: String,
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
struct RetryRequestEnvelope {
    actor: String,
    idempotency_key: String,
    vocabulary_expression: String,
    target: String,
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
struct PurchaseRequestEnvelope {
    actor: String,
    idempotency_key: String,
    plan_code: String,
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
struct RestorePurchaseRequestEnvelope {
    actor: String,
    idempotency_key: String,
}

// ---------- Parsers ----------------------------------------------------------

pub fn parse_request_explanation_generation(
    body: &str,
    actor_context: &VerifiedActorContext,
) -> Result<RequestExplanationGenerationCommand, MutationRequestError> {
    let envelope: GenerationRequestEnvelope =
        serde_json::from_str(body).map_err(|_| MutationRequestError::InvalidJson)?;
    let (actor, idempotency_key) =
        validate_actor_and_key(&envelope.actor, &envelope.idempotency_key, actor_context)?;
    let vocabulary_expression = validate_vocabulary_expression(&envelope.vocabulary_expression)?;
    Ok(RequestExplanationGenerationCommand {
        actor,
        idempotency_key,
        vocabulary_expression,
    })
}

pub fn parse_request_image_generation(
    body: &str,
    actor_context: &VerifiedActorContext,
) -> Result<RequestImageGenerationCommand, MutationRequestError> {
    let envelope: GenerationRequestEnvelope =
        serde_json::from_str(body).map_err(|_| MutationRequestError::InvalidJson)?;
    let (actor, idempotency_key) =
        validate_actor_and_key(&envelope.actor, &envelope.idempotency_key, actor_context)?;
    let vocabulary_expression = validate_vocabulary_expression(&envelope.vocabulary_expression)?;
    Ok(RequestImageGenerationCommand {
        actor,
        idempotency_key,
        vocabulary_expression,
    })
}

pub fn parse_retry_generation(
    body: &str,
    actor_context: &VerifiedActorContext,
) -> Result<RetryGenerationCommand, MutationRequestError> {
    let envelope: RetryRequestEnvelope =
        serde_json::from_str(body).map_err(|_| MutationRequestError::InvalidJson)?;
    let (actor, idempotency_key) =
        validate_actor_and_key(&envelope.actor, &envelope.idempotency_key, actor_context)?;
    let vocabulary_expression = validate_vocabulary_expression(&envelope.vocabulary_expression)?;
    let target = GenerationTargetKind::parse(envelope.target.trim())
        .ok_or(MutationRequestError::InvalidGenerationTarget)?;
    Ok(RetryGenerationCommand {
        actor,
        idempotency_key,
        vocabulary_expression,
        target,
    })
}

pub fn parse_request_purchase(
    body: &str,
    actor_context: &VerifiedActorContext,
) -> Result<RequestPurchaseCommand, MutationRequestError> {
    let envelope: PurchaseRequestEnvelope =
        serde_json::from_str(body).map_err(|_| MutationRequestError::InvalidJson)?;
    let (actor, idempotency_key) =
        validate_actor_and_key(&envelope.actor, &envelope.idempotency_key, actor_context)?;
    let raw_plan = envelope.plan_code.trim();
    if raw_plan.is_empty() {
        return Err(MutationRequestError::MissingPlanCode);
    }
    let plan_code = PlanCode::parse(raw_plan).ok_or(MutationRequestError::InvalidPlanCode)?;
    Ok(RequestPurchaseCommand {
        actor,
        idempotency_key,
        plan_code,
    })
}

pub fn parse_request_restore_purchase(
    body: &str,
    actor_context: &VerifiedActorContext,
) -> Result<RequestRestorePurchaseCommand, MutationRequestError> {
    let envelope: RestorePurchaseRequestEnvelope =
        serde_json::from_str(body).map_err(|_| MutationRequestError::InvalidJson)?;
    let (actor, idempotency_key) =
        validate_actor_and_key(&envelope.actor, &envelope.idempotency_key, actor_context)?;
    Ok(RequestRestorePurchaseCommand {
        actor,
        idempotency_key,
    })
}

fn validate_actor_and_key(
    claimed_actor: &str,
    idempotency_key: &str,
    actor_context: &VerifiedActorContext,
) -> Result<(VerifiedActorContext, String), MutationRequestError> {
    let claimed_actor = claimed_actor.trim();
    if claimed_actor.is_empty() {
        return Err(MutationRequestError::MissingActor);
    }
    if claimed_actor != actor_context.actor().as_str() {
        return Err(MutationRequestError::OwnershipMismatch);
    }
    let idempotency_key = idempotency_key.trim();
    if idempotency_key.is_empty() {
        return Err(MutationRequestError::MissingIdempotencyKey);
    }
    Ok((actor_context.clone(), idempotency_key.to_owned()))
}

fn validate_vocabulary_expression(raw: &str) -> Result<String, MutationRequestError> {
    let trimmed = raw.trim();
    if trimmed.is_empty() {
        return Err(MutationRequestError::MissingVocabularyExpression);
    }
    Ok(trimmed.to_owned())
}

// ---------- MutationCommand trait + impls ------------------------------------

use super::mutation_response::{AcceptanceOutcomeCode, CommandResponseEnvelope, UserFacingMessage};
use crate::runtime::MutationFingerprint;

/// Common surface for the five mutation commands used by
/// `accept_mutation_command`.
pub trait MutationCommand {
    fn command_name(&self) -> &'static str;
    fn actor_reference(&self) -> &str;
    fn idempotency_key(&self) -> &str;
    fn payload_hash(&self) -> String;
    fn dispatch_request(&self) -> DispatchRequest;
    fn success_message(&self) -> UserFacingMessage;
}

impl MutationCommand for RequestExplanationGenerationCommand {
    fn command_name(&self) -> &'static str {
        "requestExplanationGeneration"
    }
    fn actor_reference(&self) -> &str {
        self.actor.actor().as_str()
    }
    fn idempotency_key(&self) -> &str {
        &self.idempotency_key
    }
    fn payload_hash(&self) -> String {
        format!("vocab={}", self.vocabulary_expression)
    }
    fn dispatch_request(&self) -> DispatchRequest {
        DispatchRequest::new(
            self.actor_reference(),
            self.idempotency_key.as_str(),
            "",
            self.vocabulary_expression.as_str(),
            false,
        )
        .with_kind(DispatchKind::ExplanationGeneration)
    }
    fn success_message(&self) -> UserFacingMessage {
        UserFacingMessage::new(
            "command.explanation_generation_queued",
            "explanation generation request accepted",
        )
    }
}

impl MutationCommand for RequestImageGenerationCommand {
    fn command_name(&self) -> &'static str {
        "requestImageGeneration"
    }
    fn actor_reference(&self) -> &str {
        self.actor.actor().as_str()
    }
    fn idempotency_key(&self) -> &str {
        &self.idempotency_key
    }
    fn payload_hash(&self) -> String {
        format!("vocab={}", self.vocabulary_expression)
    }
    fn dispatch_request(&self) -> DispatchRequest {
        DispatchRequest::new(
            self.actor_reference(),
            self.idempotency_key.as_str(),
            "",
            self.vocabulary_expression.as_str(),
            false,
        )
        .with_kind(DispatchKind::ImageGeneration)
    }
    fn success_message(&self) -> UserFacingMessage {
        UserFacingMessage::new(
            "command.image_generation_queued",
            "image generation request accepted",
        )
    }
}

impl MutationCommand for RetryGenerationCommand {
    fn command_name(&self) -> &'static str {
        "retryGeneration"
    }
    fn actor_reference(&self) -> &str {
        self.actor.actor().as_str()
    }
    fn idempotency_key(&self) -> &str {
        &self.idempotency_key
    }
    fn payload_hash(&self) -> String {
        format!(
            "vocab={}|target={}",
            self.vocabulary_expression,
            self.target.as_str()
        )
    }
    fn dispatch_request(&self) -> DispatchRequest {
        DispatchRequest::new(
            self.actor_reference(),
            self.idempotency_key.as_str(),
            "",
            self.vocabulary_expression.as_str(),
            true,
        )
        .with_kind(DispatchKind::Retry)
        .with_retry_target(self.target.as_str().to_owned())
    }
    fn success_message(&self) -> UserFacingMessage {
        UserFacingMessage::new("command.retry_generation_queued", "retry request accepted")
    }
}

impl MutationCommand for RequestPurchaseCommand {
    fn command_name(&self) -> &'static str {
        "requestPurchase"
    }
    fn actor_reference(&self) -> &str {
        self.actor.actor().as_str()
    }
    fn idempotency_key(&self) -> &str {
        &self.idempotency_key
    }
    fn payload_hash(&self) -> String {
        format!("plan={}", self.plan_code.as_str())
    }
    fn dispatch_request(&self) -> DispatchRequest {
        DispatchRequest::new(
            self.actor_reference(),
            self.idempotency_key.as_str(),
            "",
            "",
            false,
        )
        .with_kind(DispatchKind::Purchase)
        .with_plan_code(self.plan_code.as_str().to_owned())
    }
    fn success_message(&self) -> UserFacingMessage {
        UserFacingMessage::new(
            "command.purchase_queued",
            "purchase request accepted for processing",
        )
    }
}

impl MutationCommand for RequestRestorePurchaseCommand {
    fn command_name(&self) -> &'static str {
        "requestRestorePurchase"
    }
    fn actor_reference(&self) -> &str {
        self.actor.actor().as_str()
    }
    fn idempotency_key(&self) -> &str {
        &self.idempotency_key
    }
    fn payload_hash(&self) -> String {
        "restore".to_owned()
    }
    fn dispatch_request(&self) -> DispatchRequest {
        DispatchRequest::new(
            self.actor_reference(),
            self.idempotency_key.as_str(),
            "",
            "",
            false,
        )
        .with_kind(DispatchKind::RestorePurchase)
    }
    fn success_message(&self) -> UserFacingMessage {
        UserFacingMessage::new(
            "command.restore_purchase_queued",
            "restore purchase request accepted",
        )
    }
}

// ---------- Fingerprint helper ----------------------------------------------

pub fn fingerprint_for<C: MutationCommand + ?Sized>(command: &C) -> MutationFingerprint {
    MutationFingerprint::new(command.command_name(), command.payload_hash())
}

/// Builder used by acceptance logic to construct a success envelope.
pub fn success_envelope<C: MutationCommand + ?Sized>(command: &C) -> CommandResponseEnvelope {
    CommandResponseEnvelope::accepted(AcceptanceOutcomeCode::Accepted, command.success_message())
}
