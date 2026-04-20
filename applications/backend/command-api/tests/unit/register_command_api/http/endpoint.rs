use std::io::Cursor;

use command_api::{
    read_request, route_request, write_response, InMemoryCommandStore, InMemoryDispatchPort,
    RenderedResponse, RequestReadError, StubTokenVerifier,
};

use crate::support::{active_actor, env_lock, register_command_json, request};

#[test]
fn read_request_parses_method_path_headers_and_body() {
    let body = "{\"body\":\"ok\"}";
    let raw = format!(
        "POST /commands/register-vocabulary-expression HTTP/1.1\r\nAuthorization: Bearer valid-learner-token\r\nContent-Length: {}\r\nX-Test: value\r\n\r\n{}",
        body.len(),
        body
    );
    let mut reader = Cursor::new(raw.into_bytes());

    let request = read_request(&mut reader).expect("request should parse");

    assert_eq!(request.method, "POST");
    assert_eq!(request.path, "/commands/register-vocabulary-expression");
    assert_eq!(
        request.headers.get("authorization").map(String::as_str),
        Some("Bearer valid-learner-token")
    );
    assert_eq!(
        request.headers.get("x-test").map(String::as_str),
        Some("value")
    );
    assert_eq!(request.body, "{\"body\":\"ok\"}");
}

#[test]
fn read_request_rejects_oversized_body_before_allocation() {
    let oversized_length = 16 * 1024 + 1;
    let raw = format!(
        "POST /commands/register-vocabulary-expression HTTP/1.1\r\nContent-Length: {oversized_length}\r\n\r\n"
    );
    let mut reader = Cursor::new(raw.into_bytes());

    let error = read_request(&mut reader).expect_err("oversized request should fail");

    match error {
        RequestReadError::PayloadTooLarge {
            declared_length,
            max_length,
        } => {
            assert_eq!(declared_length, oversized_length);
            assert!(max_length < declared_length);
        }
        other => panic!("unexpected error: {other:?}"),
    }
}

#[test]
fn route_request_covers_ready_root_not_found_and_method_not_allowed() {
    let verifier = StubTokenVerifier;
    let store = InMemoryCommandStore::default();
    let dispatcher = InMemoryDispatchPort::default();

    let ready = route_request(
        &request("GET", "/readyz", None, ""),
        "/readyz",
        &verifier,
        &store,
        &dispatcher,
    );
    assert_eq!(ready.status, "200 OK");
    assert!(ready.body.contains("command-api ready"));

    let root = route_request(
        &request("GET", "/", None, ""),
        "/readyz",
        &verifier,
        &store,
        &dispatcher,
    );
    assert_eq!(root.status, "200 OK");
    assert!(root.body.contains("accepted/reused-existing"));

    let not_found = route_request(
        &request("GET", "/unknown", None, ""),
        "/readyz",
        &verifier,
        &store,
        &dispatcher,
    );
    assert_eq!(not_found.status, "404 Not Found");
    assert_eq!(not_found.body, "not found");

    let method_not_allowed = route_request(
        &request("GET", "/commands/register-vocabulary-expression", None, ""),
        "/readyz",
        &verifier,
        &store,
        &dispatcher,
    );
    assert_eq!(method_not_allowed.status, "405 Method Not Allowed");
    assert!(method_not_allowed.body.contains("method not allowed"));
}

#[test]
fn route_request_covers_success_auth_failures_and_ownership_mismatch() {
    let verifier = StubTokenVerifier;
    let store = InMemoryCommandStore::default();
    let dispatcher = InMemoryDispatchPort::default();

    let success = route_request(
        &request(
            "POST",
            "/commands/register-vocabulary-expression",
            Some("Bearer valid-learner-token"),
            register_command_json(
                "actor:learner",
                "req-http-success",
                "  Mixed   Case  ",
                None,
            )
            .as_str(),
        ),
        "/readyz",
        &verifier,
        &store,
        &dispatcher,
    );
    assert_eq!(success.status, "202 Accepted");
    assert!(success.body.contains("\"acceptance\":\"accepted\""));
    assert!(success
        .body
        .contains("\"statusHandle\":\"status:actor:learner:vocabulary:mixed-case\""));
    assert!(!success.body.contains("completedSummary"));

    let missing = route_request(
        &request(
            "POST",
            "/commands/register-vocabulary-expression",
            None,
            "{}",
        ),
        "/readyz",
        &verifier,
        &store,
        &dispatcher,
    );
    assert_eq!(missing.status, "401 Unauthorized");
    assert!(missing.body.contains("missing bearer token"));

    let invalid = route_request(
        &request(
            "POST",
            "/commands/register-vocabulary-expression",
            Some("Bearer invalid-token"),
            "{}",
        ),
        "/readyz",
        &verifier,
        &store,
        &dispatcher,
    );
    assert_eq!(invalid.status, "401 Unauthorized");
    assert!(invalid.body.contains("invalid bearer token"));

    let reauth = route_request(
        &request(
            "POST",
            "/commands/register-vocabulary-expression",
            Some("Bearer reauth-token"),
            "{}",
        ),
        "/readyz",
        &verifier,
        &store,
        &dispatcher,
    );
    assert_eq!(reauth.status, "403 Forbidden");
    assert!(reauth.body.contains("reauthentication"));

    let ownership_mismatch = route_request(
        &request(
            "POST",
            "/commands/register-vocabulary-expression",
            Some("Bearer valid-learner-token"),
            register_command_json("actor:other", "req-http-owner", "tea", None).as_str(),
        ),
        "/readyz",
        &verifier,
        &store,
        &dispatcher,
    );
    assert_eq!(ownership_mismatch.status, "403 Forbidden");
    assert!(ownership_mismatch.body.contains("ownership-mismatch"));
}

