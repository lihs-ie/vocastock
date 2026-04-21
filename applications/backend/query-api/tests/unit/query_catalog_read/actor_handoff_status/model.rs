use query_api::{ActorHandoffStatusView, SessionStateCode};
use shared_auth::SessionState;

#[test]
fn session_state_mapping_matches_contract() {
    assert_eq!(
        SessionStateCode::from_session_state(&SessionState::Active),
        SessionStateCode::Active
    );
    assert_eq!(
        SessionStateCode::from_session_state(&SessionState::ReauthRequired),
        SessionStateCode::Inactive
    );
}

#[test]
fn view_serializes_with_graphql_session_state_code() {
    let view = ActorHandoffStatusView {
        actor: Some("stub-actor-demo".to_owned()),
        session: Some("stub-session-demo".to_owned()),
        auth_account: Some("stub-account-demo".to_owned()),
        session_state: SessionStateCode::Active,
    };
    let serialized = serde_json::to_string(&view).expect("serializes");
    assert!(serialized.contains("\"actor\":\"stub-actor-demo\""));
    assert!(serialized.contains("\"session\":\"stub-session-demo\""));
    assert!(serialized.contains("\"authAccount\":\"stub-account-demo\""));
    assert!(serialized.contains("\"sessionState\":\"ACTIVE\""));
}

#[test]
fn inactive_reauth_view_surfaces_nulls() {
    let view = ActorHandoffStatusView::inactive_reauth_view();
    let serialized = serde_json::to_string(&view).expect("serializes");
    assert!(serialized.contains("\"actor\":null"));
    assert!(serialized.contains("\"session\":null"));
    assert!(serialized.contains("\"authAccount\":null"));
    assert!(serialized.contains("\"sessionState\":\"INACTIVE\""));
}
