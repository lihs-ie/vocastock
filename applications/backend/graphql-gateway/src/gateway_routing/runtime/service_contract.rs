use std::collections::HashMap;
use std::env;
use std::sync::atomic::{AtomicU64, Ordering};
use std::time::{SystemTime, UNIX_EPOCH};

pub const SERVICE_NAME: &str = "graphql-gateway";
pub const GRAPHQL_PATH: &str = "/graphql";
pub const ROOT_PATH: &str = "/";
pub const FIREBASE_DEPENDENCIES_PATH: &str = "/dependencies/firebase";
pub const AUTHORIZATION_HEADER: &str = "authorization";
pub const REQUEST_CORRELATION_HEADER: &str = "x-request-correlation";
pub const ROOT_MESSAGE: &str = "graphql-gateway exposes /graphql for registerVocabularyExpression and vocabularyCatalog while preserving readiness and Firebase probes";

const DEFAULT_HOST: &str = "0.0.0.0";
const DEFAULT_PORT: u16 = 18180;
const DEFAULT_READINESS_PATH: &str = "/readyz";
const DEFAULT_COMMAND_UPSTREAM_BASE_URL: &str = "http://command-api:18181";
const DEFAULT_QUERY_UPSTREAM_BASE_URL: &str = "http://query-api:18182";
const COMMAND_UPSTREAM_ENV: &str = "VOCAS_COMMAND_UPSTREAM_BASE_URL";
const QUERY_UPSTREAM_ENV: &str = "VOCAS_QUERY_UPSTREAM_BASE_URL";

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct ServerConfig {
    pub host: String,
    pub port: u16,
    pub readiness_path: String,
    pub command_upstream_base_url: String,
    pub query_upstream_base_url: String,
}

impl ServerConfig {
    pub fn from_env() -> Self {
        Self {
            host: env::var("VOCAS_SERVICE_HOST").unwrap_or_else(|_| DEFAULT_HOST.to_owned()),
            port: env::var("VOCAS_SERVICE_PORT")
                .ok()
                .and_then(|value| value.parse::<u16>().ok())
                .unwrap_or(DEFAULT_PORT),
            readiness_path: env::var("VOCAS_READINESS_PATH")
                .unwrap_or_else(|_| DEFAULT_READINESS_PATH.to_owned()),
            command_upstream_base_url: env::var(COMMAND_UPSTREAM_ENV)
                .unwrap_or_else(|_| DEFAULT_COMMAND_UPSTREAM_BASE_URL.to_owned()),
            query_upstream_base_url: env::var(QUERY_UPSTREAM_ENV)
                .unwrap_or_else(|_| DEFAULT_QUERY_UPSTREAM_BASE_URL.to_owned()),
        }
    }
}

pub fn request_correlation_from_headers(headers: &HashMap<String, String>) -> String {
    headers
        .get(REQUEST_CORRELATION_HEADER)
        .map(String::as_str)
        .map(str::trim)
        .filter(|value| !value.is_empty())
        .map(str::to_owned)
        .unwrap_or_else(generate_request_correlation)
}

pub fn generate_request_correlation() -> String {
    static COUNTER: AtomicU64 = AtomicU64::new(1);

    let millis = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .expect("system clock should be after unix epoch")
        .as_millis();
    let sequence = COUNTER.fetch_add(1, Ordering::Relaxed);

    format!("gateway-{millis}-{sequence}")
}
