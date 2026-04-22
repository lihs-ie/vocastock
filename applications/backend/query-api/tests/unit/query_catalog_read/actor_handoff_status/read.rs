use query_api::{
    read_actor_handoff_status, read_actor_handoff_status_from_authorization_header,
    ActorHandoffStatusError, SessionStateCode,
};

use crate::support::StubTokenVerifier;
use crate::support::{active_actor, reauth_actor};

#[test]
fn derives_view_directly_from_verified_actor_context() {
    let view = read_actor_handoff_status(&active_actor());
    assert_eq!(view.actor.as_deref(), Some("actor:learner"));
    assert_eq!(view.session.as_deref(), Some("session:actor:learner"));
    assert_eq!(view.auth_account.as_deref(), Some("auth:actor:learner"));
    assert_eq!(view.session_state, SessionStateCode::Active);
}

#[test]
fn reauth_required_session_surfaces_inactive_state_directly() {
    let view = read_actor_handoff_status(&reauth_actor());
    assert_eq!(view.session_state, SessionStateCode::Inactive);
    assert_eq!(view.actor.as_deref(), Some("actor:learner"));
}

#[test]
fn authorization_header_variant_returns_active_for_valid_token() {
    let verifier = StubTokenVerifier;
    let view = read_actor_handoff_status_from_authorization_header(
        Some("Bearer valid-learner-token"),
        &verifier,
    )
    .expect("authorized call");
    assert_eq!(view.session_state, SessionStateCode::Active);
}

#[test]
fn reauth_token_returns_inactive_view_instead_of_403() {
    let verifier = StubTokenVerifier;
    let view =
        read_actor_handoff_status_from_authorization_header(Some("Bearer reauth-token"), &verifier)
            .expect("reauth responds with synthetic inactive view");
    assert_eq!(view.session_state, SessionStateCode::Inactive);
    assert!(view.actor.is_none());
    assert!(view.session.is_none());
    assert!(view.auth_account.is_none());
}

#[test]
fn missing_token_is_rejected() {
    let verifier = StubTokenVerifier;
    let error = read_actor_handoff_status_from_authorization_header(None, &verifier)
        .expect_err("missing header rejected");
    assert_eq!(
        error,
        ActorHandoffStatusError::Auth(shared_auth::TokenVerificationError::MissingToken)
    );
}

#[test]
fn invalid_token_is_rejected() {
    let verifier = StubTokenVerifier;
    let error = read_actor_handoff_status_from_authorization_header(Some("Bearer nope"), &verifier)
        .expect_err("invalid token rejected");
    assert_eq!(
        error,
        ActorHandoffStatusError::Auth(shared_auth::TokenVerificationError::InvalidToken)
    );
}
