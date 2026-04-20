use serde::Deserialize;
use serde_json::{Map, Value};

use super::failure_envelope::GatewayFailure;

#[derive(Clone, Debug, Deserialize, PartialEq)]
#[serde(rename_all = "camelCase")]
pub struct UnifiedGraphqlRequestEnvelope {
    pub query: String,
    #[serde(default)]
    pub operation_name: Option<String>,
    #[serde(default)]
    pub variables: Option<Value>,
}

#[derive(Clone, Debug, PartialEq)]
pub struct UnifiedGraphqlRequest {
    pub envelope: UnifiedGraphqlRequestEnvelope,
    pub authorization_header: Option<String>,
    pub request_correlation: String,
}

impl UnifiedGraphqlRequestEnvelope {
    pub fn parse(body: &str) -> Result<Self, GatewayFailure> {
        let envelope = serde_json::from_str::<Self>(body)
            .map_err(|_| GatewayFailure::validation_failed("request body must be valid JSON"))?;

        if envelope.query.trim().is_empty() {
            return Err(GatewayFailure::validation_failed("query must not be empty"));
        }

        if let Some(variables) = &envelope.variables {
            if !variables.is_object() {
                return Err(GatewayFailure::validation_failed(
                    "variables must be a JSON object when provided",
                ));
            }
        }

        Ok(envelope)
    }

    pub fn variables_object(&self) -> Option<&Map<String, Value>> {
        self.variables.as_ref()?.as_object()
    }
}

impl UnifiedGraphqlRequest {
    pub fn new(
        envelope: UnifiedGraphqlRequestEnvelope,
        authorization_header: Option<String>,
        request_correlation: String,
    ) -> Self {
        Self {
            envelope,
            authorization_header,
            request_correlation,
        }
    }
}
