use std::collections::HashMap;
use std::fmt::{Display, Formatter};
use std::io::{BufRead, Write};

use crate::downstream::{
    relay_generic_command, relay_generic_query, relay_register_vocabulary_expression,
    relay_vocabulary_catalog, RelayClient,
};
use crate::graphql::{
    allowlisted_operation, failure_envelope::GatewayFailure, GraphqlOperationKind,
    UnifiedGraphqlRequest, UnifiedGraphqlRequestEnvelope,
    REGISTER_VOCABULARY_EXPRESSION_OPERATION, VOCABULARY_CATALOG_OPERATION,
};

use super::service_contract::{
    request_correlation_from_headers, AUTHORIZATION_HEADER, FIREBASE_DEPENDENCIES_PATH,
    GRAPHQL_PATH, ROOT_MESSAGE, ROOT_PATH, SERVICE_NAME,
};

const MAX_REQUEST_BODY_BYTES: usize = 16 * 1024;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Request {
    pub method: String,
    pub path: String,
    pub headers: HashMap<String, String>,
    pub body: String,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct RenderedResponse {
    pub status: &'static str,
    pub content_type: &'static str,
    pub body: String,
}

#[derive(Debug)]
pub enum RequestReadError {
    Io(std::io::Error),
    PayloadTooLarge {
        declared_length: usize,
        max_length: usize,
    },
}

impl Display for RequestReadError {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::Io(error) => Display::fmt(error, f),
            Self::PayloadTooLarge { max_length, .. } => {
                write!(f, "request body exceeds maximum size of {max_length} bytes")
            }
        }
    }
}

impl std::error::Error for RequestReadError {}

impl From<std::io::Error> for RequestReadError {
    fn from(error: std::io::Error) -> Self {
        Self::Io(error)
    }
}

pub fn read_request(reader: &mut impl BufRead) -> Result<Request, RequestReadError> {
    let mut request_line = String::new();
    let mut headers = HashMap::new();
    reader.read_line(&mut request_line)?;

    loop {
        let mut header_line = String::new();
        let bytes_read = reader.read_line(&mut header_line)?;
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
    if content_length > MAX_REQUEST_BODY_BYTES {
        return Err(RequestReadError::PayloadTooLarge {
            declared_length: content_length,
            max_length: MAX_REQUEST_BODY_BYTES,
        });
    }

    let mut body_bytes = vec![0; content_length];
    if content_length > 0 {
        reader.read_exact(&mut body_bytes)?;
    }

    Ok(Request {
        method: request_method(request_line.as_str()).to_owned(),
        path: request_path(request_line.as_str()).to_owned(),
        headers,
        body: String::from_utf8_lossy(&body_bytes).into_owned(),
    })
}

pub fn route_request(
    request: &Request,
    readiness_path: &str,
    relay_client: &RelayClient,
) -> RenderedResponse {
    match (request.method.as_str(), request.path.as_str()) {
        ("GET", path) if path == readiness_path => {
            text_response("200 OK", format!("{SERVICE_NAME} ready"))
        }
        ("GET", FIREBASE_DEPENDENCIES_PATH) => firebase_dependency_response(),
        ("GET", ROOT_PATH) => text_response("200 OK", ROOT_MESSAGE.to_owned()),
        ("POST", GRAPHQL_PATH) => graphql_response(request, relay_client),
        ("GET" | "PUT" | "PATCH" | "DELETE", GRAPHQL_PATH) => {
            render_gateway_failure(&GatewayFailure::validation_failed("method not allowed"))
        }
        _ => text_response("404 Not Found", "not found".to_owned()),
    }
}

pub fn write_response(writer: &mut impl Write, response: &RenderedResponse) -> std::io::Result<()> {
    write!(
        writer,
        "HTTP/1.1 {}\r\nContent-Type: {}\r\nContent-Length: {}\r\nConnection: close\r\n\r\n{}",
        response.status,
        response.content_type,
        response.body.len(),
        response.body
    )?;
    writer.flush()
}

pub fn render_gateway_failure(failure: &GatewayFailure) -> RenderedResponse {
    RenderedResponse {
        status: failure.status,
        content_type: "application/json; charset=utf-8",
        body: failure.json_body(),
    }
}

fn graphql_response(request: &Request, relay_client: &RelayClient) -> RenderedResponse {
    let envelope = match UnifiedGraphqlRequestEnvelope::parse(request.body.as_str()) {
        Ok(envelope) => envelope,
        Err(failure) => return render_gateway_failure(&failure),
    };
    let request_correlation = request_correlation_from_headers(&request.headers);
    let unified_request = UnifiedGraphqlRequest::new(
        envelope,
        request.headers.get(AUTHORIZATION_HEADER).cloned(),
        request_correlation,
    );

    let decision = match allowlisted_operation(&unified_request.envelope) {
        Ok(decision) => decision,
        Err(failure) => return render_gateway_failure(&failure),
    };

    let body = match decision.operation_name.as_str() {
        REGISTER_VOCABULARY_EXPRESSION_OPERATION => {
            relay_register_vocabulary_expression(relay_client, &unified_request)
        }
        VOCABULARY_CATALOG_OPERATION => relay_vocabulary_catalog(relay_client, &unified_request),
        _ => match decision.operation_kind {
            GraphqlOperationKind::Query => relay_generic_query(
                relay_client,
                &unified_request,
                decision.downstream_route,
                decision.operation_name.as_str(),
                decision.downstream_service,
            ),
            GraphqlOperationKind::Mutation => relay_generic_command(
                relay_client,
                &unified_request,
                decision.downstream_route,
                decision.operation_name.as_str(),
                decision.downstream_service,
            ),
        },
    };

    match body {
        Ok(body) => json_response("200 OK", body),
        Err(failure) => render_gateway_failure(&failure),
    }
}

fn firebase_dependency_response() -> RenderedResponse {
    let body = shared_runtime::firebase_dependency_report();
    let status = if shared_runtime::firebase_dependencies_healthy() {
        "200 OK"
    } else {
        "503 Service Unavailable"
    };

    text_response(status, body)
}

fn request_method(request_line: &str) -> &str {
    request_line.split_whitespace().next().unwrap_or("GET")
}

fn request_path(request_line: &str) -> &str {
    request_line.split_whitespace().nth(1).unwrap_or(ROOT_PATH)
}

fn json_response(status: &'static str, body: String) -> RenderedResponse {
    RenderedResponse {
        status,
        content_type: "application/json; charset=utf-8",
        body,
    }
}

fn text_response(status: &'static str, body: String) -> RenderedResponse {
    RenderedResponse {
        status,
        content_type: "text/plain; charset=utf-8",
        body,
    }
}
