use std::net::{TcpListener, TcpStream};
use std::thread;
use std::time::{Duration, Instant};

use graphql_gateway::server_runtime::{
    bind_error_message, bind_listener, handle_connection, listening_message,
    process_incoming_stream, run, serve_with_listener, server_configuration_from_env,
    ServerConfiguration, DEFAULT_HOST, DEFAULT_PORT, DEFAULT_READINESS_PATH,
};

use crate::support::env_lock;

#[test]
fn server_configuration_reads_env_and_defaults() {
    let _guard = env_lock();
    unsafe {
        std::env::remove_var("VOCAS_SERVICE_HOST");
        std::env::remove_var("VOCAS_SERVICE_PORT");
        std::env::remove_var("VOCAS_READINESS_PATH");
    }

    let defaults = server_configuration_from_env();
    assert_eq!(defaults.host, DEFAULT_HOST);
    assert_eq!(defaults.port, DEFAULT_PORT);
    assert_eq!(defaults.readiness_path, DEFAULT_READINESS_PATH);

    unsafe {
        std::env::set_var("VOCAS_SERVICE_HOST", "127.0.0.1");
        std::env::set_var("VOCAS_SERVICE_PORT", "19191");
        std::env::set_var("VOCAS_READINESS_PATH", "/healthz");
    }

    let configured = server_configuration_from_env();
    assert_eq!(configured.host, "127.0.0.1");
    assert_eq!(configured.port, 19191);
    assert_eq!(configured.readiness_path, "/healthz");

    unsafe {
        std::env::remove_var("VOCAS_SERVICE_HOST");
        std::env::remove_var("VOCAS_SERVICE_PORT");
        std::env::remove_var("VOCAS_READINESS_PATH");
    }
}

#[test]
fn handle_connection_serves_readyz_requests() {
    let listener = TcpListener::bind(("127.0.0.1", 0)).expect("listener should bind");
    let address = listener
        .local_addr()
        .expect("listener address should resolve");

    let server = thread::spawn(move || {
        let (stream, _) = listener.accept().expect("listener should accept");
        handle_connection(stream, "/readyz").expect("request handling should succeed");
    });

    let mut client = TcpStream::connect(address).expect("client should connect");
    std::io::Write::write_all(
        &mut client,
        b"GET /readyz HTTP/1.1\r\nHost: localhost\r\n\r\n",
    )
    .expect("request should write");
    std::io::Write::flush(&mut client).expect("request should flush");

    let mut response = String::new();
    std::io::Read::read_to_string(&mut client, &mut response).expect("response should be readable");
    server.join().expect("server thread should finish");

    assert!(response.contains("HTTP/1.1 200 OK"));
    assert!(response.contains("graphql-gateway ready"));
}

#[test]
fn server_configuration_type_is_constructible_for_runtime_use() {
    let configuration = ServerConfiguration {
        host: "127.0.0.1".to_owned(),
        port: 18080,
        readiness_path: "/readyz".to_owned(),
    };

    assert_eq!(configuration.host, "127.0.0.1");
    assert_eq!(configuration.port, 18080);
    assert_eq!(configuration.readiness_path, "/readyz");
}

#[test]
fn bind_helpers_cover_success_and_message_rendering() {
    let listener = TcpListener::bind(("127.0.0.1", 0)).expect("listener should bind");
    let address = listener
        .local_addr()
        .expect("listener address should resolve");
    drop(listener);

    let configuration = ServerConfiguration {
        host: "127.0.0.1".to_owned(),
        port: address.port(),
        readiness_path: "/readyz".to_owned(),
    };

    let rebound_listener = bind_listener(&configuration).expect("listener should rebind");
    drop(rebound_listener);

    let message = listening_message(&configuration);
    assert!(message.contains("graphql-gateway listening"));
    assert!(message.contains("/readyz"));

    let in_use_listener = TcpListener::bind(("127.0.0.1", 0)).expect("listener should bind");
    let in_use_address = in_use_listener
        .local_addr()
        .expect("listener address should resolve");
    let in_use_configuration = ServerConfiguration {
        host: "127.0.0.1".to_owned(),
        port: in_use_address.port(),
        readiness_path: "/readyz".to_owned(),
    };

    let error = bind_listener(&in_use_configuration).expect_err("second bind should fail");
    let error_message = bind_error_message(&in_use_configuration, &error);
    assert!(error_message.contains("failed to bind"));
}

