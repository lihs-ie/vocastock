use graphql_gateway::downstream::{
    build_register_command_body, relay_register_vocabulary_expression, translate_command_response,
    DownstreamHttpResponse, RelayClient,
};
use graphql_gateway::graphql::{UnifiedGraphqlRequest, UnifiedGraphqlRequestEnvelope};
use serde_json::json;
use std::collections::HashMap;
use std::io::{BufRead, BufReader, Read, Write};
use std::net::{TcpListener, TcpStream};
use std::thread;

#[test]
fn build_register_command_body_translates_graphql_variables_to_internal_command_shape() {
    let envelope = UnifiedGraphqlRequestEnvelope::parse(
        r#"{"query":"mutation RegisterVocabularyExpression { registerVocabularyExpression { acceptance } }","variables":{"actor":"actor:learner","idempotencyKey":"feature-command","text":"coffee","startExplanation":false}}"#,
    )
    .expect("request should parse");

    let body = build_register_command_body(&envelope).expect("command body should build");

    assert!(body.contains("\"command\":\"registerVocabularyExpression\""));
    assert!(body.contains("\"actor\":\"actor:learner\""));
    assert!(body.contains("\"idempotencyKey\":\"feature-command\""));
    assert!(body.contains("\"text\":\"coffee\""));
    assert!(body.contains("\"startExplanation\":false"));
}

#[test]
fn translate_command_response_wraps_accepted_result() {
    let response = translate_command_response(DownstreamHttpResponse {
        status_code: 202,
        headers: HashMap::new(),
        body: json!({
            "acceptance": "accepted",
            "target": {
                "vocabularyExpression": "vocabulary:coffee"
            },
            "state": {
                "registration": "registered",
                "explanation": "queued"
            },
            "statusHandle": "status:actor:learner:vocabulary:coffee",
            "message": "registerVocabularyExpression was accepted for asynchronous processing",
            "replayedByIdempotency": false
        })
        .to_string(),
    })
    .expect("accepted response should translate");

    assert!(response.contains("\"registerVocabularyExpression\""));
    assert!(response.contains("\"acceptance\":\"accepted\""));
}

#[test]
fn translate_command_response_maps_idempotency_conflict() {
    let error = translate_command_response(DownstreamHttpResponse {
        status_code: 409,
        headers: HashMap::new(),
        body: json!({
            "code": "idempotency-conflict",
            "message": "same idempotencyKey was reused for a different normalized request",
            "retryable": false
        })
        .to_string(),
    })
    .expect_err("conflict should become public failure");

    assert_eq!(error.status, "409 Conflict");
    assert_eq!(error.envelope.code, "idempotency-conflict");
}

#[test]
fn translate_command_response_maps_downstream_auth_failure() {
    let error = translate_command_response(DownstreamHttpResponse {
        status_code: 401,
        headers: HashMap::new(),
        body: json!({
            "code": "missing-token",
            "message": "missing bearer token",
            "retryable": false
        })
        .to_string(),
    })
    .expect_err("auth failure should become redacted public failure");

    assert_eq!(error.status, "401 Unauthorized");
    assert_eq!(error.envelope.code, "downstream-auth-failed");
    assert_eq!(error.envelope.message, "missing bearer token");
}

#[test]
fn build_register_command_body_rejects_missing_required_variables() {
    let envelope = UnifiedGraphqlRequestEnvelope::parse(
        r#"{"query":"mutation RegisterVocabularyExpression { registerVocabularyExpression { acceptance } }","variables":{"actor":"actor:learner","text":"coffee"}}"#,
    )
    .expect("request should parse");

    let error =
        build_register_command_body(&envelope).expect_err("missing idempotencyKey should fail");

    assert_eq!(error.envelope.code, "validation-failed");
    assert!(error.envelope.message.contains("variables.idempotencyKey"));
}

#[test]
fn build_register_command_body_rejects_non_boolean_start_explanation() {
    let envelope = UnifiedGraphqlRequestEnvelope::parse(
        r#"{"query":"mutation RegisterVocabularyExpression { registerVocabularyExpression { acceptance } }","variables":{"actor":"actor:learner","idempotencyKey":"feature-command","text":"coffee","startExplanation":"later"}}"#,
    )
    .expect("request should parse");

    let error =
        build_register_command_body(&envelope).expect_err("string startExplanation should fail");

    assert_eq!(error.envelope.code, "validation-failed");
    assert!(error
        .envelope
        .message
        .contains("variables.startExplanation"));
}

#[test]
fn translate_command_response_maps_dispatch_failed() {
    let error = translate_command_response(DownstreamHttpResponse {
        status_code: 503,
        headers: HashMap::new(),
        body: json!({
            "code": "dispatch-failed",
            "message": "command dispatch to explanation queue failed",
            "retryable": true
        })
        .to_string(),
    })
    .expect_err("dispatch failure should become public failure");

    assert_eq!(error.status, "503 Service Unavailable");
    assert_eq!(error.envelope.code, "dispatch-failed");
    assert_eq!(error.envelope.retryable, Some(true));
}

