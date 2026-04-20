use crate::support::{assert_contains, FeatureRuntime};

#[test]
fn graphql_gateway_runs_against_dockerized_gateway_and_firebase_emulator() {
    let runtime = FeatureRuntime::start();

    let readiness = runtime.get("/readyz");
    assert_eq!(readiness.status, 200);
    assert_contains(
        &readiness.body,
        "graphql-gateway ready",
        "readiness response",
    );

    let dependency = runtime.get("/dependencies/firebase");
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

    let root = runtime.get("/");
    assert_eq!(root.status, 200);
    assert_contains(
        &root.body,
        "graphql-gateway routes mutation to command-api and query/subscription to query-api",
        "root response",
    );

    let unknown = runtime.get("/unknown");
    assert_eq!(unknown.status, 404);
    assert_contains(&unknown.body, "not found", "unknown response");
}
