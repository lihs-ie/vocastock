use std::collections::HashMap;
use std::io::{BufRead, Write};

use serde::Serialize;
use shared_auth::TokenVerificationPort;

use crate::{
    read_actor_handoff_status_from_authorization_header, read_catalog_from_authorization_header,
    read_explanation_detail_from_authorization_header, read_image_detail_from_authorization_header,
    read_subscription_status_from_authorization_header,
    read_vocabulary_expression_detail_from_authorization_header, ActorHandoffStatusError,
    CatalogProjectionSource, CatalogReadError, ExplanationDetailError, ExplanationDetailSource,
    ImageDetailError, ImageDetailSource, SubscriptionStatusError, SubscriptionStatusSource,
    VocabularyExpressionDetailError, VocabularyExpressionDetailSource, ACTOR_HANDOFF_STATUS_PATH,
    EXPLANATION_DETAIL_PATH, IMAGE_DETAIL_PATH, ROOT_MESSAGE, SERVICE_NAME,
    SUBSCRIPTION_STATUS_PATH, VOCABULARY_CATALOG_PATH, VOCABULARY_EXPRESSION_DETAIL_PATH,
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

/// Bundle of trait references needed to serve query-api requests.
/// Built in `main.rs` from the concrete Firestore adapters (or the
/// in-memory catalog fixture when production adapters are disabled).
pub struct RouteContext<'a> {
    pub readiness_path: &'a str,
    pub verifier: &'a dyn TokenVerificationPort,
    pub catalog_source: &'a dyn CatalogProjectionSource,
    pub vocabulary_expression_detail_source: Option<&'a dyn VocabularyExpressionDetailSource>,
    pub explanation_detail_source: Option<&'a dyn ExplanationDetailSource>,
    pub image_detail_source: Option<&'a dyn ImageDetailSource>,
    pub subscription_status_source: Option<&'a dyn SubscriptionStatusSource>,
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

pub fn route_request(request: &Request, ctx: &RouteContext<'_>) -> RenderedResponse {
    let (path, query) = split_path_and_query(request.path.as_str());

    match (request.method.as_str(), path) {
        ("GET", path) if path == ctx.readiness_path => {
            text_response("200 OK", format!("{SERVICE_NAME} ready"))
        }
        ("GET", FIREBASE_DEPENDENCIES_PATH) => firebase_dependency_response(),
        ("GET", ROOT_PATH) => text_response("200 OK", ROOT_MESSAGE.to_owned()),
        ("GET", VOCABULARY_CATALOG_PATH) => vocabulary_catalog_response(request, ctx),
        ("GET", VOCABULARY_EXPRESSION_DETAIL_PATH) => {
            vocabulary_expression_detail_response(request, query, ctx)
        }
        ("GET", EXPLANATION_DETAIL_PATH) => explanation_detail_response(request, query, ctx),
        ("GET", IMAGE_DETAIL_PATH) => image_detail_response(request, query, ctx),
        ("GET", SUBSCRIPTION_STATUS_PATH) => subscription_status_response(request, ctx),
        ("GET", ACTOR_HANDOFF_STATUS_PATH) => actor_handoff_status_response(request, ctx),
        (
            "POST" | "PUT" | "PATCH" | "DELETE",
            VOCABULARY_CATALOG_PATH
            | VOCABULARY_EXPRESSION_DETAIL_PATH
            | EXPLANATION_DETAIL_PATH
            | IMAGE_DETAIL_PATH
            | SUBSCRIPTION_STATUS_PATH
            | ACTOR_HANDOFF_STATUS_PATH,
        ) => json_response(
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

fn vocabulary_catalog_response(request: &Request, ctx: &RouteContext<'_>) -> RenderedResponse {
    let authorization_header = request.headers.get("authorization").map(String::as_str);

    match read_catalog_from_authorization_header(
        authorization_header,
        ctx.verifier,
        ctx.catalog_source,
    ) {
        Ok(response) => json_response("200 OK", &response),
        Err(error) => json_response(
            catalog_auth_error_status(&error),
            &ErrorResponse {
                message: error.user_message(),
            },
        ),
    }
}

fn vocabulary_expression_detail_response(
    request: &Request,
    query: Option<&str>,
    ctx: &RouteContext<'_>,
) -> RenderedResponse {
    let Some(source) = ctx.vocabulary_expression_detail_source else {
        return detail_source_unavailable();
    };
    let Some(identifier) = require_identifier(query) else {
        return missing_identifier_response();
    };
    let authorization_header = request.headers.get("authorization").map(String::as_str);

    match read_vocabulary_expression_detail_from_authorization_header(
        authorization_header,
        identifier.as_str(),
        ctx.verifier,
        source,
    ) {
        Ok(Some(view)) => json_response("200 OK", &view),
        Ok(None) => detail_not_found_response(),
        Err(error) => json_response(
            vocabulary_expression_detail_error_status(&error),
            &ErrorResponse {
                message: error.user_message(),
            },
        ),
    }
}

fn explanation_detail_response(
    request: &Request,
    query: Option<&str>,
    ctx: &RouteContext<'_>,
) -> RenderedResponse {
    let Some(source) = ctx.explanation_detail_source else {
        return detail_source_unavailable();
    };
    let Some(identifier) = require_identifier(query) else {
        return missing_identifier_response();
    };
    let authorization_header = request.headers.get("authorization").map(String::as_str);

    match read_explanation_detail_from_authorization_header(
        authorization_header,
        identifier.as_str(),
        ctx.verifier,
        source,
    ) {
        Ok(Some(view)) => json_response("200 OK", &view),
        Ok(None) => detail_not_found_response(),
        Err(error) => json_response(
            explanation_detail_error_status(&error),
            &ErrorResponse {
                message: error.user_message(),
            },
        ),
    }
}

fn image_detail_response(
    request: &Request,
    query: Option<&str>,
    ctx: &RouteContext<'_>,
) -> RenderedResponse {
    let Some(source) = ctx.image_detail_source else {
        return detail_source_unavailable();
    };
    let Some(identifier) = require_identifier(query) else {
        return missing_identifier_response();
    };
    let authorization_header = request.headers.get("authorization").map(String::as_str);

    match read_image_detail_from_authorization_header(
        authorization_header,
        identifier.as_str(),
        ctx.verifier,
        source,
    ) {
        Ok(Some(view)) => json_response("200 OK", &view),
        Ok(None) => detail_not_found_response(),
        Err(error) => json_response(
            image_detail_error_status(&error),
            &ErrorResponse {
                message: error.user_message(),
            },
        ),
    }
}

fn subscription_status_response(request: &Request, ctx: &RouteContext<'_>) -> RenderedResponse {
    let Some(source) = ctx.subscription_status_source else {
        return detail_source_unavailable();
    };
    let authorization_header = request.headers.get("authorization").map(String::as_str);

    match read_subscription_status_from_authorization_header(
        authorization_header,
        ctx.verifier,
        source,
    ) {
        Ok(view) => json_response("200 OK", &view),
        Err(error) => json_response(
            subscription_status_error_status(&error),
            &ErrorResponse {
                message: error.user_message(),
            },
        ),
    }
}

fn actor_handoff_status_response(request: &Request, ctx: &RouteContext<'_>) -> RenderedResponse {
    let authorization_header = request.headers.get("authorization").map(String::as_str);

    match read_actor_handoff_status_from_authorization_header(authorization_header, ctx.verifier) {
        Ok(view) => json_response("200 OK", &view),
        Err(error) => json_response(
            actor_handoff_status_error_status(&error),
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

fn split_path_and_query(raw: &str) -> (&str, Option<&str>) {
    match raw.split_once('?') {
        Some((path, query)) => (path, Some(query)),
        None => (raw, None),
    }
}

fn parse_query_param(query: Option<&str>, key: &str) -> Option<String> {
    let query = query?;
    query
        .split('&')
        .filter_map(|pair| pair.split_once('='))
        .find(|(name, _)| *name == key)
        .and_then(|(_, value)| percent_decode(value))
}

fn percent_decode(raw: &str) -> Option<String> {
    let mut out = Vec::with_capacity(raw.len());
    let bytes = raw.as_bytes();
    let mut index = 0;
    while index < bytes.len() {
        match bytes[index] {
            b'+' => {
                out.push(b' ');
                index += 1;
            }
            b'%' => {
                if index + 2 >= bytes.len() {
                    return None;
                }
                let high = hex_digit(bytes[index + 1])?;
                let low = hex_digit(bytes[index + 2])?;
                out.push((high << 4) | low);
                index += 3;
            }
            byte => {
                out.push(byte);
                index += 1;
            }
        }
    }
    String::from_utf8(out).ok()
}

fn hex_digit(byte: u8) -> Option<u8> {
    match byte {
        b'0'..=b'9' => Some(byte - b'0'),
        b'a'..=b'f' => Some(byte - b'a' + 10),
        b'A'..=b'F' => Some(byte - b'A' + 10),
        _ => None,
    }
}

fn require_identifier(query: Option<&str>) -> Option<String> {
    parse_query_param(query, "identifier").filter(|value| !value.trim().is_empty())
}

fn missing_identifier_response() -> RenderedResponse {
    json_response(
        "400 Bad Request",
        &ErrorResponse {
            message: "identifier is required",
        },
    )
}

fn detail_not_found_response() -> RenderedResponse {
    RenderedResponse {
        status: "200 OK",
        content_type: "application/json; charset=utf-8",
        body: "null".to_owned(),
    }
}

fn detail_source_unavailable() -> RenderedResponse {
    json_response(
        "503 Service Unavailable",
        &ErrorResponse {
            message: "detail source not configured",
        },
    )
}

fn catalog_auth_error_status(error: &CatalogReadError) -> &'static str {
    match error {
        CatalogReadError::Auth(shared_auth::TokenVerificationError::MissingToken)
        | CatalogReadError::Auth(shared_auth::TokenVerificationError::InvalidToken) => {
            "401 Unauthorized"
        }
        CatalogReadError::Auth(shared_auth::TokenVerificationError::ReauthRequired)
        | CatalogReadError::InactiveSession => "403 Forbidden",
    }
}

fn vocabulary_expression_detail_error_status(
    error: &VocabularyExpressionDetailError,
) -> &'static str {
    match error {
        VocabularyExpressionDetailError::Auth(
            shared_auth::TokenVerificationError::MissingToken,
        )
        | VocabularyExpressionDetailError::Auth(
            shared_auth::TokenVerificationError::InvalidToken,
        ) => "401 Unauthorized",
        VocabularyExpressionDetailError::Auth(
            shared_auth::TokenVerificationError::ReauthRequired,
        )
        | VocabularyExpressionDetailError::InactiveSession => "403 Forbidden",
        VocabularyExpressionDetailError::MissingIdentifier => "400 Bad Request",
    }
}

fn explanation_detail_error_status(error: &ExplanationDetailError) -> &'static str {
    match error {
        ExplanationDetailError::Auth(shared_auth::TokenVerificationError::MissingToken)
        | ExplanationDetailError::Auth(shared_auth::TokenVerificationError::InvalidToken) => {
            "401 Unauthorized"
        }
        ExplanationDetailError::Auth(shared_auth::TokenVerificationError::ReauthRequired)
        | ExplanationDetailError::InactiveSession => "403 Forbidden",
        ExplanationDetailError::MissingIdentifier => "400 Bad Request",
    }
}

fn image_detail_error_status(error: &ImageDetailError) -> &'static str {
    match error {
        ImageDetailError::Auth(shared_auth::TokenVerificationError::MissingToken)
        | ImageDetailError::Auth(shared_auth::TokenVerificationError::InvalidToken) => {
            "401 Unauthorized"
        }
        ImageDetailError::Auth(shared_auth::TokenVerificationError::ReauthRequired)
        | ImageDetailError::InactiveSession => "403 Forbidden",
        ImageDetailError::MissingIdentifier => "400 Bad Request",
    }
}

fn subscription_status_error_status(error: &SubscriptionStatusError) -> &'static str {
    match error {
        SubscriptionStatusError::Auth(shared_auth::TokenVerificationError::MissingToken)
        | SubscriptionStatusError::Auth(shared_auth::TokenVerificationError::InvalidToken) => {
            "401 Unauthorized"
        }
        SubscriptionStatusError::Auth(shared_auth::TokenVerificationError::ReauthRequired)
        | SubscriptionStatusError::InactiveSession => "403 Forbidden",
    }
}

fn actor_handoff_status_error_status(error: &ActorHandoffStatusError) -> &'static str {
    match error {
        ActorHandoffStatusError::Auth(shared_auth::TokenVerificationError::MissingToken)
        | ActorHandoffStatusError::Auth(shared_auth::TokenVerificationError::InvalidToken) => {
            "401 Unauthorized"
        }
        ActorHandoffStatusError::Auth(shared_auth::TokenVerificationError::ReauthRequired) => {
            "403 Forbidden"
        }
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
