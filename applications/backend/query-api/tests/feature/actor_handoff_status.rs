use crate::support::{assert_contains, FeatureRuntime};

#[test]
fn actor_handoff_status_reports_session_context_for_seeded_actors() {
    let runtime = FeatureRuntime::start_with_production_adapters();

    let demo = runtime.get("/actor-handoff-status", Some("Bearer valid-demo-token"));
    assert_eq!(demo.status, 200);
    assert_contains(
        &demo.body,
        "\"actor\":\"stub-actor-demo\"",
        "demo actor handoff surfaces the Firebase UID",
    );
    assert_contains(
        &demo.body,
        "\"session\":\"stub-session-demo\"",
        "demo actor handoff surfaces the stub session",
    );
    assert_contains(
        &demo.body,
        "\"authAccount\":\"stub-account-demo\"",
        "demo actor handoff surfaces the auth account",
    );
    assert_contains(
        &demo.body,
        "\"sessionState\":\"ACTIVE\"",
        "seeded demo session is ACTIVE",
    );

    let reauth = runtime.get("/actor-handoff-status", Some("Bearer reauth-token"));
    assert_eq!(
        reauth.status, 200,
        "reauth-required tokens still receive the handoff view so clients can observe the state"
    );
    assert_contains(
        &reauth.body,
        "\"sessionState\":\"INACTIVE\"",
        "reauth-required maps to INACTIVE at the contract surface",
    );
    assert_contains(
        &reauth.body,
        "\"actor\":null",
        "inactive view nulls out actor",
    );

    let missing_token = runtime.get("/actor-handoff-status", None);
    assert_eq!(missing_token.status, 401);
}
