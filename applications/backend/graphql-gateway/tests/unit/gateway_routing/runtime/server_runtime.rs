use graphql_gateway::runtime::server_runtime::{bind_listener, startup_message};
use graphql_gateway::runtime::service_contract::ServerConfig;
use graphql_gateway::{downstream::RelayClient, runtime::server_runtime};
use std::io::{Read, Write};
use std::net::{Shutdown, TcpListener, TcpStream};
use std::thread;

#[test]
fn startup_message_mentions_public_graphql_route() {
    let config = ServerConfig {
        host: "127.0.0.1".to_owned(),
        port: 18180,
        readiness_path: "/readyz".to_owned(),
        command_upstream_base_url: "http://command-api:18181".to_owned(),
        query_upstream_base_url: "http://query-api:18182".to_owned(),
    };

    let message = startup_message(&config);

    assert!(message.contains("graphql-gateway listening on 127.0.0.1:18180"));
    assert!(message.contains("public route /graphql"));
}

#[test]
fn bind_listener_accepts_ephemeral_port() {
    let config = ServerConfig {
        host: "127.0.0.1".to_owned(),
        port: 0,
        readiness_path: "/readyz".to_owned(),
        command_upstream_base_url: "http://command-api:18181".to_owned(),
        query_upstream_base_url: "http://query-api:18182".to_owned(),
    };

    let listener = bind_listener(&config).expect("listener should bind");

    assert!(
        listener
            .local_addr()
            .expect("local addr should resolve")
            .port()
            > 0
    );
}

#[test]
fn serve_incoming_stream_returns_original_accept_error() {
    let relay_client = RelayClient::new("http://command-api:18181", "http://query-api:18182");
    let error = server_runtime::serve_incoming_stream(
        Err(std::io::Error::other("accept failed")),
        "/readyz",
        &relay_client,
    )
    .expect_err("incoming accept error should bubble");

    assert_eq!(error.kind(), std::io::ErrorKind::Other);
}

#[test]
fn handle_connection_writes_readiness_response() {
    let relay_client = RelayClient::new("http://command-api:18181", "http://query-api:18182");
    let listener = TcpListener::bind(("127.0.0.1", 0)).expect("listener should bind");
    let address = listener.local_addr().expect("address should resolve");

    let server = thread::spawn(move || {
        let (stream, _) = listener.accept().expect("request should arrive");
        server_runtime::handle_connection(stream, "/readyz", &relay_client)
            .expect("connection should be served");
    });

    let mut client = TcpStream::connect(address).expect("client should connect");
    write!(
        client,
        "GET /readyz HTTP/1.1\r\nHost: {}:{}\r\nConnection: close\r\n\r\n",
        address.ip(),
        address.port()
    )
    .expect("request should write");
    client
        .shutdown(Shutdown::Write)
        .expect("shutdown should work");

    let mut response = String::new();
    client
        .read_to_string(&mut response)
        .expect("response should read");
    server.join().expect("server thread should finish");

    assert!(response.contains("HTTP/1.1 200 OK"));
    assert!(response.contains("graphql-gateway ready"));
}

#[test]
fn handle_connection_writes_payload_too_large_failure() {
    let relay_client = RelayClient::new("http://command-api:18181", "http://query-api:18182");
    let listener = TcpListener::bind(("127.0.0.1", 0)).expect("listener should bind");
    let address = listener.local_addr().expect("address should resolve");

    let server = thread::spawn(move || {
        let (stream, _) = listener.accept().expect("request should arrive");
        server_runtime::handle_connection(stream, "/readyz", &relay_client)
            .expect("oversized request should still render a response");
    });

    let mut client = TcpStream::connect(address).expect("client should connect");
    write!(
        client,
        "POST /graphql HTTP/1.1\r\nHost: {}:{}\r\nContent-Length: {}\r\nConnection: close\r\n\r\n",
        address.ip(),
        address.port(),
        16 * 1024 + 1
    )
    .expect("request should write");
    client
        .shutdown(Shutdown::Write)
        .expect("shutdown should work");

    let mut response = String::new();
    client
        .read_to_string(&mut response)
        .expect("response should read");
    server.join().expect("server thread should finish");

    assert!(response.contains("HTTP/1.1 413 Payload Too Large"));
    assert!(response.contains("\"code\":\"payload-too-large\""));
}

#[test]
fn serve_incoming_stream_handles_successful_connection() {
    let relay_client = RelayClient::new("http://command-api:18181", "http://query-api:18182");
    let listener = TcpListener::bind(("127.0.0.1", 0)).expect("listener should bind");
    let address = listener.local_addr().expect("address should resolve");

    let server = thread::spawn(move || {
        let (stream, _) = listener.accept().expect("request should arrive");
        server_runtime::serve_incoming_stream(Ok(stream), "/readyz", &relay_client)
            .expect("connection should be served");
    });

    let mut client = TcpStream::connect(address).expect("client should connect");
    write!(
        client,
        "GET / HTTP/1.1\r\nHost: {}:{}\r\nConnection: close\r\n\r\n",
        address.ip(),
        address.port()
    )
    .expect("request should write");
    client
        .shutdown(Shutdown::Write)
        .expect("shutdown should work");

    let mut response = String::new();
    client
        .read_to_string(&mut response)
        .expect("response should read");
    server.join().expect("server thread should finish");

    assert!(response.contains("HTTP/1.1 200 OK"));
    assert!(response.contains("/graphql"));
}
