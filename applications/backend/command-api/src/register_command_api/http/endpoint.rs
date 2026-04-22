use std::collections::HashMap;
use std::fmt::{Display, Formatter};
use std::io::{BufRead, Write};

use serde::Serialize;
use shared_auth::{TokenVerificationError, TokenVerificationPort, VerifiedActorContext};

use crate::command::{
    accept_mutation_command, accept_register_command, parse_register_command,
    parse_request_explanation_generation, parse_request_image_generation, parse_request_purchase,
    parse_request_restore_purchase, parse_retry_generation, CommandErrorCategory, CommandFailure,
    CommandResponseEnvelope, MutationRequestError, RequestValidationError, UserFacingMessage,
};
use crate::runtime::{
    CommandStore, DispatchPort, MutationCommandStore, REGISTER_VOCABULARY_EXPRESSION_PATH,
    REQUEST_EXPLANATION_GENERATION_PATH, REQUEST_IMAGE_GENERATION_PATH, REQUEST_PURCHASE_PATH,
    REQUEST_RESTORE_PURCHASE_PATH, RETRY_GENERATION_PATH, ROOT_MESSAGE, SERVICE_NAME,
};

const FIREBASE_DEPENDENCIES_PATH: &str = "/dependencies/firebase";
const MAX_REQUEST_BODY_BYTES: usize = 16 * 1024;
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

/// Bundle of trait references needed to serve command-api requests.
pub struct RouteContext<'a> {
    pub readiness_path: &'a str,
    pub verifier: &'a dyn TokenVerificationPort,
    pub register_store: &'a dyn CommandStore,
    pub mutation_store: Option<&'a dyn MutationCommandStore>,
    pub dispatcher: &'a dyn DispatchPort,
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

