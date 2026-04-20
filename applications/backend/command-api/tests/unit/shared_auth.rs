use shared_auth::{
    ActorReference, AuthAccountReference, SessionReference, SessionState, TokenVerificationError,
    VerifiedActorContext,
};

#[test]
fn shared_auth_context_exposes_all_references_and_session_state() {
    let context = VerifiedActorContext::new(
        ActorReference::new("actor:learner"),
        AuthAccountReference::new("auth:learner"),
        SessionReference::new("session:learner"),
        SessionState::Active,
    );

    assert_eq!(context.actor().as_str(), "actor:learner");
    assert_eq!(context.auth_account().as_str(), "auth:learner");
    assert_eq!(context.session().as_str(), "session:learner");
    assert_eq!(context.session_state(), &SessionState::Active);
    assert!(context.is_active());
}

#[test]
fn shared_auth_reauth_context_is_not_active_and_errors_have_stable_messages() {
    let context = VerifiedActorContext::new(
        ActorReference::new("actor:learner"),
        AuthAccountReference::new("auth:learner"),
        SessionReference::new("session:learner"),
        SessionState::ReauthRequired,
    );

    assert!(!context.is_active());
    assert_eq!(
        TokenVerificationError::MissingToken.message(),
        "missing bearer token"
    );
    assert_eq!(
        TokenVerificationError::InvalidToken.message(),
        "invalid bearer token"
    );
    assert_eq!(
        TokenVerificationError::ReauthRequired.message(),
        "session requires reauthentication"
    );
}
