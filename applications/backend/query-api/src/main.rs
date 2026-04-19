use std::env;
use std::io::{BufRead, BufReader, Write};
use std::net::{TcpListener, TcpStream};

const DEFAULT_HOST: &str = "0.0.0.0";
const DEFAULT_PORT: u16 = 18182;
const DEFAULT_READINESS_PATH: &str = "/readyz";
const FIREBASE_DEPENDENCIES_PATH: &str = "/dependencies/firebase";

fn main() {
    let host = env::var("VOCAS_SERVICE_HOST").unwrap_or_else(|_| DEFAULT_HOST.to_owned());
    let port = env::var("VOCAS_SERVICE_PORT")
        .ok()
        .and_then(|value| value.parse::<u16>().ok())
        .unwrap_or(DEFAULT_PORT);
    let readiness_path =
        env::var("VOCAS_READINESS_PATH").unwrap_or_else(|_| DEFAULT_READINESS_PATH.to_owned());

    let listener = TcpListener::bind((host.as_str(), port)).unwrap_or_else(|error| {
        panic!(
            "{} failed to bind on {}:{}: {}",
            query_api::SERVICE_NAME,
            host,
            port,
            error
        )
    });

    println!(
        "{} listening on {}:{} with readiness {}",
        query_api::SERVICE_NAME,
        host,
        port,
        readiness_path
    );

    for stream in listener.incoming() {
        match stream {
            Ok(stream) => {
                if let Err(error) = handle_connection(stream, readiness_path.as_str()) {
                    eprintln!("{} request handling error: {}", query_api::SERVICE_NAME, error);
                }
            }
            Err(error) => {
                eprintln!("{} accept error: {}", query_api::SERVICE_NAME, error);
            }
        }
    }
}

fn handle_connection(mut stream: TcpStream, readiness_path: &str) -> std::io::Result<()> {
    let mut request_line = String::new();
    let mut reader = BufReader::new(&stream);
    reader.read_line(&mut request_line)?;
    drop(reader);

    let path = request_path(request_line.as_str());

    match path {
        path if path == readiness_path => respond(
            &mut stream,
            "200 OK",
            format!("{} ready", query_api::SERVICE_NAME).as_str(),
        ),
        FIREBASE_DEPENDENCIES_PATH => firebase_dependency_response(&mut stream),
        "/" => respond(
            &mut stream,
            "200 OK",
            "query-api returns status-only until a completed payload is available",
        ),
        _ => respond(&mut stream, "404 Not Found", "not found"),
    }
}

fn firebase_dependency_response(stream: &mut TcpStream) -> std::io::Result<()> {
    let body = shared_runtime::firebase_dependency_report();
    let status = if shared_runtime::firebase_dependencies_healthy() {
        "200 OK"
    } else {
        "503 Service Unavailable"
    };

    respond(stream, status, body.as_str())
}

fn request_path(request_line: &str) -> &str {
    request_line
        .split_whitespace()
        .nth(1)
        .unwrap_or("/")
}

fn respond(stream: &mut TcpStream, status: &str, body: &str) -> std::io::Result<()> {
    write!(
        stream,
        "HTTP/1.1 {status}\r\nContent-Type: text/plain; charset=utf-8\r\nContent-Length: {}\r\nConnection: close\r\n\r\n{body}",
        body.len()
    )?;
    stream.flush()
}
