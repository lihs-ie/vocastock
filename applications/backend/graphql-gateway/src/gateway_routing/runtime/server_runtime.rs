use std::io::BufReader;
use std::net::{TcpListener, TcpStream};

use crate::downstream::RelayClient;
use crate::graphql::failure_envelope::GatewayFailure;

use super::http_endpoint::{
    read_request, render_gateway_failure, route_request, write_response, RequestReadError,
};
use super::service_contract::{ServerConfig, SERVICE_NAME};

pub fn run_public_gateway() {
    let config = ServerConfig::from_env();
    let listener = bind_listener(&config).unwrap_or_else(|error| {
        panic!(
            "{} failed to bind on {}:{}: {}",
            SERVICE_NAME, config.host, config.port, error
        )
    });

    println!("{}", startup_message(&config));

    let relay_client = RelayClient::from_server_config(&config);
    run_accept_loop(listener, config.readiness_path.as_str(), &relay_client);
}

pub fn bind_listener(config: &ServerConfig) -> std::io::Result<TcpListener> {
    TcpListener::bind((config.host.as_str(), config.port))
}

pub fn startup_message(config: &ServerConfig) -> String {
    format!(
        "{} listening on {}:{} with readiness {} and public route /graphql",
        SERVICE_NAME, config.host, config.port, config.readiness_path
    )
}

pub fn run_accept_loop(listener: TcpListener, readiness_path: &str, relay_client: &RelayClient) {
    for stream in listener.incoming() {
        if let Err(error) = serve_incoming_stream(stream, readiness_path, relay_client) {
            eprintln!("{} stream handling error: {}", SERVICE_NAME, error);
        }
    }
}

pub fn serve_incoming_stream(
    stream: std::io::Result<TcpStream>,
    readiness_path: &str,
    relay_client: &RelayClient,
) -> std::io::Result<()> {
    match stream {
        Ok(stream) => handle_connection(stream, readiness_path, relay_client),
        Err(error) => Err(error),
    }
}

pub fn handle_connection(
    mut stream: TcpStream,
    readiness_path: &str,
    relay_client: &RelayClient,
) -> std::io::Result<()> {
    let response = {
        let mut reader = BufReader::new(&mut stream);
        match read_request(&mut reader) {
            Ok(request) => route_request(&request, readiness_path, relay_client),
            Err(RequestReadError::PayloadTooLarge { max_length, .. }) => {
                render_gateway_failure(&GatewayFailure::payload_too_large(max_length))
            }
            Err(RequestReadError::Io(error)) => return Err(error),
        }
    };

    write_response(&mut stream, &response)
}
