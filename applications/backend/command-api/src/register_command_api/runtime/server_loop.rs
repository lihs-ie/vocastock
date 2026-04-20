use std::env;
use std::io::BufReader;
use std::net::{TcpListener, TcpStream};

use crate::command::CommandFailure;
use crate::http::{
    read_request, render_command_failure, route_request, write_response, RequestReadError,
};

use super::{InMemoryCommandStore, InMemoryDispatchPort, StubTokenVerifier, SERVICE_NAME};

const DEFAULT_HOST: &str = "0.0.0.0";
const DEFAULT_PORT: u16 = 18181;
const DEFAULT_READINESS_PATH: &str = "/readyz";

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct ServerConfig {
    pub host: String,
    pub port: u16,
    pub readiness_path: String,
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
        }
    }
}

pub fn run_server() {
    let config = ServerConfig::from_env();
    let listener = bind_listener(&config).unwrap_or_else(|error| {
        panic!(
            "{} failed to bind on {}:{}: {}",
            SERVICE_NAME, config.host, config.port, error
        )
    });

    println!("{}", startup_message(&config));

    let verifier = StubTokenVerifier;
    let store = InMemoryCommandStore::default();
    let dispatcher = InMemoryDispatchPort::default();

    run_accept_loop(
        listener,
        config.readiness_path.as_str(),
        &verifier,
        &store,
        &dispatcher,
    );
}

pub fn bind_listener(config: &ServerConfig) -> std::io::Result<TcpListener> {
    TcpListener::bind((config.host.as_str(), config.port))
}

pub fn startup_message(config: &ServerConfig) -> String {
    format!(
        "{} listening on {}:{} with readiness {}",
        SERVICE_NAME, config.host, config.port, config.readiness_path
    )
}

pub fn run_accept_loop(
    listener: TcpListener,
    readiness_path: &str,
    verifier: &StubTokenVerifier,
    store: &InMemoryCommandStore,
    dispatcher: &InMemoryDispatchPort,
) {
    for stream in listener.incoming() {
        if let Err(error) =
            serve_incoming_stream(stream, readiness_path, verifier, store, dispatcher)
        {
            eprintln!("{} stream handling error: {}", SERVICE_NAME, error);
        }
    }
}

pub fn serve_incoming_stream(
    stream: std::io::Result<TcpStream>,
    readiness_path: &str,
    verifier: &StubTokenVerifier,
    store: &InMemoryCommandStore,
    dispatcher: &InMemoryDispatchPort,
) -> std::io::Result<()> {
    match stream {
        Ok(stream) => handle_connection(stream, readiness_path, verifier, store, dispatcher),
        Err(error) => Err(error),
    }
}

pub fn handle_connection(
    mut stream: TcpStream,
    readiness_path: &str,
    verifier: &StubTokenVerifier,
    store: &InMemoryCommandStore,
    dispatcher: &InMemoryDispatchPort,
) -> std::io::Result<()> {
    let response = {
        let mut reader = BufReader::new(&mut stream);
        match read_request(&mut reader) {
            Ok(request) => route_request(&request, readiness_path, verifier, store, dispatcher),
            Err(RequestReadError::PayloadTooLarge { max_length, .. }) => {
                render_command_failure(&CommandFailure::payload_too_large(max_length))
            }
            Err(RequestReadError::Io(error)) => return Err(error),
        }
    };

    write_response(&mut stream, &response)
}
