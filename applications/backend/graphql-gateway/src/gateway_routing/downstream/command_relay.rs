use serde_json::{json, Map, Value};

use crate::graphql::{
    failure_envelope::GatewayFailure, mutation_success_response, UnifiedGraphqlRequest,
};

use super::relay_client::{DownstreamHttpResponse, RelayClient, RelayClientError};

pub fn relay_register_vocabulary_expression(
    relay_client: &RelayClient,
    request: &UnifiedGraphqlRequest,
) -> Result<String, GatewayFailure> {
    let body = build_register_command_body(&request.envelope)?;
    let response = relay_client
        .send_command_json(
            command_api::REGISTER_VOCABULARY_EXPRESSION_PATH,
            request.authorization_header.as_deref(),
            request.request_correlation.as_str(),
            body.as_str(),
        )
        .map_err(map_relay_client_error)?;

    translate_command_response(response)
}

pub fn build_register_command_body(
    envelope: &crate::graphql::UnifiedGraphqlRequestEnvelope,
) -> Result<String, GatewayFailure> {
    let variables = envelope.variables_object().ok_or_else(|| {
        GatewayFailure::validation_failed(
            "registerVocabularyExpression requires variables.actor, variables.idempotencyKey, and variables.text",
        )
    })?;

    let actor = required_string_variable(variables, "actor")?;
    let idempotency_key = required_string_variable(variables, "idempotencyKey")?;
    let text = required_string_variable(variables, "text")?;

    let mut body = json!({
        "command": "registerVocabularyExpression",
        "actor": actor,
        "idempotencyKey": idempotency_key,
        "body": {
            "text": text
        }
    });

    if let Some(start_explanation) = optional_bool_variable(variables, "startExplanation")? {
        body["body"]["startExplanation"] = Value::Bool(start_explanation);
    }

    Ok(body.to_string())
}

pub fn translate_command_response(
    response: DownstreamHttpResponse,
) -> Result<String, GatewayFailure> {
    match response.status_code {
        202 => {
            let payload = serde_json::from_str::<Value>(response.body.as_str()).map_err(|_| {
                GatewayFailure::downstream_invalid_response(command_api::SERVICE_NAME)
            })?;
            mutation_success_response(payload)
        }
        401 => Err(downstream_auth_failure(
            "401 Unauthorized",
            response.body.as_str(),
        )),
        403 => Err(downstream_auth_failure(
            "403 Forbidden",
            response.body.as_str(),
        )),
        409 | 503 => translate_command_failure(response.status_code, response.body.as_str()),
        _ => Err(GatewayFailure::downstream_invalid_response(
            command_api::SERVICE_NAME,
        )),
    }
}

fn translate_command_failure(status_code: u16, body: &str) -> Result<String, GatewayFailure> {
    let payload = serde_json::from_str::<Value>(body)
        .map_err(|_| GatewayFailure::downstream_invalid_response(command_api::SERVICE_NAME))?;
    let payload_object = payload
        .as_object()
        .ok_or_else(|| GatewayFailure::downstream_invalid_response(command_api::SERVICE_NAME))?;
    let code = payload_object
        .get("code")
        .and_then(Value::as_str)
        .ok_or_else(|| GatewayFailure::downstream_invalid_response(command_api::SERVICE_NAME))?;
    let message = payload_object
        .get("message")
        .and_then(Value::as_str)
        .ok_or_else(|| GatewayFailure::downstream_invalid_response(command_api::SERVICE_NAME))?;
    let retryable = payload_object.get("retryable").and_then(Value::as_bool);

    match (status_code, code) {
        (409, "idempotency-conflict") => Err(GatewayFailure::command_failure(
            "409 Conflict",
            code,
            message,
            retryable,
        )),
        (503, "dispatch-failed") => Err(GatewayFailure::command_failure(
            "503 Service Unavailable",
            code,
            message,
            retryable,
        )),
        _ => Err(GatewayFailure::downstream_invalid_response(
            command_api::SERVICE_NAME,
        )),
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

fn map_relay_client_error(error: RelayClientError) -> GatewayFailure {
    match error {
        RelayClientError::Unavailable | RelayClientError::InvalidBaseUrl => {
            GatewayFailure::downstream_unavailable()
        }
        RelayClientError::InvalidResponse => {
            GatewayFailure::downstream_invalid_response(command_api::SERVICE_NAME)
        }
    }
}

fn required_string_variable(
    variables: &Map<String, Value>,
    key: &str,
) -> Result<String, GatewayFailure> {
    variables
        .get(key)
        .and_then(Value::as_str)
        .map(str::to_owned)
        .ok_or_else(|| {
            GatewayFailure::validation_failed(format!("variables.{key} must be a non-empty string"))
        })
}

fn optional_bool_variable(
    variables: &Map<String, Value>,
    key: &str,
) -> Result<Option<bool>, GatewayFailure> {
    match variables.get(key) {
        Some(value) => value.as_bool().map(Some).ok_or_else(|| {
            GatewayFailure::validation_failed(format!("variables.{key} must be a boolean"))
        }),
        None => Ok(None),
    }
}
