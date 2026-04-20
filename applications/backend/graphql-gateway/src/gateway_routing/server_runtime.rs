use std::env;
use std::io::{BufRead, BufReader};
use std::net::{TcpListener, TcpStream};

pub const DEFAULT_HOST: &str = "0.0.0.0";
pub const DEFAULT_PORT: u16 = 18180;
pub const DEFAULT_READINESS_PATH: &str = "/readyz";

pub struct ServerConfiguration {
    pub host: String,
    pub port: u16,
    pub readiness_path: String,
}

pub fn server_configuration_from_env() -> ServerConfiguration {
    let host = env::var("VOCAS_SERVICE_HOST").unwrap_or_else(|_| DEFAULT_HOST.to_owned());
    let port = env::var("VOCAS_SERVICE_PORT")
        .ok()
        .and_then(|value| value.parse::<u16>().ok())
        .unwrap_or(DEFAULT_PORT);
    let readiness_path =
        env::var("VOCAS_READINESS_PATH").unwrap_or_else(|_| DEFAULT_READINESS_PATH.to_owned());

    ServerConfiguration {
        host,
        port,
        readiness_path,
    }
}

pub fn handle_connection(mut stream: TcpStream, readiness_path: &str) -> std::io::Result<()> {
    let mut request_line = String::new();
    let mut reader = BufReader::new(&stream);
    reader.read_line(&mut request_line)?;
    drop(reader);

    let path = crate::http_endpoint::request_path(request_line.as_str());
    let response = crate::http_endpoint::response_for_path(path, readiness_path);
    crate::http_endpoint::write_response(&mut stream, &response)
}

pub fn process_incoming_stream(
    stream_result: std::io::Result<TcpStream>,
    readiness_path: &str,
) -> std::io::Result<()> {
    let stream = stream_result?;
    handle_connection(stream, readiness_path)
}

pub fn bind_listener(configuration: &ServerConfiguration) -> std::io::Result<TcpListener> {
    TcpListener::bind((configuration.host.as_str(), configuration.port))
}

pub fn bind_error_message(configuration: &ServerConfiguration, error: &std::io::Error) -> String {
    format!(
        "{} failed to bind on {}:{}: {}",
        crate::SERVICE_NAME,
        configuration.host,
        configuration.port,
        error
    )
}

pub fn listening_message(configuration: &ServerConfiguration) -> String {
    format!(
        "{} listening on {}:{} with readiness {}",
        crate::SERVICE_NAME,
        configuration.host,
        configuration.port,
        configuration.readiness_path
    )
}

pub fn run() {
    let configuration = server_configuration_from_env();
    let listener = bind_listener(&configuration)
        .unwrap_or_else(|error| panic!("{}", bind_error_message(&configuration, &error)));

    serve_with_listener(listener, &configuration, connection_limit_from_env());
}

pub fn serve_with_listener(
    listener: TcpListener,
    configuration: &ServerConfiguration,
    max_connections: Option<usize>,
) {
    println!("{}", listening_message(configuration));

    for (index, stream) in listener.incoming().enumerate() {
        if let Err(error) = process_incoming_stream(stream, configuration.readiness_path.as_str()) {
            eprintln!("{} request handling error: {}", crate::SERVICE_NAME, error);
        }
        if max_connections.is_some_and(|limit| index + 1 >= limit) {
            break;
        }
    }
}

fn connection_limit_from_env() -> Option<usize> {
    env::var("VOCAS_SERVICE_CONNECTION_LIMIT")
        .ok()
        .and_then(|value| value.parse::<usize>().ok())
}
