use serde::Serialize;

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct GatewayFailureEnvelope {
    pub code: String,
    pub message: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub retryable: Option<bool>,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct GatewayFailure {
    pub status: &'static str,
    pub envelope: GatewayFailureEnvelope,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
pub struct PublicFailureResponse {
    pub errors: Vec<GatewayFailureEnvelope>,
}

impl GatewayFailure {
    pub fn new(
        status: &'static str,
        code: impl Into<String>,
        message: impl Into<String>,
        retryable: Option<bool>,
    ) -> Self {
        Self {
            status,
            envelope: GatewayFailureEnvelope {
                code: code.into(),
                message: message.into(),
                retryable,
            },
        }
    }

    pub fn validation_failed(message: impl Into<String>) -> Self {
        Self::new("400 Bad Request", "validation-failed", message, Some(false))
    }

    pub fn payload_too_large(max_length: usize) -> Self {
        Self::new(
            "413 Payload Too Large",
            "payload-too-large",
            format!("request body exceeds maximum size of {max_length} bytes"),
            Some(false),
        )
    }

    pub fn unsupported_operation() -> Self {
        Self::new(
            "400 Bad Request",
            "unsupported-operation",
            "public GraphQL operation is not allowlisted",
            Some(false),
        )
    }

    pub fn ambiguous_operation() -> Self {
        Self::new(
            "400 Bad Request",
            "ambiguous-operation",
            "request must contain exactly one resolvable public GraphQL operation",
            Some(false),
        )
    }

    pub fn downstream_unavailable() -> Self {
        Self::new(
            "503 Service Unavailable",
            "downstream-unavailable",
            "downstream service is unavailable",
            Some(true),
        )
    }

    pub fn downstream_invalid_response(service_name: &str) -> Self {
        Self::new(
            "502 Bad Gateway",
            "downstream-invalid-response",
            format!("{service_name} returned an invalid response"),
            Some(true),
        )
    }

    pub fn downstream_auth_failed(
        status: &'static str,
        message: &str,
        retryable: Option<bool>,
    ) -> Self {
        Self::new(
            status,
            "downstream-auth-failed",
            sanitize_message(message, "downstream authentication failed"),
            retryable,
        )
    }

    pub fn command_failure(
        status: &'static str,
        code: &str,
        message: &str,
        retryable: Option<bool>,
    ) -> Self {
        Self::new(
            status,
            code,
            sanitize_message(message, "command relay failed"),
            retryable,
        )
    }

    pub fn json_body(&self) -> String {
        serde_json::to_string(&PublicFailureResponse {
            errors: vec![self.envelope.clone()],
        })
        .expect("gateway failure should serialize")
    }
}

pub fn sanitize_message(message: &str, fallback: &str) -> String {
    let trimmed = message.trim();
    if trimmed.is_empty()
        || trimmed.contains("http://")
        || trimmed.contains("https://")
        || trimmed.contains("/commands/")
        || trimmed.contains("/vocabulary-catalog")
        || trimmed.contains("command-api")
        || trimmed.contains("query-api")
    {
        fallback.to_owned()
    } else {
        trimmed.to_owned()
    }
}
