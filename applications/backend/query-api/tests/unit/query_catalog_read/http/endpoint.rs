use std::collections::HashMap;
use std::io::Cursor;

use query_api::{
    InMemoryCatalogProjectionSource, Request, StubTokenVerifier, read_request, route_request,
    write_response,
};

fn request(method: &str, path: &str) -> Request {
    Request {
        method: method.to_owned(),
        path: path.to_owned(),
        headers: HashMap::new(),
    }
}

#[test]
fn read_request_parses_method_path_and_headers() {
    let raw = b"GET /vocabulary-catalog HTTP/1.1\r\nAuthorization: Bearer valid-learner-token\r\nX-Test: value\r\n\r\n";
    let mut reader = Cursor::new(raw.as_slice());

    let request = read_request(&mut reader).expect("request should parse");

    assert_eq!(request.method, "GET");
    assert_eq!(request.path, "/vocabulary-catalog");
    assert_eq!(
        request.headers.get("authorization").map(String::as_str),
        Some("Bearer valid-learner-token")
    );
    assert_eq!(request.headers.get("x-test").map(String::as_str), Some("value"));
}

#[test]
fn route_request_covers_ready_root_not_found_and_method_not_allowed() {
    let verifier = StubTokenVerifier;
    let source = InMemoryCatalogProjectionSource::default();

    let ready = route_request(&request("GET", "/readyz"), "/readyz", &verifier, &source);
    assert_eq!(ready.status, "200 OK");
    assert!(ready.body.contains("query-api ready"));

    let root = route_request(&request("GET", "/"), "/readyz", &verifier, &source);
    assert_eq!(root.status, "200 OK");
    assert!(root.body.contains("completed summaries"));

    let not_found = route_request(&request("GET", "/unknown"), "/readyz", &verifier, &source);
    assert_eq!(not_found.status, "404 Not Found");
    assert_eq!(not_found.body, "not found");

    let method_not_allowed =
        route_request(&request("POST", "/vocabulary-catalog"), "/readyz", &verifier, &source);
    assert_eq!(method_not_allowed.status, "405 Method Not Allowed");
    assert!(method_not_allowed.body.contains("method not allowed"));
}

#[test]
fn route_request_covers_catalog_success_and_auth_failures() {
    let verifier = StubTokenVerifier;
    let source = InMemoryCatalogProjectionSource::default();

    let success = route_request(
        &Request {
            method: "GET".to_owned(),
            path: "/vocabulary-catalog".to_owned(),
            headers: HashMap::from([(
                "authorization".to_owned(),
                "Bearer valid-learner-token".to_owned(),
            )]),
        },
        "/readyz",
        &verifier,
        &source,
    );
    assert_eq!(success.status, "200 OK");
    assert!(success.body.contains("\"collectionState\":\"populated\""));

    let missing = route_request(
        &request("GET", "/vocabulary-catalog"),
        "/readyz",
        &verifier,
        &source,
    );
    assert_eq!(missing.status, "401 Unauthorized");
    assert!(missing.body.contains("missing bearer token"));

    let reauth = route_request(
        &Request {
            method: "GET".to_owned(),
            path: "/vocabulary-catalog".to_owned(),
            headers: HashMap::from([(
                "authorization".to_owned(),
                "Bearer reauth-token".to_owned(),
            )]),
        },
        "/readyz",
        &verifier,
        &source,
    );
    assert_eq!(reauth.status, "403 Forbidden");
    assert!(reauth.body.contains("session requires reauthentication"));
}

#[test]
fn write_response_renders_http_message() {
    let mut output = Vec::new();
    write_response(
        &mut output,
        &query_api::RenderedResponse {
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
