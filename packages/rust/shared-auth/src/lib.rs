#[derive(Clone, Debug, Eq, PartialEq)]
pub struct ActorReference(String);

impl ActorReference {
    pub fn new(value: impl Into<String>) -> Self {
        Self(value.into())
    }

    pub fn as_str(&self) -> &str {
        &self.0
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct AuthAccountReference(String);

impl AuthAccountReference {
    pub fn new(value: impl Into<String>) -> Self {
        Self(value.into())
    }

    pub fn as_str(&self) -> &str {
        &self.0
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct SessionReference(String);

impl SessionReference {
    pub fn new(value: impl Into<String>) -> Self {
        Self(value.into())
    }

    pub fn as_str(&self) -> &str {
        &self.0
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum SessionState {
    Active,
    ReauthRequired,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct VerifiedActorContext {
    actor: ActorReference,
    auth_account: AuthAccountReference,
    session: SessionReference,
    session_state: SessionState,
}

impl VerifiedActorContext {
    pub fn new(
        actor: ActorReference,
        auth_account: AuthAccountReference,
        session: SessionReference,
        session_state: SessionState,
    ) -> Self {
        Self {
            actor,
            auth_account,
            session,
            session_state,
        }
    }

    pub fn actor(&self) -> &ActorReference {
        &self.actor
    }

    pub fn auth_account(&self) -> &AuthAccountReference {
        &self.auth_account
    }

    pub fn session(&self) -> &SessionReference {
        &self.session
    }

    pub fn session_state(&self) -> &SessionState {
        &self.session_state
    }

    pub fn is_active(&self) -> bool {
        self.session_state == SessionState::Active
    }
}

pub trait TokenVerificationPort {
    fn verify(&self, bearer_token: &str) -> Result<VerifiedActorContext, TokenVerificationError>;
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum TokenVerificationError {
    MissingToken,
    InvalidToken,
    ReauthRequired,
}

impl TokenVerificationError {
    pub fn message(&self) -> &'static str {
        match self {
            Self::MissingToken => "missing bearer token",
            Self::InvalidToken => "invalid bearer token",
            Self::ReauthRequired => "session requires reauthentication",
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn verified_actor_context_reports_active_session() {
        let actor_context = VerifiedActorContext::new(
            ActorReference::new("actor:alice"),
            AuthAccountReference::new("auth:alice"),
            SessionReference::new("session:primary"),
            SessionState::Active,
        );

        assert!(actor_context.is_active());
        assert_eq!(actor_context.actor().as_str(), "actor:alice");
    }

    #[test]
    fn token_verification_error_exposes_stable_message() {
        assert_eq!(
            TokenVerificationError::ReauthRequired.message(),
            "session requires reauthentication"
        );
    }
}
