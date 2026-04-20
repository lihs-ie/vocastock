use graphql_gateway::graphql::failure_envelope::{sanitize_message, GatewayFailure};

#[test]
fn gateway_failure_serializes_common_envelope() {
    let failure = GatewayFailure::downstream_unavailable();
    let body = failure.json_body();

    assert_eq!(failure.status, "503 Service Unavailable");
    assert!(body.contains("\"code\":\"downstream-unavailable\""));
    assert!(body.contains("\"message\":\"downstream service is unavailable\""));
    assert!(body.contains("\"retryable\":true"));
}

#[test]
fn sanitize_message_redacts_internal_route_details() {
    let message = sanitize_message(
        "http://command-api:18181/commands/register-vocabulary-expression timed out",
        "command relay failed",
    );

    assert_eq!(message, "command relay failed");
}
