use serde::Serialize;
use shared_auth::SessionState;

#[derive(Clone, Copy, Debug, Eq, PartialEq, Serialize)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
pub enum SessionStateCode {
    Active,
    Inactive,
    Revoked,
}

impl SessionStateCode {
    /// Maps the authentication-layer session state to the API-facing
    /// handoff code. `shared_auth::SessionState` today only carries
    /// `Active` and `ReauthRequired`, which align with `ACTIVE` and
    /// `INACTIVE` respectively. When `shared-auth` later introduces a
    /// `Revoked` variant, extend the mapping here so the contract
    /// surface stays accurate.
    pub fn from_session_state(state: &SessionState) -> Self {
        match state {
            SessionState::Active => Self::Active,
            SessionState::ReauthRequired => Self::Inactive,
        }
    }
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct ActorHandoffStatusView {
    pub actor: Option<String>,
    pub session: Option<String>,
    pub auth_account: Option<String>,
    pub session_state: SessionStateCode,
}

impl ActorHandoffStatusView {
    /// Response body for callers whose bearer token was accepted but
    /// explicitly requires reauthentication. The endpoint's purpose is
    /// to surface session-state changes to clients, so we return the
    /// `INACTIVE` view instead of rejecting the request outright.
    pub fn inactive_reauth_view() -> Self {
        Self {
            actor: None,
            session: None,
            auth_account: None,
            session_state: SessionStateCode::Inactive,
        }
    }
}
