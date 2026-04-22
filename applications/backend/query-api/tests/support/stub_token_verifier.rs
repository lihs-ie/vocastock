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
            "valid-empty-token" => Ok(sample_actor_context("actor:empty")),
            "valid-other-token" => Ok(sample_actor_context("actor:other")),
            // Tokens below resolve to the Firebase Auth UIDs that
            // `firebase/seed/fixtures.json` provisions, so that detail
            // readers backed by Firestore can exercise the seeded data
            // end-to-end.
            "valid-demo-token" => Ok(seeded_actor_context(
                "stub-actor-demo",
                "stub-account-demo",
                "stub-session-demo",
                SessionState::Active,
            )),
            "valid-free-token" => Ok(seeded_actor_context(
                "stub-actor-free",
                "stub-account-free",
                "stub-session-free",
                SessionState::Active,
            )),
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

fn seeded_actor_context(
    actor: &str,
    auth_account: &str,
    session: &str,
    session_state: SessionState,
) -> VerifiedActorContext {
    VerifiedActorContext::new(
        ActorReference::new(actor),
        AuthAccountReference::new(auth_account),
        SessionReference::new(session),
        session_state,
    )
}
