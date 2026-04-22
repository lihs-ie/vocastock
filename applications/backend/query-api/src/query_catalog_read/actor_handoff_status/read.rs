use shared_auth::{self, TokenVerificationPort, VerifiedActorContext};

use super::model::{ActorHandoffStatusView, SessionStateCode};
use crate::runtime::authorization::extract_bearer_token;

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum ActorHandoffStatusError {
    Auth(shared_auth::TokenVerificationError),
}

impl ActorHandoffStatusError {
    pub fn user_message(&self) -> &'static str {
        match self {
            Self::Auth(error) => error.message(),
        }
    }
}

pub fn read_actor_handoff_status(actor_context: &VerifiedActorContext) -> ActorHandoffStatusView {
    ActorHandoffStatusView {
        actor: Some(actor_context.actor().as_str().to_owned()),
        session: Some(actor_context.session().as_str().to_owned()),
        auth_account: Some(actor_context.auth_account().as_str().to_owned()),
        session_state: SessionStateCode::from_session_state(actor_context.session_state()),
    }
}

pub fn read_actor_handoff_status_from_authorization_header(
    authorization_header: Option<&str>,
    verifier: &(impl TokenVerificationPort + ?Sized),
) -> Result<ActorHandoffStatusView, ActorHandoffStatusError> {
    let bearer_token =
        extract_bearer_token(authorization_header).map_err(ActorHandoffStatusError::Auth)?;
    match verifier.verify(bearer_token) {
        Ok(actor_context) => Ok(read_actor_handoff_status(&actor_context)),
        Err(shared_auth::TokenVerificationError::ReauthRequired) => {
            Ok(ActorHandoffStatusView::inactive_reauth_view())
        }
        Err(error) => Err(ActorHandoffStatusError::Auth(error)),
    }
}