#[test]
fn translate_command_response_rejects_unexpected_failure_family() {
    let error = translate_command_response(DownstreamHttpResponse {
        status_code: 503,
        headers: HashMap::new(),
        body: json!({
            "code": "unexpected-command-failure",
            "message": "something else happened",
            "retryable": true
        })
        .to_string(),
    })
    .expect_err("unexpected failure family should fail closed");

    assert_eq!(error.envelope.code, "downstream-invalid-response");
}

#[test]
fn relay_register_vocabulary_expression_forwards_headers_and_wraps_response() {
    let (base_url, handle) = spawn_command_stub(
        "HTTP/1.1 202 Accepted\r\nContent-Type: application/json\r\nContent-Length: 249\r\nConnection: close\r\n\r\n{\"acceptance\":\"accepted\",\"target\":{\"vocabularyExpression\":\"vocabulary:coffee\"},\"state\":{\"registration\":\"registered\",\"explanation\":\"queued\"},\"statusHandle\":\"status:actor:learner:vocabulary:coffee\",\"message\":\"registerVocabularyExpression was accepted for asynchronous processing\",\"replayedByIdempotency\":false}",
    );
    let relay_client = RelayClient::new(base_url, "http://query-api:18182");
    let request = UnifiedGraphqlRequest::new(
        UnifiedGraphqlRequestEnvelope::parse(
            r#"{"query":"mutation RegisterVocabularyExpression($actor: String!, $idempotencyKey: String!, $text: String!) { registerVocabularyExpression(actor: $actor, idempotencyKey: $idempotencyKey, text: $text) { acceptance } }","operationName":"RegisterVocabularyExpression","variables":{"actor":"actor:learner","idempotencyKey":"feature-command","text":"coffee"}}"#,
        )
        .expect("request should parse"),
        Some("Bearer forwarded-token".to_owned()),
        "client-correlation".to_owned(),
    );

    let response = relay_register_vocabulary_expression(&relay_client, &request)
        .expect("relay should translate success response");
    let observed = handle.join().expect("stub should finish");

    assert!(response.contains("\"registerVocabularyExpression\""));
    assert_eq!(observed.path, "/commands/register-vocabulary-expression");
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
fn relay_register_vocabulary_expression_maps_invalid_base_url_to_downstream_unavailable() {
    let relay_client = RelayClient::new("invalid-base-url", "http://query-api:18182");
    let request = UnifiedGraphqlRequest::new(
        UnifiedGraphqlRequestEnvelope::parse(
            r#"{"query":"mutation RegisterVocabularyExpression { registerVocabularyExpression { acceptance } }","variables":{"actor":"actor:learner","idempotencyKey":"feature-command","text":"coffee"}}"#,
        )
        .expect("request should parse"),
        None,
        "client-correlation".to_owned(),
    );

    let error = relay_register_vocabulary_expression(&relay_client, &request)
        .expect_err("invalid base url should fail");

    assert_eq!(error.status, "503 Service Unavailable");
    assert_eq!(error.envelope.code, "downstream-unavailable");
}

#[test]
fn relay_register_vocabulary_expression_rejects_malformed_downstream_response() {
    let (base_url, handle) = spawn_command_stub("not-http");
    let relay_client = RelayClient::new(base_url, "http://query-api:18182");
    let request = UnifiedGraphqlRequest::new(
        UnifiedGraphqlRequestEnvelope::parse(
            r#"{"query":"mutation RegisterVocabularyExpression { registerVocabularyExpression { acceptance } }","variables":{"actor":"actor:learner","idempotencyKey":"feature-command","text":"coffee"}}"#,
        )
        .expect("request should parse"),
        None,
        "client-correlation".to_owned(),
    );

    let error = relay_register_vocabulary_expression(&relay_client, &request)
        .expect_err("malformed downstream response should fail");
    handle.join().expect("stub should finish");

    assert_eq!(error.envelope.code, "downstream-invalid-response");
}

#[test]
fn translate_command_response_rejects_invalid_json_success_body() {
    let error = translate_command_response(DownstreamHttpResponse {
        status_code: 202,
        headers: HashMap::new(),
        body: "not-json".to_owned(),
    })
    .expect_err("invalid success body should fail");

    assert_eq!(error.envelope.code, "downstream-invalid-response");
}

#[test]
fn translate_command_response_uses_default_message_for_invalid_auth_body() {
    let error = translate_command_response(DownstreamHttpResponse {
        status_code: 401,
        headers: HashMap::new(),
        body: "not-json".to_owned(),
    })
    .expect_err("invalid auth body should still map");

    assert_eq!(error.envelope.code, "downstream-auth-failed");
    assert_eq!(error.envelope.message, "downstream authentication failed");
}

#[derive(Debug)]
struct CapturedRequest {
    path: String,
    headers: HashMap<String, String>,
}

fn spawn_command_stub(raw_response: &str) -> (String, thread::JoinHandle<CapturedRequest>) {
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

    let content_length = headers
        .get("content-length")
        .and_then(|value| value.parse::<usize>().ok())
        .unwrap_or(0);
    if content_length > 0 {
        let mut body_bytes = vec![0; content_length];
        reader
            .read_exact(&mut body_bytes)
            .expect("body should read exactly");
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
