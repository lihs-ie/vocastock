use graphql_gateway::downstream::RelayClient;
use graphql_gateway::graphql::failure_envelope::GatewayFailure;
use graphql_gateway::runtime::http_endpoint::{
    read_request, render_gateway_failure, route_request, Request, RequestReadError,
};
use graphql_gateway::runtime::service_contract::GRAPHQL_PATH;
use std::collections::{BTreeMap, HashMap};
use std::io::{BufRead, BufReader, Cursor, Read, Write};
use std::net::{TcpListener, TcpStream};
use std::thread;

use crate::support::env_lock;

#[test]
fn route_request_preserves_readiness_and_root_routes() {
    let relay_client = RelayClient::new("http://command-api:18181", "http://query-api:18182");

    let readiness = route_request(
        &Request {
            method: "GET".to_owned(),
            path: "/readyz".to_owned(),
            headers: HashMap::new(),
            body: String::new(),
        },
        "/readyz",
        &relay_client,
    );
    assert_eq!(readiness.status, "200 OK");
    assert!(readiness.body.contains("graphql-gateway ready"));

    let root = route_request(
        &Request {
            method: "GET".to_owned(),
            path: "/".to_owned(),
            headers: HashMap::new(),
            body: String::new(),
        },
        "/readyz",
        &relay_client,
    );
    assert_eq!(root.status, "200 OK");
    assert!(root.body.contains("/graphql"));
}

#[test]
fn route_request_rejects_method_not_allowed_for_graphql() {
    let relay_client = RelayClient::new("http://command-api:18181", "http://query-api:18182");
    let response = route_request(
        &Request {
            method: "GET".to_owned(),
            path: GRAPHQL_PATH.to_owned(),
            headers: HashMap::new(),
            body: String::new(),
        },
        "/readyz",
        &relay_client,
    );

    assert_eq!(response.status, "400 Bad Request");
    assert!(response.body.contains("\"code\":\"validation-failed\""));
    assert!(response.body.contains("method not allowed"));
}

#[test]
fn route_request_rejects_unsupported_operation_before_downstream_call() {
    let relay_client = RelayClient::new("http://127.0.0.1:9", "http://127.0.0.1:9");
    let response = route_request(
        &Request {
            method: "POST".to_owned(),
            path: GRAPHQL_PATH.to_owned(),
            headers: HashMap::new(),
            body: r#"{"query":"query UnsupportedOperation { vocabularyDetail { identifier } }"}"#
                .to_owned(),
        },
        "/readyz",
        &relay_client,
    );

    assert_eq!(response.status, "400 Bad Request");
    assert!(response.body.contains("\"code\":\"unsupported-operation\""));
}

#[test]
fn render_gateway_failure_uses_common_error_envelope() {
    let rendered =
        render_gateway_failure(&GatewayFailure::downstream_invalid_response("query-api"));

    assert_eq!(rendered.status, "502 Bad Gateway");
    assert_eq!(rendered.content_type, "application/json; charset=utf-8");
    assert!(rendered.body.contains("\"errors\""));
    assert!(rendered
        .body
        .contains("\"code\":\"downstream-invalid-response\""));
}

#[test]
fn read_request_reads_method_path_headers_and_body() {
    let body = "{\"query\":\"{ }\"}";
    let raw_request = concat!(
        "POST /graphql HTTP/1.1\r\n",
        "Host: localhost:18180\r\n",
        "Authorization: Bearer forwarded-token\r\n",
        "Content-Length: "
    );
    let raw_request = format!("{raw_request}{}\r\n\r\n{body}", body.len());
    let mut reader = Cursor::new(raw_request.as_bytes());

    let request = read_request(&mut reader).expect("request should read");

    assert_eq!(request.method, "POST");
    assert_eq!(request.path, "/graphql");
    assert_eq!(
        request.headers.get("authorization").map(String::as_str),
        Some("Bearer forwarded-token")
    );
    assert_eq!(request.body, body);
}

#[test]
fn read_request_rejects_payload_larger_than_limit() {
    let raw_request = format!(
        "POST /graphql HTTP/1.1\r\nHost: localhost:18180\r\nContent-Length: {}\r\n\r\n",
        16 * 1024 + 1
    );
    let mut reader = Cursor::new(raw_request.into_bytes());

    let error = read_request(&mut reader).expect_err("oversized request should fail");

    assert_eq!(
        error.to_string(),
        "request body exceeds maximum size of 16384 bytes"
    );
    assert!(matches!(
        error,
        RequestReadError::PayloadTooLarge {
            declared_length: 16385,
            max_length: 16384
        }
    ));
}

