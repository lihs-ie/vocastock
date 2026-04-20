use std::env;
use std::io::BufReader;
use std::net::{TcpListener, TcpStream};

const DEFAULT_HOST: &str = "0.0.0.0";
const DEFAULT_PORT: u16 = 18182;
const DEFAULT_READINESS_PATH: &str = "/readyz";

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

    let verifier = query_api::StubTokenVerifier;
    let source = query_api::InMemoryCatalogProjectionSource::default();

    for stream in listener.incoming() {
        match stream {
            Ok(stream) => {
                if let Err(error) =
                    handle_connection(stream, readiness_path.as_str(), &verifier, &source)
                {
                    eprintln!(
                        "{} request handling error: {}",
                        query_api::SERVICE_NAME,
                        error
                    );
                }
            }
            Err(error) => {
                eprintln!("{} accept error: {}", query_api::SERVICE_NAME, error);
            }
        }
    }
}

fn handle_connection(
    mut stream: TcpStream,
    readiness_path: &str,
    verifier: &query_api::StubTokenVerifier,
    source: &query_api::InMemoryCatalogProjectionSource,
) -> std::io::Result<()> {
    let request = {
        let mut reader = BufReader::new(&mut stream);
        query_api::read_request(&mut reader)?
    };
    let response = query_api::route_request(&request, readiness_path, verifier, source);

    query_api::write_response(&mut stream, &response)
}