#[test]
fn process_incoming_stream_propagates_accept_errors() {
    let result = process_incoming_stream(Err(std::io::Error::other("accept failed")), "/readyz");

    assert!(result.is_err());
}

#[test]
fn serve_with_listener_processes_a_single_connection() {
    let listener = TcpListener::bind(("127.0.0.1", 0)).expect("listener should bind");
    let address = listener
        .local_addr()
        .expect("listener address should resolve");
    let configuration = ServerConfiguration {
        host: "127.0.0.1".to_owned(),
        port: address.port(),
        readiness_path: "/readyz".to_owned(),
    };

    let server = thread::spawn(move || {
        serve_with_listener(listener, &configuration, Some(1));
    });

    let mut client = TcpStream::connect(address).expect("client should connect");
    std::io::Write::write_all(
        &mut client,
        b"GET /readyz HTTP/1.1\r\nHost: localhost\r\n\r\n",
    )
    .expect("request should write");
    std::io::Write::flush(&mut client).expect("request should flush");

    let mut response = String::new();
    std::io::Read::read_to_string(&mut client, &mut response).expect("response should be readable");
    server.join().expect("server thread should finish");

    assert!(response.contains("HTTP/1.1 200 OK"));
}

#[test]
fn run_uses_env_configuration_and_processes_limited_connections() {
    let _guard = env_lock();
    let reserved_listener = TcpListener::bind(("127.0.0.1", 0)).expect("listener should bind");
    let address = reserved_listener
        .local_addr()
        .expect("listener address should resolve");
    drop(reserved_listener);

    unsafe {
        std::env::set_var("VOCAS_SERVICE_HOST", "127.0.0.1");
        std::env::set_var("VOCAS_SERVICE_PORT", address.port().to_string());
        std::env::set_var("VOCAS_READINESS_PATH", "/readyz");
        std::env::set_var("VOCAS_SERVICE_CONNECTION_LIMIT", "1");
    }

    let server = thread::spawn(run);

    let mut client = connect_with_retry(address);
    std::io::Write::write_all(
        &mut client,
        b"GET /readyz HTTP/1.1\r\nHost: localhost\r\n\r\n",
    )
    .expect("request should write");
    std::io::Write::flush(&mut client).expect("request should flush");

    let mut response = String::new();
    std::io::Read::read_to_string(&mut client, &mut response).expect("response should be readable");
    server.join().expect("server thread should finish");

    assert!(response.contains("HTTP/1.1 200 OK"));

    unsafe {
        std::env::remove_var("VOCAS_SERVICE_HOST");
        std::env::remove_var("VOCAS_SERVICE_PORT");
        std::env::remove_var("VOCAS_READINESS_PATH");
        std::env::remove_var("VOCAS_SERVICE_CONNECTION_LIMIT");
    }
}

fn connect_with_retry(address: std::net::SocketAddr) -> TcpStream {
    let deadline = Instant::now() + Duration::from_secs(2);
    loop {
        match TcpStream::connect(address) {
            Ok(stream) => return stream,
            Err(error) if Instant::now() < deadline => {
                assert_eq!(
                    error.kind(),
                    std::io::ErrorKind::ConnectionRefused,
                    "unexpected connection error while waiting for server"
                );
                thread::sleep(Duration::from_millis(10));
            }
            Err(error) => panic!("client should connect: {error}"),
        }
    }
}
