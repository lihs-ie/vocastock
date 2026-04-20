use graphql_gateway::runtime::service_contract::{
    generate_request_correlation, request_correlation_from_headers, ServerConfig,
};
use std::collections::HashMap;

use crate::support::env_lock;

#[test]
fn server_config_reads_overrides_from_environment() {
    let _guard = env_lock();

    unsafe {
        std::env::set_var("VOCAS_SERVICE_HOST", "127.0.0.1");
        std::env::set_var("VOCAS_SERVICE_PORT", "19180");
        std::env::set_var("VOCAS_READINESS_PATH", "/healthz");
        std::env::set_var(
            "VOCAS_COMMAND_UPSTREAM_BASE_URL",
            "http://command-api:19181",
        );
        std::env::set_var("VOCAS_QUERY_UPSTREAM_BASE_URL", "http://query-api:19182");
    }

    let config = ServerConfig::from_env();

    assert_eq!(config.host, "127.0.0.1");
    assert_eq!(config.port, 19180);
    assert_eq!(config.readiness_path, "/healthz");
    assert_eq!(config.command_upstream_base_url, "http://command-api:19181");
    assert_eq!(config.query_upstream_base_url, "http://query-api:19182");

    unsafe {
        std::env::remove_var("VOCAS_SERVICE_HOST");
        std::env::remove_var("VOCAS_SERVICE_PORT");
        std::env::remove_var("VOCAS_READINESS_PATH");
        std::env::remove_var("VOCAS_COMMAND_UPSTREAM_BASE_URL");
        std::env::remove_var("VOCAS_QUERY_UPSTREAM_BASE_URL");
    }
}

#[test]
fn request_correlation_from_headers_prefers_client_value() {
    let headers = HashMap::from([(
        "x-request-correlation".to_owned(),
        "client-correlation".to_owned(),
    )]);

    let correlation = request_correlation_from_headers(&headers);

    assert_eq!(correlation, "client-correlation");
}

#[test]
fn request_correlation_from_headers_generates_gateway_value_when_missing() {
    let correlation = request_correlation_from_headers(&HashMap::new());

    assert!(correlation.starts_with("gateway-"));
}

#[test]
fn server_config_uses_defaults_when_env_is_missing_or_invalid() {
    let _guard = env_lock();

    unsafe {
        std::env::remove_var("VOCAS_SERVICE_HOST");
        std::env::set_var("VOCAS_SERVICE_PORT", "invalid");
        std::env::remove_var("VOCAS_READINESS_PATH");
        std::env::remove_var("VOCAS_COMMAND_UPSTREAM_BASE_URL");
        std::env::remove_var("VOCAS_QUERY_UPSTREAM_BASE_URL");
    }

    let config = ServerConfig::from_env();

    assert_eq!(config.host, "0.0.0.0");
    assert_eq!(config.port, 18180);
    assert_eq!(config.readiness_path, "/readyz");
    assert_eq!(config.command_upstream_base_url, "http://command-api:18181");
    assert_eq!(config.query_upstream_base_url, "http://query-api:18182");

    unsafe {
        std::env::remove_var("VOCAS_SERVICE_PORT");
    }
}

#[test]
fn request_correlation_from_headers_ignores_blank_client_value() {
    let headers = HashMap::from([("x-request-correlation".to_owned(), "   ".to_owned())]);

    let correlation = request_correlation_from_headers(&headers);

    assert!(correlation.starts_with("gateway-"));
}

#[test]
fn generate_request_correlation_produces_gateway_prefixed_unique_values() {
    let first = generate_request_correlation();
    let second = generate_request_correlation();

    assert!(first.starts_with("gateway-"));
    assert!(second.starts_with("gateway-"));
    assert_ne!(first, second);
}
