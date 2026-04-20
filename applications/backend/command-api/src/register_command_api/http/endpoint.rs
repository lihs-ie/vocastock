use std::collections::HashMap;
use std::io::{BufRead, Write};

use serde::Serialize;
use shared_auth::{TokenVerificationError, TokenVerificationPort};

use crate::command::{
    accept_register_command, parse_register_command, CommandFailure, RequestValidationError,
};
use crate::runtime::{
    InMemoryCommandStore, InMemoryDispatchPort, StubTokenVerifier,
    REGISTER_VOCABULARY_EXPRESSION_PATH, ROOT_MESSAGE, SERVICE_NAME,
};

const FIREBASE_DEPENDENCIES_PATH: &str = "/dependencies/firebase";
const ROOT_PATH: &str = "/";

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

pub fn read_request(reader: &mut impl BufRead) -> std::io::Result<Request> {
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
    verifier: &StubTokenVerifier,
    store: &InMemoryCommandStore,
    dispatcher: &InMemoryDispatchPort,
) -> RenderedResponse {
    match (request.method.as_str(), request.path.as_str()) {
        ("GET", path) if path == readiness_path => {
            text_response("200 OK", format!("{SERVICE_NAME} ready"))
        }
        ("GET", FIREBASE_DEPENDENCIES_PATH) => firebase_dependency_response(),
        ("GET", ROOT_PATH) => text_response("200 OK", ROOT_MESSAGE.to_owned()),
        ("POST", REGISTER_VOCABULARY_EXPRESSION_PATH) => {
            register_command_response(request, verifier, store, dispatcher)
        }
        ("GET" | "PUT" | "PATCH" | "DELETE", REGISTER_VOCABULARY_EXPRESSION_PATH) => json_response(
            "405 Method Not Allowed",
            &CommandFailure::validation_failed("method not allowed"),
        ),
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

fn register_command_response(
    request: &Request,
    verifier: &StubTokenVerifier,
    store: &InMemoryCommandStore,
    dispatcher: &InMemoryDispatchPort,
) -> RenderedResponse {
    let actor_context = match verify_actor_context(
        request.headers.get("authorization").map(String::as_str),
        verifier,
    ) {
        Ok(actor_context) => actor_context,
        Err(failure) => return json_response(failure.http_status(), &failure),
    };

    let command = match parse_register_command(&request.body, &actor_context) {
        Ok(command) => command,
        Err(error) => {
            let failure = validation_failure(&error);
            return json_response(failure.http_status(), &failure);
        }
    };

    match accept_register_command(&command, store, dispatcher) {
        Ok(result) => json_response("202 Accepted", &result),
        Err(failure) => json_response(failure.http_status(), &failure),
    }
}

#[allow(clippy::result_large_err)]
fn verify_actor_context(
    authorization_header: Option<&str>,
    verifier: &impl TokenVerificationPort,
) -> Result<shared_auth::VerifiedActorContext, CommandFailure> {
    let bearer_token =
        extract_bearer_token(authorization_header).map_err(auth_failure_from_verification_error)?;

    verifier
        .verify(bearer_token)
        .map_err(auth_failure_from_verification_error)
}

fn extract_bearer_token(
    authorization_header: Option<&str>,
) -> Result<&str, TokenVerificationError> {
    let header_value = authorization_header
        .map(str::trim)
        .filter(|value| !value.is_empty())
        .ok_or(TokenVerificationError::MissingToken)?;

    let (scheme, token) = header_value
        .split_once(' ')
        .ok_or(TokenVerificationError::InvalidToken)?;

    if !scheme.eq_ignore_ascii_case("bearer") || token.trim().is_empty() {
        return Err(TokenVerificationError::InvalidToken);
    }

    Ok(token.trim())
}

fn auth_failure_from_verification_error(error: TokenVerificationError) -> CommandFailure {
    match error {
        TokenVerificationError::MissingToken => {
            CommandFailure::auth("missing-token", error.message(), false)
        }
        TokenVerificationError::InvalidToken => {
            CommandFailure::auth("invalid-token", error.message(), false)
        }
        TokenVerificationError::ReauthRequired => {
            CommandFailure::auth("reauth-required", error.message(), true)
        }
    }
}

fn validation_failure(error: &RequestValidationError) -> CommandFailure {
    match error {
        RequestValidationError::OwnershipMismatch => CommandFailure::ownership_mismatch(),
        _ => CommandFailure::new(error.code(), error.message(), false),
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

fn json_response(status: &'static str, payload: &impl Serialize) -> RenderedResponse {
    RenderedResponse {
        status,
        content_type: "application/json; charset=utf-8",
        body: serde_json::to_string(payload).expect("response serialization should succeed"),
    }
}

fn text_response(status: &'static str, body: String) -> RenderedResponse {
    RenderedResponse {
        status,
        content_type: "text/plain; charset=utf-8",
        body,
    }
}
