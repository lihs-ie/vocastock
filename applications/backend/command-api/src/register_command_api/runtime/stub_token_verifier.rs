use shared_auth::{
    self, ActorReference, AuthAccountReference, SessionReference, SessionState,
    TokenVerificationPort, VerifiedActorContext,
};

#[derive(Clone, Debug, Default)]
pub struct StubTokenVerifier;

impl TokenVerificationPort for StubTokenVerifier {
    fn verify(
        &self,
        bearer_token: &str,
    ) -> Result<VerifiedActorContext, shared_auth::TokenVerificationError> {
        match bearer_token {
            "" => Err(shared_auth::TokenVerificationError::MissingToken),
            "valid-learner-token" => Ok(sample_actor_context("actor:learner")),
            "valid-other-token" => Ok(sample_actor_context("actor:other")),
            "reauth-token" => Err(shared_auth::TokenVerificationError::ReauthRequired),
            _ => Err(shared_auth::TokenVerificationError::InvalidToken),
        }
    }
}

fn sample_actor_context(actor_reference: &str) -> VerifiedActorContext {
    VerifiedActorContext::new(
        ActorReference::new(actor_reference),
        AuthAccountReference::new(format!("auth:{actor_reference}")),
        SessionReference::new(format!("session:{actor_reference}")),
        SessionState::Active,
    )
}
