use serde::Serialize;

#[derive(Clone, Copy, Debug, Eq, PartialEq, Serialize)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
pub enum RegistrationStatus {
    Active,
    Archived,
}

impl RegistrationStatus {
    pub fn parse(raw: &str) -> Self {
        match raw {
            "archived" => Self::Archived,
            _ => Self::Active,
        }
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq, Serialize)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
pub enum GenerationStatus {
    Pending,
    Running,
    RetryScheduled,
    TimedOut,
    Succeeded,
    FailedFinal,
    DeadLettered,
}

impl GenerationStatus {
    pub fn parse(raw: &str) -> Self {
        match raw {
            "running" => Self::Running,
            "retryScheduled" => Self::RetryScheduled,
            "timedOut" => Self::TimedOut,
            "succeeded" => Self::Succeeded,
            "failedFinal" => Self::FailedFinal,
            "deadLettered" => Self::DeadLettered,
            _ => Self::Pending,
        }
    }
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct VocabularyExpressionEntryView {
    pub identifier: String,
    pub text: String,
    pub registration_status: RegistrationStatus,
    pub explanation_status: GenerationStatus,
    pub image_status: GenerationStatus,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub current_explanation: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub current_image: Option<String>,
    pub registered_at: String,
}
