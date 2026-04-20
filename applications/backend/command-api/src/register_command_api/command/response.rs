use serde::Serialize;

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum AcceptanceOutcome {
    Accepted,
    ReusedExisting,
}

impl AcceptanceOutcome {
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Accepted => "accepted",
            Self::ReusedExisting => "reused-existing",
        }
    }
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct TargetReference {
    pub vocabulary_expression: String,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct StateSummary {
    pub registration: String,
    pub explanation: String,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct DuplicateReuseResult {
    pub registration_state: String,
    pub explanation_state: String,
    pub restart_decision: String,
    pub restart_condition: String,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct AcceptedCommandResult {
    pub acceptance: String,
    pub target: TargetReference,
    pub state: StateSummary,
    pub status_handle: String,
    pub message: String,
    pub replayed_by_idempotency: bool,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub duplicate_reuse: Option<DuplicateReuseResult>,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct AcceptedCommandFields {
    pub target: TargetReference,
    pub state: StateSummary,
    pub status_handle: String,
    pub message: String,
    pub replayed_by_idempotency: bool,
    pub duplicate_reuse: Option<DuplicateReuseResult>,
}

impl AcceptedCommandResult {
    pub fn new(acceptance: AcceptanceOutcome, fields: AcceptedCommandFields) -> Self {
        Self {
            acceptance: acceptance.as_str().to_owned(),
            target: fields.target,
            state: fields.state,
            status_handle: fields.status_handle,
            message: fields.message,
            replayed_by_idempotency: fields.replayed_by_idempotency,
            duplicate_reuse: fields.duplicate_reuse,
        }
    }

    pub fn replay(&self) -> Self {
        let mut replayed = self.clone();
        replayed.replayed_by_idempotency = true;
        replayed
    }
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct CommandFailure {
    pub code: String,
    pub message: String,
    pub retryable: bool,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub target: Option<TargetReference>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub state: Option<StateSummary>,
}

impl CommandFailure {
    pub fn new(code: impl Into<String>, message: impl Into<String>, retryable: bool) -> Self {
        Self {
            code: code.into(),
            message: message.into(),
            retryable,
            target: None,
            state: None,
        }
    }

    pub fn auth(code: &str, message: &str, retryable: bool) -> Self {
        Self::new(code, message, retryable)
    }

    pub fn validation_failed(message: impl Into<String>) -> Self {
        Self::new("validation-failed", message, false)
    }

    pub fn ownership_mismatch() -> Self {
        Self::new(
            "ownership-mismatch",
            "actor handoff does not match bearer token",
            false,
        )
    }

    pub fn idempotency_conflict() -> Self {
        Self::new(
            "idempotency-conflict",
            "same idempotencyKey was reused for a different normalized request",
            false,
        )
    }

    pub fn dispatch_failed() -> Self {
        Self::new(
            "dispatch-failed",
            "workflow dispatch failed before the registration could be committed",
            true,
        )
    }

    pub fn internal_failure(message: impl Into<String>) -> Self {
        Self::new("internal-failure", message, true)
    }

    pub fn http_status(&self) -> &'static str {
        match self.code.as_str() {
            "missing-token" | "invalid-token" => "401 Unauthorized",
            "reauth-required" | "ownership-mismatch" => "403 Forbidden",
            "validation-failed" => "400 Bad Request",
            "idempotency-conflict" => "409 Conflict",
            "dispatch-failed" => "503 Service Unavailable",
            _ => "500 Internal Server Error",
        }
    }
}
