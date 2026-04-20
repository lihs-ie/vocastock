use std::io::{Read, Write};
use std::net::{TcpListener, TcpStream};
use std::thread;

use command_api::{
    bind_listener, handle_connection, serve_incoming_stream, startup_message, InMemoryCommandStore,
    InMemoryDispatchPort, ServerConfig, StubTokenVerifier,
};

use crate::support::env_lock;

#[test]
fn server_config_reads_env_and_falls_back_to_defaults() {
    let _guard = env_lock();
    unsafe {
        std::env::remove_var("VOCAS_SERVICE_HOST");
        std::env::remove_var("VOCAS_SERVICE_PORT");
        std::env::remove_var("VOCAS_READINESS_PATH");
    }

    let defaults = ServerConfig::from_env();
    assert_eq!(defaults.host, "0.0.0.0");
    assert_eq!(defaults.port, 18181);
    assert_eq!(defaults.readiness_path, "/readyz");

    unsafe {
        std::env::set_var("VOCAS_SERVICE_HOST", "127.0.0.1");
        std::env::set_var("VOCAS_SERVICE_PORT", "19181");
        std::env::set_var("VOCAS_READINESS_PATH", "/healthz");
    }

    let configured = ServerConfig::from_env();
    assert_eq!(configured.host, "127.0.0.1");
    assert_eq!(configured.port, 19181);
    assert_eq!(configured.readiness_path, "/healthz");

    unsafe {
        std::env::remove_var("VOCAS_SERVICE_HOST");
        std::env::remove_var("VOCAS_SERVICE_PORT");
        std::env::remove_var("VOCAS_READINESS_PATH");
    }
}

#[test]
fn handle_connection_serves_readyz_request() {
    let listener = TcpListener::bind(("127.0.0.1", 0)).expect("listener should bind");
    let address = listener
        .local_addr()
        .expect("listener address should resolve");

    let server = thread::spawn(move || {
        let (stream, _) = listener.accept().expect("connection should be accepted");
        handle_connection(
            stream,
            "/readyz",
            &StubTokenVerifier,
            &InMemoryCommandStore::default(),
            &InMemoryDispatchPort::default(),
        )
        .expect("connection should be handled");
    });

    let mut client = TcpStream::connect(address).expect("client should connect");
    client
        .write_all(b"GET /readyz HTTP/1.1\r\nHost: 127.0.0.1\r\n\r\n")
        .expect("request should write");
    client.flush().expect("request should flush");

    let mut response = String::new();
    client
        .read_to_string(&mut response)
        .expect("response should read");

    server.join().expect("server thread should join");

    assert!(response.starts_with("HTTP/1.1 200 OK\r\n"));
    assert!(response.contains("command-api ready"));
}

#[test]
fn handle_connection_returns_413_for_oversized_request_body() {
    let listener = TcpListener::bind(("127.0.0.1", 0)).expect("listener should bind");
    let address = listener
        .local_addr()
        .expect("listener address should resolve");

    let server = thread::spawn(move || {
        let (stream, _) = listener.accept().expect("connection should be accepted");
        handle_connection(
            stream,
            "/readyz",
            &StubTokenVerifier,
            &InMemoryCommandStore::default(),
            &InMemoryDispatchPort::default(),
        )
        .expect("connection should be handled");
    });

    let mut client = TcpStream::connect(address).expect("client should connect");
    client
        .write_all(
            b"POST /commands/register-vocabulary-expression HTTP/1.1\r\nHost: 127.0.0.1\r\nContent-Length: 16385\r\n\r\n",
        )
        .expect("request should write");
    client.flush().expect("request should flush");

    let mut response = String::new();
    client
        .read_to_string(&mut response)
        .expect("response should read");

    server.join().expect("server thread should join");

    assert!(response.starts_with("HTTP/1.1 413 Payload Too Large\r\n"));
    assert!(response.contains("\"code\":\"payload-too-large\""));
}

#[test]
fn server_loop_helpers_cover_bind_message_and_error_passthrough() {
    let config = ServerConfig {
        host: "127.0.0.1".to_owned(),
        port: 0,
        readiness_path: "/readyz".to_owned(),
    };

    let listener = bind_listener(&config).expect("listener should bind");
    let bound_address = listener
        .local_addr()
        .expect("listener address should resolve");
    assert_eq!(bound_address.ip().to_string(), "127.0.0.1");
    assert!(startup_message(&config).contains("command-api listening on 127.0.0.1:0"));

    let error = serve_incoming_stream(
        Err(std::io::Error::other("accept failed")),
        "/readyz",
        &StubTokenVerifier,
        &InMemoryCommandStore::default(),
        &InMemoryDispatchPort::default(),
    )
    .expect_err("incoming error should pass through");

    assert_eq!(error.kind(), std::io::ErrorKind::Other);
}