#[test]
fn route_request_relays_mutation_success_and_headers() {
    let (command_base_url, handle) = spawn_stub_server(
        "202 Accepted",
        r#"{"acceptance":"accepted","target":{"vocabularyExpression":"vocabulary:coffee"},"state":{"registration":"registered","explanation":"queued"},"statusHandle":"status:actor:learner:vocabulary:coffee","message":"registerVocabularyExpression was accepted for asynchronous processing","replayedByIdempotency":false}"#,
    );
    let relay_client = RelayClient::new(command_base_url, "http://127.0.0.1:9");
    let response = route_request(
        &Request {
            method: "POST".to_owned(),
            path: GRAPHQL_PATH.to_owned(),
            headers: HashMap::from([
                (
                    "authorization".to_owned(),
                    "Bearer forwarded-token".to_owned(),
                ),
                (
                    "x-request-correlation".to_owned(),
                    "client-correlation".to_owned(),
                ),
            ]),
            body: r#"{"query":"mutation RegisterVocabularyExpression($actor: String!, $idempotencyKey: String!, $text: String!) { registerVocabularyExpression(actor: $actor, idempotencyKey: $idempotencyKey, text: $text) { acceptance } }","operationName":"RegisterVocabularyExpression","variables":{"actor":"actor:learner","idempotencyKey":"feature-command","text":"coffee"}}"#.to_owned(),
        },
        "/readyz",
        &relay_client,
    );

    let observed = handle.join().expect("stub should complete");

    assert_eq!(response.status, "200 OK");
    assert!(response.body.contains("\"registerVocabularyExpression\""));
    assert_eq!(
        observed.headers.get("authorization").map(String::as_str),
        Some("Bearer forwarded-token")
    );
    assert_eq!(
        observed
            .headers
            .get("x-request-correlation")
            .map(String::as_str),
        Some("client-correlation")
    );
    assert!(observed
        .body
        .contains("\"command\":\"registerVocabularyExpression\""));
}

#[test]
fn route_request_maps_query_auth_failure_from_downstream() {
    let (query_base_url, handle) = spawn_stub_server(
        "403 Forbidden",
        r#"{"message":"session requires reauthentication","retryable":true}"#,
    );
    let relay_client = RelayClient::new("http://127.0.0.1:9", query_base_url);
    let response = route_request(
        &Request {
            method: "POST".to_owned(),
            path: GRAPHQL_PATH.to_owned(),
            headers: HashMap::new(),
            body: r#"{"query":"query VocabularyCatalog { vocabularyCatalog { collectionState } }","operationName":"VocabularyCatalog"}"#.to_owned(),
        },
        "/readyz",
        &relay_client,
    );

    let observed = handle.join().expect("stub should complete");

    assert_eq!(response.status, "403 Forbidden");
    assert_eq!(observed.path, "/vocabulary-catalog");
    assert!(response
        .body
        .contains("\"code\":\"downstream-auth-failed\""));
    assert!(response.body.contains("\"retryable\":true"));
}

#[test]
fn route_request_reports_firebase_dependency_health() {
    let _guard = env_lock();
    let listener = TcpListener::bind(("127.0.0.1", 0)).expect("listener should bind");
    let address = listener.local_addr().expect("address should resolve");

    unsafe {
        std::env::set_var("FIRESTORE_EMULATOR_HOST", address.to_string());
        std::env::remove_var("STORAGE_EMULATOR_HOST");
        std::env::remove_var("FIREBASE_AUTH_EMULATOR_HOST");
        std::env::remove_var("PUBSUB_EMULATOR_HOST");
    }

    let relay_client = RelayClient::new("http://command-api:18181", "http://query-api:18182");
    let response = route_request(
        &Request {
            method: "GET".to_owned(),
            path: "/dependencies/firebase".to_owned(),
            headers: HashMap::new(),
            body: String::new(),
        },
        "/readyz",
        &relay_client,
    );

    assert_eq!(response.status, "200 OK");
    assert!(response.body.contains("firestore="));
    assert!(response.body.contains("reachable via"));

    unsafe {
        std::env::remove_var("FIRESTORE_EMULATOR_HOST");
    }
}

