//! Generic relay helpers for operations whose request / response
//! validators are small enough that hand-rolling a dedicated translator
//! in `command_relay.rs` / `query_relay.rs` would be pure boilerplate.
//!
//! Both helpers trust the downstream service to return a payload whose
//! JSON shape already matches the public GraphQL schema declared in
//! `applications/backend/graphql-gateway/schema/schema.graphql`. The
//! gateway is still responsible for the HTTP envelope (auth / status
//! code translation); payload validation is deferred to the downstream.

use serde_json::{json, Value};

use crate::graphql::{
    failure_envelope::GatewayFailure, pass_through_nullable_response,
    pass_through_success_response, UnifiedGraphqlRequest,
};

use super::relay_client::{DownstreamHttpResponse, RelayClient, RelayClientError};

/// Relay a query operation with downstream path and pass-through response
/// translation. Accepts `null` as a valid body for nullable GraphQL
/// fields — downstream returns `204 No Content` or `"null"` when the
/// resource is absent.
pub fn relay_generic_query(
    relay_client: &RelayClient,
    request: &UnifiedGraphqlRequest,
    downstream_path: &str,
    operation_name: &str,
    service_name: &'static str,
) -> Result<String, GatewayFailure> {
    let path = attach_variables_as_query_string(downstream_path, request);
    let response = relay_client
        .send_query(
            path.as_str(),
            request.authorization_header.as_deref(),
            request.request_correlation.as_str(),
        )
        .map_err(|error| map_relay_error(error, service_name))?;

    translate_query_response(response, operation_name, service_name)
}

/// Relay a mutation operation by forwarding the raw GraphQL variables
/// as the downstream JSON body. Response is validated to be a valid
/// JSON object (which must match the `CommandResponseEnvelope` schema).
pub fn relay_generic_command(
    relay_client: &RelayClient,
    request: &UnifiedGraphqlRequest,
    downstream_path: &str,
    operation_name: &str,
    service_name: &'static str,
) -> Result<String, GatewayFailure> {
    let body = build_command_body(request)?;
    let response = relay_client
        .send_command_json(
            downstream_path,
            request.authorization_header.as_deref(),
            request.request_correlation.as_str(),
            body.as_str(),
        )
        .map_err(|error| map_relay_error(error, service_name))?;

    translate_command_response(response, operation_name, service_name)
}

fn attach_variables_as_query_string(
    downstream_path: &str,
    request: &UnifiedGraphqlRequest,
) -> String {
    // For queries with an `identifier` argument, the gateway appends
    // `?identifier=<url-encoded>` so the downstream can avoid parsing the
    // entire GraphQL document. Queries without variables are relayed as
    // plain GETs to the base path.
    let Some(variables) = request.envelope.variables_object() else {
        return downstream_path.to_owned();
    };
    let mut parts = Vec::new();
    for (key, value) in variables {
        if let Some(raw) = value.as_str() {
            parts.push(format!("{key}={}", percent_encode(raw)));
        } else if let Some(raw) = value.as_i64() {
            parts.push(format!("{key}={raw}"));
        }
    }
    if parts.is_empty() {
        downstream_path.to_owned()
    } else {
        format!("{downstream_path}?{}", parts.join("&"))
    }
}

fn build_command_body(request: &UnifiedGraphqlRequest) -> Result<String, GatewayFailure> {
    // The gateway forwards the GraphQL `variables.input` payload verbatim
    // as the HTTP body. Operations that carry no input variables send an
    // empty JSON object so downstream parsers stay strict.
    let body = request
        .envelope
        .variables_object()
        .and_then(|variables| variables.get("input").cloned())
        .unwrap_or_else(|| json!({}));
    Ok(body.to_string())
}

fn translate_query_response(
    response: DownstreamHttpResponse,
    operation_name: &str,
    service_name: &'static str,
) -> Result<String, GatewayFailure> {
    match response.status_code {
        200 => {
            let payload = serde_json::from_str::<Value>(response.body.as_str())
                .map_err(|_| GatewayFailure::downstream_invalid_response(service_name))?;
            if payload.is_null() {
                Ok(pass_through_nullable_response(operation_name, payload))
            } else {
                pass_through_success_response(operation_name, payload, service_name)
            }
        }
        204 => Ok(pass_through_nullable_response(operation_name, Value::Null)),
        401 => Err(downstream_auth_failure(
            "401 Unauthorized",
            response.body.as_str(),
        )),
        403 => Err(downstream_auth_failure(
            "403 Forbidden",
            response.body.as_str(),
        )),
        _ => Err(GatewayFailure::downstream_invalid_response(service_name)),
    }
}

fn translate_command_response(
    response: DownstreamHttpResponse,
    operation_name: &str,
    service_name: &'static str,
) -> Result<String, GatewayFailure> {
    match response.status_code {
        200 | 202 => {
            let payload = serde_json::from_str::<Value>(response.body.as_str())
                .map_err(|_| GatewayFailure::downstream_invalid_response(service_name))?;
            pass_through_success_response(operation_name, payload, service_name)
        }
        401 => Err(downstream_auth_failure(
            "401 Unauthorized",
            response.body.as_str(),
        )),
        403 => Err(downstream_auth_failure(
            "403 Forbidden",
            response.body.as_str(),
        )),
        _ => Err(GatewayFailure::downstream_invalid_response(service_name)),
    }
}

fn downstream_auth_failure(status: &'static str, body: &str) -> GatewayFailure {
    let payload = serde_json::from_str::<Value>(body).ok();
    let message = payload
        .as_ref()
        .and_then(Value::as_object)
        .and_then(|object| object.get("message"))
        .and_then(Value::as_str)
        .unwrap_or("downstream authentication failed");
    let retryable = payload
        .as_ref()
        .and_then(Value::as_object)
        .and_then(|object| object.get("retryable"))
        .and_then(Value::as_bool);
    GatewayFailure::downstream_auth_failed(status, message, retryable)
}

fn map_relay_error(error: RelayClientError, service_name: &'static str) -> GatewayFailure {
    match error {
        RelayClientError::Unavailable | RelayClientError::InvalidBaseUrl => {
            GatewayFailure::downstream_unavailable()
        }
        RelayClientError::InvalidResponse => {
            GatewayFailure::downstream_invalid_response(service_name)
        }
    }
}

fn percent_encode(raw: &str) -> String {
    let mut buffer = String::with_capacity(raw.len());
    for byte in raw.as_bytes() {
        match byte {
            b'A'..=b'Z' | b'a'..=b'z' | b'0'..=b'9' | b'-' | b'_' | b'.' | b'~' => {
                buffer.push(*byte as char);
            }
            _ => buffer.push_str(&format!("%{byte:02X}")),
        }
    }
    buffer
}
