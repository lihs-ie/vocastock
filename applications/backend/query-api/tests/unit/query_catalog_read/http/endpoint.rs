use std::collections::HashMap;
use std::io::Cursor;

use query_api::{
    read_request, route_request, write_response, InMemoryCatalogProjectionSource, Request,
    RouteContext, StubTokenVerifier,
};

fn request(method: &str, path: &str) -> Request {
    Request {
        method: method.to_owned(),
        path: path.to_owned(),
        headers: HashMap::new(),
    }
}

fn base_context<'a>(
    verifier: &'a StubTokenVerifier,
    catalog_source: &'a InMemoryCatalogProjectionSource,
) -> RouteContext<'a> {
    RouteContext {
        readiness_path: "/readyz",
        verifier,
        catalog_source,
        vocabulary_expression_detail_source: None,
        explanation_detail_source: None,
        image_detail_source: None,
        subscription_status_source: None,
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
    assert_eq!(
        request.headers.get("x-test").map(String::as_str),
        Some("value")
    );
}

#[test]
fn route_request_covers_ready_root_not_found_and_method_not_allowed() {
    let verifier = StubTokenVerifier;
    let source = InMemoryCatalogProjectionSource::default();
    let ctx = base_context(&verifier, &source);

    let ready = route_request(&request("GET", "/readyz"), &ctx);
    assert_eq!(ready.status, "200 OK");
    assert!(ready.body.contains("query-api ready"));

    let root = route_request(&request("GET", "/"), &ctx);
    assert_eq!(root.status, "200 OK");
    assert!(root.body.contains("completed summaries"));

    let not_found = route_request(&request("GET", "/unknown"), &ctx);
    assert_eq!(not_found.status, "404 Not Found");
    assert_eq!(not_found.body, "not found");

    let method_not_allowed = route_request(&request("POST", "/vocabulary-catalog"), &ctx);
    assert_eq!(method_not_allowed.status, "405 Method Not Allowed");
    assert!(method_not_allowed.body.contains("method not allowed"));

    let method_not_allowed_detail =
        route_request(&request("POST", "/vocabulary-expression-detail"), &ctx);
    assert_eq!(
        method_not_allowed_detail.status, "405 Method Not Allowed",
        "POST on a detail path is rejected"
    );
}

#[test]
fn route_request_covers_catalog_success_and_auth_failures() {
    let verifier = StubTokenVerifier;
    let source = InMemoryCatalogProjectionSource::default();
    let ctx = base_context(&verifier, &source);

    let success = route_request(
        &Request {
            method: "GET".to_owned(),
            path: "/vocabulary-catalog".to_owned(),
            headers: HashMap::from([(
                "authorization".to_owned(),
                "Bearer valid-learner-token".to_owned(),
            )]),
        },
        &ctx,
    );
    assert_eq!(success.status, "200 OK");
    assert!(success.body.contains("\"collectionState\":\"populated\""));

    let missing = route_request(&request("GET", "/vocabulary-catalog"), &ctx);
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
        &ctx,
    );
    assert_eq!(reauth.status, "403 Forbidden");
    assert!(reauth.body.contains("session requires reauthentication"));
}

#[test]
fn route_request_detail_endpoints_without_source_return_service_unavailable() {
    let verifier = StubTokenVerifier;
    let source = InMemoryCatalogProjectionSource::default();
    let ctx = base_context(&verifier, &source);

    let response = route_request(
        &Request {
            method: "GET".to_owned(),
            path: "/vocabulary-expression-detail?identifier=vocab:coffee".to_owned(),
            headers: HashMap::from([(
                "authorization".to_owned(),
                "Bearer valid-learner-token".to_owned(),
            )]),
        },
        &ctx,
    );
    assert_eq!(response.status, "503 Service Unavailable");
    assert!(response.body.contains("detail source not configured"));
}

#[test]
fn route_request_actor_handoff_does_not_require_detail_source() {
    let verifier = StubTokenVerifier;
    let source = InMemoryCatalogProjectionSource::default();
    let ctx = base_context(&verifier, &source);

    let response = route_request(
        &Request {
            method: "GET".to_owned(),
            path: "/actor-handoff-status".to_owned(),
            headers: HashMap::from([(
                "authorization".to_owned(),
                "Bearer valid-learner-token".to_owned(),
            )]),
        },
        &ctx,
    );
    assert_eq!(response.status, "200 OK");
    assert!(response.body.contains("\"sessionState\":\"ACTIVE\""));
    assert!(response.body.contains("\"actor\":\"actor:learner\""));

    let reauth = route_request(
        &Request {
            method: "GET".to_owned(),
            path: "/actor-handoff-status".to_owned(),
            headers: HashMap::from([(
                "authorization".to_owned(),
                "Bearer reauth-token".to_owned(),
            )]),
        },
        &ctx,
    );
    assert_eq!(reauth.status, "200 OK");
    assert!(reauth.body.contains("\"sessionState\":\"INACTIVE\""));
    assert!(reauth.body.contains("\"actor\":null"));

    let missing = route_request(&request("GET", "/actor-handoff-status"), &ctx);
    assert_eq!(missing.status, "401 Unauthorized");
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