#[test]
fn route_request_reports_unhealthy_firebase_dependencies() {
    let _guard = env_lock();
    let listener = TcpListener::bind(("127.0.0.1", 0)).expect("listener should bind");
    let address = listener.local_addr().expect("address should resolve");
    drop(listener);

    unsafe {
        std::env::set_var("FIRESTORE_EMULATOR_HOST", address.to_string());
        std::env::remove_var("STORAGE_EMULATOR_HOST");
        std::env::remove_var("FIREBASE_AUTH_EMULATOR_HOST");
        std::env::remove_var("PUBSUB_EMULATOR_HOST");
    }

    let relay_client = RelayClient::new("http://command-api:18181", "http://query-api:18182");
    let response = route_request(
        &Request {
            method: "GET".to_owned(),
            path: "/dependencies/firebase".to_owned(),
            headers: HashMap::new(),
            body: String::new(),
        },
        "/readyz",
        &relay_client,
    );

    assert_eq!(response.status, "503 Service Unavailable");
    assert!(response.body.contains("connect failed"));

    unsafe {
        std::env::remove_var("FIRESTORE_EMULATOR_HOST");
    }
}

#[test]
fn route_request_returns_not_found_for_unknown_path() {
    let relay_client = RelayClient::new("http://command-api:18181", "http://query-api:18182");
    let response = route_request(
        &Request {
            method: "GET".to_owned(),
            path: "/unknown".to_owned(),
            headers: HashMap::new(),
            body: String::new(),
        },
        "/readyz",
        &relay_client,
    );

    assert_eq!(response.status, "404 Not Found");
    assert_eq!(response.body, "not found");
}

#[test]
fn write_response_renders_complete_http_message() {
    let mut output = Vec::new();
    let response = graphql_gateway::runtime::http_endpoint::RenderedResponse {
        status: "200 OK",
        content_type: "application/json; charset=utf-8",
        body: "{\"ok\":true}".to_owned(),
    };

    graphql_gateway::runtime::http_endpoint::write_response(&mut output, &response)
        .expect("response should write");

    let rendered = String::from_utf8(output).expect("utf8 response");
    assert!(rendered.starts_with("HTTP/1.1 200 OK\r\n"));
    assert!(rendered.contains("Content-Type: application/json; charset=utf-8\r\n"));
    assert!(rendered.ends_with("{\"ok\":true}"));
}

#[derive(Debug)]
struct ObservedRequest {
    path: String,
    headers: BTreeMap<String, String>,
    body: String,
}

fn spawn_stub_server(
    status: &str,
    response_body: &str,
) -> (String, thread::JoinHandle<ObservedRequest>) {
    let listener = TcpListener::bind(("127.0.0.1", 0)).expect("stub listener should bind");
    let port = listener
        .local_addr()
        .expect("address should resolve")
        .port();
    let status = status.to_owned();
    let response_body = response_body.to_owned();

    let handle = thread::spawn(move || {
        let (mut stream, _) = listener.accept().expect("request should arrive");
        let observed = read_stub_request(&mut stream);
        write!(
            stream,
            "HTTP/1.1 {}\r\nContent-Type: application/json\r\nContent-Length: {}\r\nConnection: close\r\n\r\n{}",
            status,
            response_body.len(),
            response_body
        )
        .expect("response should write");
        observed
    });

    (format!("http://127.0.0.1:{port}"), handle)
}

fn read_stub_request(stream: &mut TcpStream) -> ObservedRequest {
    let mut reader = BufReader::new(stream);
    let mut request_line = String::new();
    let mut headers = BTreeMap::new();
    reader
        .read_line(&mut request_line)
        .expect("request line should read");

    loop {
        let mut header_line = String::new();
        let bytes_read = reader
            .read_line(&mut header_line)
            .expect("header line should read");
        if bytes_read == 0 || header_line == "\r\n" {
            break;
        }
        if let Some((name, value)) = header_line.split_once(':') {
            headers.insert(name.trim().to_ascii_lowercase(), value.trim().to_owned());
        }
    }

    let content_length = headers
        .get("content-length")
        .and_then(|value| value.parse::<usize>().ok())
        .unwrap_or(0);
    let mut body_bytes = vec![0; content_length];
    if content_length > 0 {
        reader
            .read_exact(&mut body_bytes)
            .expect("body should read exactly");
    }

    ObservedRequest {
        path: request_line
            .split_whitespace()
            .nth(1)
            .unwrap_or("/")
            .to_owned(),
        headers,
        body: String::from_utf8_lossy(&body_bytes).into_owned(),
    }
}
