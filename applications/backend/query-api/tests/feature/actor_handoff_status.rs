use crate::support::{assert_contains, FeatureRuntime};

#[test]
fn actor_handoff_status_reports_session_context_for_seeded_actors() {
    let runtime = FeatureRuntime::start_with_production_adapters();
    let demo_bearer = runtime.demo_bearer();

    let demo = runtime.get("/actor-handoff-status", Some(demo_bearer.as_str()));
    assert_eq!(demo.status, 200);
    assert_contains(
        &demo.body,
        "\"actor\":\"stub-actor-demo\"",
        "demo actor handoff surfaces the Firebase UID",
    );
    assert_contains(
        &demo.body,
        "\"session\":\"session:stub-actor-demo\"",
        "demo actor handoff surfaces the Firebase-derived session id",
    );
    assert_contains(
        &demo.body,
        "\"authAccount\":\"auth:demo@vocastock.test\"",
        "demo actor handoff surfaces the Firebase-derived auth account",
    );
    assert_contains(
        &demo.body,
        "\"sessionState\":\"ACTIVE\"",
        "seeded demo session is ACTIVE",
    );

    // FirebaseAuthTokenVerifier rejects non-id-token strings outright, so
    // the legacy reauth-token 200 + INACTIVE path (which depended on the
    // synthetic StubTokenVerifier returning ReauthRequired) no longer
    // applies. Unit tests for actor_handoff_status::read still exercise
    // the ReauthRequired branch against a port double.
    let invalid_token = runtime.get("/actor-handoff-status", Some("Bearer not-a-real-token"));
    assert_eq!(invalid_token.status, 401);

    let missing_token = runtime.get("/actor-handoff-status", None);
    assert_eq!(missing_token.status, 401);
}