#[test]
fn route_request_covers_dispatch_failed_and_replay() {
    let verifier = StubTokenVerifier;
    let store = InMemoryCommandStore::default();
    let dispatcher = InMemoryDispatchPort::default();
    let dispatch_fail_body =
        register_command_json("actor:learner", "dispatch-fail-http", "rollback term", None);

    let failure = route_request(
        &request(
            "POST",
            "/commands/register-vocabulary-expression",
            Some("Bearer valid-learner-token"),
            dispatch_fail_body.as_str(),
        ),
        "/readyz",
        &verifier,
        &store,
        &dispatcher,
    );
    assert_eq!(failure.status, "503 Service Unavailable");
    assert!(failure.body.contains("dispatch-failed"));
    assert!(!failure.body.contains("completedSummary"));
    assert!(store
        .registration_for(active_actor().actor().as_str(), "rollback term")
        .is_none());

    let request_body =
        register_command_json("actor:learner", "req-http-replay", "coffee", Some(false));
    let accepted = route_request(
        &request(
            "POST",
            "/commands/register-vocabulary-expression",
            Some("Bearer valid-learner-token"),
            request_body.as_str(),
        ),
        "/readyz",
        &verifier,
        &store,
        &dispatcher,
    );
    let replay = route_request(
        &request(
            "POST",
            "/commands/register-vocabulary-expression",
            Some("Bearer valid-learner-token"),
            request_body.as_str(),
        ),
        "/readyz",
        &verifier,
        &store,
        &dispatcher,
    );

    assert_eq!(accepted.status, "202 Accepted");
    assert_eq!(replay.status, "202 Accepted");
    assert!(replay.body.contains("\"replayedByIdempotency\":true"));
}

#[test]
fn route_request_covers_invalid_json_malformed_auth_and_unhealthy_dependencies() {
    let verifier = StubTokenVerifier;
    let store = InMemoryCommandStore::default();
    let dispatcher = InMemoryDispatchPort::default();

    let malformed_auth = route_request(
        &request(
            "POST",
            "/commands/register-vocabulary-expression",
            Some("invalid-header"),
            "{}",
        ),
        "/readyz",
        &verifier,
        &store,
        &dispatcher,
    );
    assert_eq!(malformed_auth.status, "401 Unauthorized");
    assert!(malformed_auth.body.contains("invalid bearer token"));

    let invalid_json = route_request(
        &request(
            "POST",
            "/commands/register-vocabulary-expression",
            Some("Bearer valid-learner-token"),
            "{",
        ),
        "/readyz",
        &verifier,
        &store,
        &dispatcher,
    );
    assert_eq!(invalid_json.status, "400 Bad Request");
    assert!(invalid_json
        .body
        .contains("request body must be valid JSON"));

    let _guard = env_lock();
    unsafe {
        std::env::set_var("FIRESTORE_EMULATOR_HOST", "127.0.0.1:1");
        std::env::remove_var("STORAGE_EMULATOR_HOST");
        std::env::remove_var("FIREBASE_AUTH_EMULATOR_HOST");
        std::env::remove_var("PUBSUB_EMULATOR_HOST");
    }

    let unhealthy = route_request(
        &request("GET", "/dependencies/firebase", None, ""),
        "/readyz",
        &verifier,
        &store,
        &dispatcher,
    );
    assert_eq!(unhealthy.status, "503 Service Unavailable");
    assert!(unhealthy.body.contains("connect failed"));

    unsafe {
        std::env::remove_var("FIRESTORE_EMULATOR_HOST");
    }
}

#[test]
fn write_response_renders_http_message() {
    let mut output = Vec::new();
    write_response(
        &mut output,
        &RenderedResponse {
            status: "200 OK",
            content_type: "text/plain; charset=utf-8",
            body: "body".to_owned(),
        },
    )
    .expect("response should render");

    let rendered = String::from_utf8(output).expect("http response should be utf-8");
    assert!(rendered.starts_with("HTTP/1.1 200 OK\r\n"));
    assert!(rendered.contains("Content-Type: text/plain; charset=utf-8\r\n"));
    assert!(rendered.ends_with("\r\n\r\nbody"));
}
