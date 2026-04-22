use serde::{Deserialize, Serialize};

/// Public-facing envelope for the five mutation endpoints that match
/// the GraphQL `CommandResponseEnvelope` type. The register endpoint
/// retains the richer `AcceptedCommandResult` shape because gateway
/// resolvers still expose its `target` / `state` / `duplicateReuse`
/// fields for the `registerVocabularyExpression` mutation.
#[derive(Clone, Copy, Debug, Eq, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
pub enum AcceptanceOutcomeCode {
    Accepted,
    ReusedExisting,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
pub enum CommandErrorCategory {
    ValidationFailed,
    TargetMissing,
    TargetNotReady,
    DispatchFailed,
    DownstreamUnavailable,
    DownstreamAuthFailed,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct UserFacingMessage {
    pub key: String,
    pub text: String,
}

impl UserFacingMessage {
    pub fn new(key: impl Into<String>, text: impl Into<String>) -> Self {
        Self {
            key: key.into(),
            text: text.into(),
        }
    }
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct CommandResponseEnvelope {
    pub accepted: bool,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub outcome: Option<AcceptanceOutcomeCode>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub error_category: Option<CommandErrorCategory>,
    pub message: UserFacingMessage,
}

impl CommandResponseEnvelope {
    pub fn accepted(outcome: AcceptanceOutcomeCode, message: UserFacingMessage) -> Self {
        Self {
            accepted: true,
            outcome: Some(outcome),
            error_category: None,
            message,
        }
    }

    pub fn rejected(category: CommandErrorCategory, message: UserFacingMessage) -> Self {
        Self {
            accepted: false,
            outcome: None,
            error_category: Some(category),
            message,
        }
    }

    pub fn http_status(&self) -> &'static str {
        if self.accepted {
            return "202 Accepted";
        }
        match self.error_category {
            Some(CommandErrorCategory::ValidationFailed) => "400 Bad Request",
            Some(CommandErrorCategory::TargetMissing) => "404 Not Found",
            Some(CommandErrorCategory::TargetNotReady) => "409 Conflict",
            Some(CommandErrorCategory::DispatchFailed) => "503 Service Unavailable",
            Some(CommandErrorCategory::DownstreamUnavailable) => "503 Service Unavailable",
            Some(CommandErrorCategory::DownstreamAuthFailed) => "403 Forbidden",
            None => "500 Internal Server Error",
        }
    }
}
