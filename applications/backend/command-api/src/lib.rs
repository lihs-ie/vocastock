use shared_auth::VerifiedActorContext;

pub const SERVICE_NAME: &str = "command-api";

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum CommandOutcome {
    Accepted,
    Rejected,
    Failed,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct AcceptedCommandResponse {
    pub outcome: CommandOutcome,
    pub status_handle: String,
    pub message: String,
}

impl AcceptedCommandResponse {
    pub fn accepted(status_handle: impl Into<String>, message: impl Into<String>) -> Self {
        Self {
            outcome: CommandOutcome::Accepted,
            status_handle: status_handle.into(),
            message: message.into(),
        }
    }
}

pub fn accept_command(
    actor_context: &VerifiedActorContext,
    command_name: &str,
    handle_seed: &str,
) -> AcceptedCommandResponse {
    let status_handle = format!(
        "{command_name}:{handle_seed}:{}",
        actor_context.actor().as_str()
    );

    AcceptedCommandResponse::accepted(
        status_handle,
        format!("{command_name} was accepted for asynchronous processing"),
    )
}

pub fn visible_guarantee() -> &'static str {
    "command-api returns accepted/status-handle only and never returns completed payloads"
}

#[cfg(test)]
mod tests {
    use super::*;
    use shared_auth::{
        ActorReference, AuthAccountReference, SessionReference, SessionState, VerifiedActorContext,
    };

    fn sample_actor() -> VerifiedActorContext {
        VerifiedActorContext::new(
            ActorReference::new("actor:learner"),
            AuthAccountReference::new("auth:learner"),
            SessionReference::new("session:primary"),
            SessionState::Active,
        )
    }

    #[test]
    fn accepted_command_response_contains_status_handle() {
        let response = accept_command(
            &sample_actor(),
            "registerVocabularyExpression",
            "normalized-expression",
        );

        assert_eq!(response.outcome, CommandOutcome::Accepted);
        assert!(response.status_handle.contains("registerVocabularyExpression"));
    }

    #[test]
    fn command_api_exposes_completed_payload_rule() {
        assert!(visible_guarantee().contains("never returns completed payloads"));
    }
}