pub fn route_request(request: &Request, ctx: &RouteContext<'_>) -> RenderedResponse {
    match (request.method.as_str(), request.path.as_str()) {
        ("GET", path) if path == ctx.readiness_path => {
            text_response("200 OK", format!("{SERVICE_NAME} ready"))
        }
        ("GET", FIREBASE_DEPENDENCIES_PATH) => firebase_dependency_response(),
        ("GET", ROOT_PATH) => text_response("200 OK", ROOT_MESSAGE.to_owned()),
        ("POST", REGISTER_VOCABULARY_EXPRESSION_PATH) => register_command_response(request, ctx),
        ("POST", REQUEST_EXPLANATION_GENERATION_PATH) => {
            explanation_generation_response(request, ctx)
        }
        ("POST", REQUEST_IMAGE_GENERATION_PATH) => image_generation_response(request, ctx),
        ("POST", RETRY_GENERATION_PATH) => retry_generation_response(request, ctx),
        ("POST", REQUEST_PURCHASE_PATH) => purchase_response(request, ctx),
        ("POST", REQUEST_RESTORE_PURCHASE_PATH) => restore_purchase_response(request, ctx),
        (
            "GET" | "PUT" | "PATCH" | "DELETE",
            REGISTER_VOCABULARY_EXPRESSION_PATH
            | REQUEST_EXPLANATION_GENERATION_PATH
            | REQUEST_IMAGE_GENERATION_PATH
            | RETRY_GENERATION_PATH
            | REQUEST_PURCHASE_PATH
            | REQUEST_RESTORE_PURCHASE_PATH,
        ) => json_response(
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

fn register_command_response(request: &Request, ctx: &RouteContext<'_>) -> RenderedResponse {
    let actor_context = match verify_actor_context(
        request.headers.get("authorization").map(String::as_str),
        ctx.verifier,
    ) {
        Ok(actor_context) => actor_context,
        Err(failure) => return render_command_failure(&failure),
    };

    let command = match parse_register_command(&request.body, &actor_context) {
        Ok(command) => command,
        Err(error) => {
            let failure = validation_failure(&error);
            return render_command_failure(&failure);
        }
    };

    match accept_register_command(&command, ctx.register_store, ctx.dispatcher) {
        Ok(result) => json_response("202 Accepted", &result),
        Err(failure) => render_command_failure(&failure),
    }
}

fn explanation_generation_response(request: &Request, ctx: &RouteContext<'_>) -> RenderedResponse {
    let Some(mutation_store) = ctx.mutation_store else {
        return render_envelope(&mutation_source_unavailable());
    };
    let actor_context = match verify_actor_context_for_mutation(request, ctx) {
        Ok(actor) => actor,
        Err(envelope) => return render_envelope(&envelope),
    };
    let command = match parse_request_explanation_generation(&request.body, &actor_context) {
        Ok(command) => command,
        Err(error) => return render_envelope(&mutation_validation_envelope(&error)),
    };
    let envelope = accept_mutation_command(&command, mutation_store, ctx.dispatcher);
    render_envelope(&envelope)
}

fn image_generation_response(request: &Request, ctx: &RouteContext<'_>) -> RenderedResponse {
    let Some(mutation_store) = ctx.mutation_store else {
        return render_envelope(&mutation_source_unavailable());
    };
    let actor_context = match verify_actor_context_for_mutation(request, ctx) {
        Ok(actor) => actor,
        Err(envelope) => return render_envelope(&envelope),
    };
    let command = match parse_request_image_generation(&request.body, &actor_context) {
        Ok(command) => command,
        Err(error) => return render_envelope(&mutation_validation_envelope(&error)),
    };
    let envelope = accept_mutation_command(&command, mutation_store, ctx.dispatcher);
    render_envelope(&envelope)
}

fn retry_generation_response(request: &Request, ctx: &RouteContext<'_>) -> RenderedResponse {
    let Some(mutation_store) = ctx.mutation_store else {
        return render_envelope(&mutation_source_unavailable());
    };
    let actor_context = match verify_actor_context_for_mutation(request, ctx) {
        Ok(actor) => actor,
        Err(envelope) => return render_envelope(&envelope),
    };
    let command = match parse_retry_generation(&request.body, &actor_context) {
        Ok(command) => command,
        Err(error) => return render_envelope(&mutation_validation_envelope(&error)),
    };
    let envelope = accept_mutation_command(&command, mutation_store, ctx.dispatcher);
    render_envelope(&envelope)
}

fn purchase_response(request: &Request, ctx: &RouteContext<'_>) -> RenderedResponse {
    let Some(mutation_store) = ctx.mutation_store else {
        return render_envelope(&mutation_source_unavailable());
    };
    let actor_context = match verify_actor_context_for_mutation(request, ctx) {
        Ok(actor) => actor,
        Err(envelope) => return render_envelope(&envelope),
    };
    let command = match parse_request_purchase(&request.body, &actor_context) {
        Ok(command) => command,
        Err(error) => return render_envelope(&mutation_validation_envelope(&error)),
    };
    let envelope = accept_mutation_command(&command, mutation_store, ctx.dispatcher);
    render_envelope(&envelope)
}

fn restore_purchase_response(request: &Request, ctx: &RouteContext<'_>) -> RenderedResponse {
    let Some(mutation_store) = ctx.mutation_store else {
        return render_envelope(&mutation_source_unavailable());
    };
    let actor_context = match verify_actor_context_for_mutation(request, ctx) {
        Ok(actor) => actor,
        Err(envelope) => return render_envelope(&envelope),
    };
    let command = match parse_request_restore_purchase(&request.body, &actor_context) {
        Ok(command) => command,
        Err(error) => return render_envelope(&mutation_validation_envelope(&error)),
    };
    let envelope = accept_mutation_command(&command, mutation_store, ctx.dispatcher);
    render_envelope(&envelope)
}

fn verify_actor_context_for_mutation(
    request: &Request,
    ctx: &RouteContext<'_>,
) -> Result<VerifiedActorContext, CommandResponseEnvelope> {
    let header = request.headers.get("authorization").map(String::as_str);
    match verify_actor_context(header, ctx.verifier) {
        Ok(actor_context) => Ok(actor_context),
        Err(failure) => Err(auth_failure_envelope(&failure)),
    }
}

fn mutation_source_unavailable() -> CommandResponseEnvelope {
    CommandResponseEnvelope::rejected(
        CommandErrorCategory::DownstreamUnavailable,
        UserFacingMessage::new(
            "command.mutation_store_unavailable",
            "mutation store is not configured; enable VOCAS_PRODUCTION_ADAPTERS and provide FIRESTORE_EMULATOR_HOST",
        ),
    )
}

fn mutation_validation_envelope(error: &MutationRequestError) -> CommandResponseEnvelope {
    CommandResponseEnvelope::rejected(
        error.to_error_category(),
        UserFacingMessage::new(mutation_validation_key(error), error.message().to_owned()),
    )
}

fn mutation_validation_key(error: &MutationRequestError) -> &'static str {
    match error {
        MutationRequestError::InvalidJson => "command.invalid_json",
        MutationRequestError::MissingActor => "command.missing_actor",
        MutationRequestError::OwnershipMismatch => "command.ownership_mismatch",
        MutationRequestError::MissingIdempotencyKey => "command.missing_idempotency_key",
        MutationRequestError::MissingVocabularyExpression => {
            "command.missing_vocabulary_expression"
        }
        MutationRequestError::InvalidGenerationTarget => "command.invalid_generation_target",
        MutationRequestError::MissingPlanCode => "command.missing_plan_code",
        MutationRequestError::InvalidPlanCode => "command.invalid_plan_code",
    }
}

fn auth_failure_envelope(failure: &CommandFailure) -> CommandResponseEnvelope {
    let category = match failure.code.as_str() {
        "missing-token" | "invalid-token" | "reauth-required" => {
            CommandErrorCategory::DownstreamAuthFailed
        }
        "ownership-mismatch" => CommandErrorCategory::DownstreamAuthFailed,
        _ => CommandErrorCategory::ValidationFailed,
    };
    CommandResponseEnvelope::rejected(
        category,
        UserFacingMessage::new(
            format!("command.auth.{}", failure.code.replace('-', "_")),
            failure.message.clone(),
        ),
    )
}

#[allow(clippy::result_large_err)]
fn verify_actor_context(
    authorization_header: Option<&str>,
    verifier: &(impl TokenVerificationPort + ?Sized),
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

pub fn render_command_failure(failure: &CommandFailure) -> RenderedResponse {
    json_response(failure.http_status(), failure)
}

fn render_envelope(envelope: &CommandResponseEnvelope) -> RenderedResponse {
    json_response(envelope.http_status(), envelope)
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
