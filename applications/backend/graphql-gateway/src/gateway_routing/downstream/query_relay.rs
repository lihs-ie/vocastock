use serde_json::Value;

use crate::graphql::{
    catalog_success_response, failure_envelope::GatewayFailure, UnifiedGraphqlRequest,
};

use super::relay_client::{DownstreamHttpResponse, RelayClient, RelayClientError};

pub fn relay_vocabulary_catalog(
    relay_client: &RelayClient,
    request: &UnifiedGraphqlRequest,
) -> Result<String, GatewayFailure> {
    let response = relay_client
        .send_query(
            query_api::VOCABULARY_CATALOG_PATH,
            request.authorization_header.as_deref(),
            request.request_correlation.as_str(),
        )
        .map_err(map_relay_client_error)?;

    translate_catalog_response(response)
}

pub fn translate_catalog_response(
    response: DownstreamHttpResponse,
) -> Result<String, GatewayFailure> {
    match response.status_code {
        200 => {
            let payload = serde_json::from_str::<Value>(response.body.as_str()).map_err(|_| {
                GatewayFailure::downstream_invalid_response(query_api::SERVICE_NAME)
            })?;
            catalog_success_response(payload)
        }
        401 => Err(downstream_auth_failure(
            "401 Unauthorized",
            response.body.as_str(),
        )),
        403 => Err(downstream_auth_failure(
            "403 Forbidden",
            response.body.as_str(),
        )),
        _ => Err(GatewayFailure::downstream_invalid_response(
            query_api::SERVICE_NAME,
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

    GatewayFailure::downstream_auth_failed(status, message, Some(status == "403 Forbidden"))
}

fn map_relay_client_error(error: RelayClientError) -> GatewayFailure {
    match error {
        RelayClientError::Unavailable | RelayClientError::InvalidBaseUrl => {
            GatewayFailure::downstream_unavailable()
        }
        RelayClientError::InvalidResponse => {
            GatewayFailure::downstream_invalid_response(query_api::SERVICE_NAME)
        }
    }
}
