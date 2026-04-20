use graphql_gateway::downstream::{
    relay_vocabulary_catalog, translate_catalog_response, DownstreamHttpResponse, RelayClient,
};
use graphql_gateway::graphql::{UnifiedGraphqlRequest, UnifiedGraphqlRequestEnvelope};
use serde_json::json;
use std::collections::HashMap;
use std::io::{BufRead, BufReader, Write};
use std::net::{TcpListener, TcpStream};
use std::thread;

#[test]
fn translate_catalog_response_wraps_query_result() {
    let response = translate_catalog_response(DownstreamHttpResponse {
        status_code: 200,
        headers: HashMap::new(),
        body: json!({
            "collectionState": "populated",
            "projectionFreshness": "eventual",
            "items": [
                {
                    "vocabularyExpression": "vocabulary:coffee",
                    "registrationState": "registered",
                    "explanationState": "completed",
                    "visibility": "completed-summary"
                }
            ]
        })
        .to_string(),
    })
    .expect("catalog response should translate");

    assert!(response.contains("\"vocabularyCatalog\""));
    assert!(response.contains("\"collectionState\":\"populated\""));
}

#[test]
fn translate_catalog_response_maps_reauthentication_to_downstream_auth_failure() {
    let error = translate_catalog_response(DownstreamHttpResponse {
        status_code: 403,
        headers: HashMap::new(),
        body: json!({
            "message": "session requires reauthentication"
        })
        .to_string(),
    })
    .expect_err("reauth response should map to public failure");

    assert_eq!(error.status, "403 Forbidden");
    assert_eq!(error.envelope.code, "downstream-auth-failed");
    assert_eq!(error.envelope.message, "session requires reauthentication");
    assert_eq!(error.envelope.retryable, Some(true));
}

#[test]
fn translate_catalog_response_rejects_invalid_response_shape() {
    let error = translate_catalog_response(DownstreamHttpResponse {
        status_code: 200,
        headers: HashMap::new(),
        body: json!({
            "collectionState": "populated",
            "items": [
                {
                    "vocabularyExpression": "vocabulary:coffee",
                    "registrationState": "registered",
                    "explanationState": "completed",
                    "visibility": "detail"
                }
            ]
        })
        .to_string(),
    })
    .expect_err("invalid visibility should fail");

    assert_eq!(error.envelope.code, "downstream-invalid-response");
}

#[test]
fn translate_catalog_response_maps_missing_token_to_downstream_auth_failure() {
    let error = translate_catalog_response(DownstreamHttpResponse {
        status_code: 401,
        headers: HashMap::new(),
        body: json!({
            "message": "missing bearer token"
        })
        .to_string(),
    })
    .expect_err("missing token should map to public auth failure");

    assert_eq!(error.status, "401 Unauthorized");
    assert_eq!(error.envelope.code, "downstream-auth-failed");
    assert_eq!(error.envelope.message, "missing bearer token");
    assert_eq!(error.envelope.retryable, Some(false));
}

#[test]
fn translate_catalog_response_rejects_unexpected_status_code() {
    let error = translate_catalog_response(DownstreamHttpResponse {
        status_code: 500,
        headers: HashMap::new(),
        body: json!({
            "message": "internal error"
        })
        .to_string(),
    })
    .expect_err("unexpected status should fail closed");

    assert_eq!(error.envelope.code, "downstream-invalid-response");
}

#[test]
fn relay_vocabulary_catalog_forwards_headers_and_wraps_response() {
    let (base_url, handle) = spawn_query_stub(
        "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: 95\r\nConnection: close\r\n\r\n{\"collectionState\":\"empty\",\"projectionFreshness\":\"eventual\",\"items\":[]}",
    );
    let relay_client = RelayClient::new("http://command-api:18181", base_url);
    let request = UnifiedGraphqlRequest::new(
        UnifiedGraphqlRequestEnvelope::parse(
            r#"{"query":"query VocabularyCatalog { vocabularyCatalog { collectionState } }","operationName":"VocabularyCatalog"}"#,
        )
        .expect("request should parse"),
        Some("Bearer forwarded-token".to_owned()),
        "client-correlation".to_owned(),
    );

    let response =
        relay_vocabulary_catalog(&relay_client, &request).expect("catalog relay should succeed");
    let observed = handle.join().expect("stub should finish");

    assert!(response.contains("\"vocabularyCatalog\""));
    assert_eq!(observed.path, "/vocabulary-catalog");
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
}

#[test]
fn relay_vocabulary_catalog_maps_invalid_base_url_to_downstream_unavailable() {
    let relay_client = RelayClient::new("http://command-api:18181", "invalid-base-url");
    let request = UnifiedGraphqlRequest::new(
        UnifiedGraphqlRequestEnvelope::parse(
            r#"{"query":"query VocabularyCatalog { vocabularyCatalog { collectionState } }","operationName":"VocabularyCatalog"}"#,
        )
        .expect("request should parse"),
        None,
        "client-correlation".to_owned(),
    );

    let error = relay_vocabulary_catalog(&relay_client, &request)
        .expect_err("invalid base url should fail");

    assert_eq!(error.status, "503 Service Unavailable");
    assert_eq!(error.envelope.code, "downstream-unavailable");
}

#[test]
fn relay_vocabulary_catalog_rejects_malformed_downstream_response() {
    let (base_url, handle) = spawn_query_stub("not-http");
    let relay_client = RelayClient::new("http://command-api:18181", base_url);
    let request = UnifiedGraphqlRequest::new(
        UnifiedGraphqlRequestEnvelope::parse(
            r#"{"query":"query VocabularyCatalog { vocabularyCatalog { collectionState } }","operationName":"VocabularyCatalog"}"#,
        )
        .expect("request should parse"),
        None,
        "client-correlation".to_owned(),
    );

    let error = relay_vocabulary_catalog(&relay_client, &request)
        .expect_err("malformed downstream response should fail");
    handle.join().expect("stub should finish");

    assert_eq!(error.envelope.code, "downstream-invalid-response");
}

#[derive(Debug)]
struct CapturedRequest {
    path: String,
    headers: HashMap<String, String>,
}

fn spawn_query_stub(raw_response: &str) -> (String, thread::JoinHandle<CapturedRequest>) {
    let listener = TcpListener::bind(("127.0.0.1", 0)).expect("stub listener should bind");
    let port = listener
        .local_addr()
        .expect("address should resolve")
        .port();
    let raw_response = raw_response.to_owned();
    let handle = thread::spawn(move || {
        let (mut stream, _) = listener.accept().expect("request should arrive");
        let captured = read_captured_request(&mut stream);
        stream
            .write_all(raw_response.as_bytes())
            .expect("response should write");
        stream.flush().expect("response should flush");
        captured
    });

    (format!("http://127.0.0.1:{port}"), handle)
}

fn read_captured_request(stream: &mut TcpStream) -> CapturedRequest {
    let mut reader = BufReader::new(stream);
    let mut request_line = String::new();
    let mut headers = HashMap::new();
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

    CapturedRequest {
        path: request_line
            .split_whitespace()
            .nth(1)
            .unwrap_or("/")
            .to_owned(),
        headers,
    }
}
