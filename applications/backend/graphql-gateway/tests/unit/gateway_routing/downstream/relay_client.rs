use std::collections::BTreeMap;
use std::io::{BufRead, BufReader, Read, Write};
use std::net::{TcpListener, TcpStream};
use std::thread;

use graphql_gateway::downstream::{parse_base_url, request_headers, RelayClient};

#[test]
fn parse_base_url_accepts_http_host_and_port() {
    let target = parse_base_url("http://command-api:18181").expect("base url should parse");

    assert_eq!(target.host, "command-api");
    assert_eq!(target.port, 18181);
}

#[test]
fn parse_base_url_rejects_missing_http_scheme() {
    let error = parse_base_url("https://command-api:18181").expect_err("https should fail");

    assert_eq!(
        error,
        graphql_gateway::downstream::RelayClientError::InvalidBaseUrl
    );
}

#[test]
fn request_headers_include_authorization_and_correlation() {
    let headers = request_headers(
        Some("Bearer forwarded-token"),
        "client-correlation",
        true,
        12,
    );

    assert!(headers.contains(&(
        "authorization".to_owned(),
        "Bearer forwarded-token".to_owned()
    )));
    assert!(headers.contains(&(
        "x-request-correlation".to_owned(),
        "client-correlation".to_owned()
    )));
    assert!(headers.contains(&("Content-Length".to_owned(), "12".to_owned())));
}

#[test]
fn relay_client_roundtrips_http_response_from_local_stub() {
    let listener = TcpListener::bind(("127.0.0.1", 0)).expect("stub listener should bind");
    let port = listener
        .local_addr()
        .expect("address should resolve")
        .port();

    let handle = thread::spawn(move || {
        let (mut stream, _) = listener.accept().expect("request should arrive");
        let request = read_stub_request(&mut stream);
        assert_eq!(request.path, "/commands/register-vocabulary-expression");
        assert_eq!(
            request.headers.get("authorization").map(String::as_str),
            Some("Bearer forwarded-token")
        );
        assert_eq!(
            request
                .headers
                .get("x-request-correlation")
                .map(String::as_str),
            Some("client-correlation")
        );
        assert!(request
            .body
            .contains("\"command\":\"registerVocabularyExpression\""));

        write!(
            stream,
            "HTTP/1.1 202 Accepted\r\nContent-Type: application/json\r\nContent-Length: {}\r\nConnection: close\r\n\r\n{{\"acceptance\":\"accepted\"}}",
            r#"{"acceptance":"accepted"}"#.len()
        )
        .expect("response should write");
    });

    let client = RelayClient::new(format!("http://127.0.0.1:{port}"), "http://query-api:18182");
    let response = client
        .send_command_json(
            "/commands/register-vocabulary-expression",
            Some("Bearer forwarded-token"),
            "client-correlation",
            r#"{"command":"registerVocabularyExpression"}"#,
        )
        .expect("stub request should succeed");

    assert_eq!(response.status_code, 202);
    assert!(response.body.contains("\"acceptance\":\"accepted\""));
    handle.join().expect("stub should finish");
}

#[test]
fn relay_client_reports_unavailable_when_port_is_closed() {
    let listener = TcpListener::bind(("127.0.0.1", 0)).expect("listener should bind");
    let port = listener
        .local_addr()
        .expect("address should resolve")
        .port();
    drop(listener);

    let client = RelayClient::new(format!("http://127.0.0.1:{port}"), "http://query-api:18182");
    let error = client
        .send_command_json(
            "/commands/register-vocabulary-expression",
            Some("Bearer forwarded-token"),
            "client-correlation",
            r#"{"command":"registerVocabularyExpression"}"#,
        )
        .expect_err("closed port should fail");

    assert_eq!(
        error,
        graphql_gateway::downstream::RelayClientError::Unavailable
    );
}

struct StubRequest {
    path: String,
    headers: BTreeMap<String, String>,
    body: String,
}

fn read_stub_request(stream: &mut TcpStream) -> StubRequest {
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

    StubRequest {
        path: request_line
            .split_whitespace()
            .nth(1)
            .unwrap_or("/")
            .to_owned(),
        headers,
        body: String::from_utf8_lossy(&body_bytes).into_owned(),
    }
}
