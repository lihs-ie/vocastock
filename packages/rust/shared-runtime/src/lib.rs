use std::env;
use std::net::{SocketAddr, TcpStream, ToSocketAddrs};
use std::time::Duration;

const DEFAULT_CONNECT_TIMEOUT_MILLIS: u64 = 1500;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct DependencyStatus {
    pub dependency_name: &'static str,
    pub endpoint: Option<String>,
    pub reachable: bool,
    pub detail: String,
}

const FIREBASE_DEPENDENCIES: [(&str, &str); 4] = [
    ("firestore", "FIRESTORE_EMULATOR_HOST"),
    ("storage", "STORAGE_EMULATOR_HOST"),
    ("auth", "FIREBASE_AUTH_EMULATOR_HOST"),
    ("pubsub", "PUBSUB_EMULATOR_HOST"),
];

pub fn firebase_dependency_statuses() -> Vec<DependencyStatus> {
    FIREBASE_DEPENDENCIES
        .into_iter()
        .map(|(dependency_name, env_var)| {
            let endpoint = env::var(env_var)
                .ok()
                .filter(|value| !value.trim().is_empty());

            match endpoint {
                Some(endpoint) => match probe_tcp_endpoint(endpoint.as_str()) {
                    Ok(socket_addr) => DependencyStatus {
                        dependency_name,
                        endpoint: Some(endpoint),
                        reachable: true,
                        detail: format!("reachable via {}", socket_addr),
                    },
                    Err(detail) => DependencyStatus {
                        dependency_name,
                        endpoint: Some(endpoint),
                        reachable: false,
                        detail,
                    },
                },
                None => DependencyStatus {
                    dependency_name,
                    endpoint: None,
                    reachable: true,
                    detail: "not configured".to_owned(),
                },
            }
        })
        .collect()
}

pub fn firebase_dependencies_healthy() -> bool {
    firebase_dependency_statuses()
        .into_iter()
        .all(|status| status.reachable)
}

pub fn firebase_dependency_report() -> String {
    firebase_dependency_statuses()
        .into_iter()
        .map(|status| match status.endpoint {
            Some(endpoint) => format!(
                "{}={} ({})",
                status.dependency_name, endpoint, status.detail
            ),
            None => format!("{}=unset ({})", status.dependency_name, status.detail),
        })
        .collect::<Vec<_>>()
        .join("\n")
}

fn probe_tcp_endpoint(endpoint: &str) -> Result<SocketAddr, String> {
    let socket_addr = resolve_socket_addr(endpoint)?;
    let timeout = Duration::from_millis(DEFAULT_CONNECT_TIMEOUT_MILLIS);

    TcpStream::connect_timeout(&socket_addr, timeout)
        .map(|_| socket_addr)
        .map_err(|error| format!("connect failed: {}", error))
}

fn resolve_socket_addr(endpoint: &str) -> Result<SocketAddr, String> {
    endpoint
        .to_socket_addrs()
        .map_err(|error| format!("address resolution failed: {}", error))?
        .next()
        .ok_or_else(|| "address resolution returned no results".to_owned())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn localhost_address_resolves() {
        let resolved = resolve_socket_addr("127.0.0.1:8080");

        assert!(resolved.is_ok());
    }

    #[test]
    fn invalid_hostname_is_reported() {
        let resolved = resolve_socket_addr("nonexistent.invalid:18080");

        assert!(resolved.is_err());
    }
}
