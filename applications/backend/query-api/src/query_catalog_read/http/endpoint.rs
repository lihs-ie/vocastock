use std::collections::HashMap;
use std::io::{BufRead, Write};

use serde::Serialize;

use crate::{
    read_catalog_from_authorization_header, CatalogProjectionSource, CatalogReadError,
    StubTokenVerifier, ROOT_MESSAGE, SERVICE_NAME, VOCABULARY_CATALOG_PATH,
};

const FIREBASE_DEPENDENCIES_PATH: &str = "/dependencies/firebase";
const ROOT_PATH: &str = "/";

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Request {
    pub method: String,
    pub path: String,
    pub headers: HashMap<String, String>,
}

#[derive(Debug, Serialize)]
struct ErrorResponse<'a> {
    message: &'a str,
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

    Ok(Request {
        method: request_method(request_line.as_str()).to_owned(),
        path: request_path(request_line.as_str()).to_owned(),
        headers,
    })
}

pub fn route_request(
    request: &Request,
    readiness_path: &str,
    verifier: &StubTokenVerifier,
    source: &dyn CatalogProjectionSource,
) -> RenderedResponse {
    match (request.method.as_str(), request.path.as_str()) {
        ("GET", path) if path == readiness_path => {
            text_response("200 OK", format!("{SERVICE_NAME} ready"))
        }
        ("GET", FIREBASE_DEPENDENCIES_PATH) => firebase_dependency_response(),
        ("GET", ROOT_PATH) => text_response("200 OK", ROOT_MESSAGE.to_owned()),
        ("GET", VOCABULARY_CATALOG_PATH) => vocabulary_catalog_response(request, verifier, source),
        ("POST" | "PUT" | "PATCH" | "DELETE", VOCABULARY_CATALOG_PATH) => json_response(
            "405 Method Not Allowed",
            &ErrorResponse {
                message: "method not allowed",
            },
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

fn vocabulary_catalog_response(
    request: &Request,
    verifier: &StubTokenVerifier,
    source: &(impl CatalogProjectionSource + ?Sized),
) -> RenderedResponse {
    let authorization_header = request.headers.get("authorization").map(String::as_str);

    match read_catalog_from_authorization_header(authorization_header, verifier, source) {
        Ok(response) => json_response("200 OK", &response),
        Err(error) => json_response(
            auth_error_status(&error),
            &ErrorResponse {
                message: error.user_message(),
            },
        ),
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

fn auth_error_status(error: &CatalogReadError) -> &'static str {
    match error {
        CatalogReadError::Auth(shared_auth::TokenVerificationError::MissingToken)
        | CatalogReadError::Auth(shared_auth::TokenVerificationError::InvalidToken) => {
            "401 Unauthorized"
        }
        CatalogReadError::Auth(shared_auth::TokenVerificationError::ReauthRequired)
        | CatalogReadError::InactiveSession => "403 Forbidden",
    }
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
