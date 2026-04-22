use crate::support::{assert_contains, assert_not_contains, FeatureRuntime};

#[test]
fn vocabulary_catalog_runs_against_dockerized_query_api_and_firebase_emulator() {
    let runtime = FeatureRuntime::start_with_production_adapters();
    let demo_bearer = runtime.demo_bearer();
    let free_bearer = runtime.free_bearer();

    let root = runtime.get("/", None);
    assert_eq!(root.status, 200);
    assert_contains(
        &root.body,
        "query-api returns completed summaries or status-only catalog items",
        "root response",
    );

    let dependency = runtime.get("/dependencies/firebase", None);
    assert_eq!(dependency.status, 200);
    assert_contains(
        &dependency.body,
        &format!(
            "firestore=host.docker.internal:{} (reachable",
            runtime.firestore_port()
        ),
        "firebase dependency report",
    );
    assert_contains(
        &dependency.body,
        &format!(
            "storage=host.docker.internal:{} (reachable",
            runtime.storage_port()
        ),
        "firebase dependency report",
    );
    assert_contains(
        &dependency.body,
        &format!(
            "auth=host.docker.internal:{} (reachable",
            runtime.auth_port()
        ),
        "firebase dependency report",
    );

    let populated = runtime.get("/vocabulary-catalog", Some(demo_bearer.as_str()));
    assert_eq!(populated.status, 200);
    assert_contains(
        &populated.body,
        "\"collectionState\":\"populated\"",
        "catalog populated response",
    );
    assert_contains(
        &populated.body,
        "\"visibility\":\"completed-summary\"",
        "catalog populated response",
    );
    assert_contains(
        &populated.body,
        "\"visibility\":\"status-only\"",
        "catalog populated response",
    );
    assert_not_contains(
        &populated.body,
        "detailPayload",
        "catalog populated response",
    );
    assert_not_contains(
        &populated.body,
        "pending-sync",
        "catalog populated response",
    );

    let empty = runtime.get("/vocabulary-catalog", Some(free_bearer.as_str()));
    assert_eq!(empty.status, 200);
    assert_contains(&empty.body, "\"items\":[]", "empty catalog response");
    assert_contains(
        &empty.body,
        "\"collectionState\":\"empty\"",
        "empty catalog response",
    );

    let missing = runtime.get("/vocabulary-catalog", None);
    assert_eq!(missing.status, 401);
    assert_contains(
        &missing.body,
        "missing bearer token",
        "missing token response",
    );

    // The FirebaseAuthTokenVerifier rejects non-id-token strings with
    // 401 InvalidToken rather than the synthetic 403 ReauthRequired path
    // the stub used to surface. The ReauthRequired branch is unit-tested
    // against a port double in query_catalog_read::catalog::read.
    let invalid_token = runtime.get("/vocabulary-catalog", Some("Bearer not-a-real-token"));
    assert_eq!(invalid_token.status, 401);
    assert_contains(
        &invalid_token.body,
        "invalid bearer token",
        "invalid token response",
    );

    let not_found = runtime.get("/unknown", None);
    assert_eq!(not_found.status, 404);
    assert_contains(&not_found.body, "not found", "not found response");

    let method_not_allowed = runtime.post("/vocabulary-catalog", None);
    assert_eq!(method_not_allowed.status, 405);
    assert_contains(
        &method_not_allowed.body,
        "method not allowed",
        "method not allowed response",
    );
}
