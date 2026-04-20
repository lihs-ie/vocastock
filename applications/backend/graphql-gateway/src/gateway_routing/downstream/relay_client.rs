use std::collections::HashMap;
use std::io::{Read, Write};
use std::net::TcpStream;
use std::time::Duration;

use crate::runtime::service_contract::{
    ServerConfig, AUTHORIZATION_HEADER, REQUEST_CORRELATION_HEADER,
};

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct RelayClient {
    command_base_url: String,
    query_base_url: String,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct HttpTarget {
    pub host: String,
    pub port: u16,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct DownstreamHttpResponse {
    pub status_code: u16,
    pub headers: HashMap<String, String>,
    pub body: String,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum RelayClientError {
    InvalidBaseUrl,
    Unavailable,
    InvalidResponse,
}

#[derive(Clone, Debug, Eq, PartialEq)]
struct DownstreamRequest {
    method: String,
    path: String,
    headers: Vec<(String, String)>,
    body: Option<String>,
}

impl RelayClient {
    pub fn new(command_base_url: impl Into<String>, query_base_url: impl Into<String>) -> Self {
        Self {
            command_base_url: command_base_url.into(),
            query_base_url: query_base_url.into(),
        }
    }

    pub fn from_server_config(config: &ServerConfig) -> Self {
        Self::new(
            config.command_upstream_base_url.clone(),
            config.query_upstream_base_url.clone(),
        )
    }

    pub fn send_command_json(
        &self,
        path: &str,
        authorization_header: Option<&str>,
        request_correlation: &str,
        body: &str,
    ) -> Result<DownstreamHttpResponse, RelayClientError> {
        let target = parse_base_url(self.command_base_url.as_str())?;
        let request = DownstreamRequest {
            method: "POST".to_owned(),
            path: path.to_owned(),
            headers: request_headers(authorization_header, request_correlation, true, body.len()),
            body: Some(body.to_owned()),
        };
        execute_request(&target, &request)
    }

    pub fn send_query(
        &self,
        path: &str,
        authorization_header: Option<&str>,
        request_correlation: &str,
    ) -> Result<DownstreamHttpResponse, RelayClientError> {
        let target = parse_base_url(self.query_base_url.as_str())?;
        let request = DownstreamRequest {
            method: "GET".to_owned(),
            path: path.to_owned(),
            headers: request_headers(authorization_header, request_correlation, false, 0),
            body: None,
        };
        execute_request(&target, &request)
    }
}

pub fn parse_base_url(base_url: &str) -> Result<HttpTarget, RelayClientError> {
    let without_scheme = base_url
        .strip_prefix("http://")
        .ok_or(RelayClientError::InvalidBaseUrl)?;
    let (host, port) = without_scheme
        .split_once(':')
        .ok_or(RelayClientError::InvalidBaseUrl)?;

    let port = port
        .parse::<u16>()
        .map_err(|_| RelayClientError::InvalidBaseUrl)?;
    if host.trim().is_empty() {
        return Err(RelayClientError::InvalidBaseUrl);
    }

    Ok(HttpTarget {
        host: host.trim().to_owned(),
        port,
    })
}

pub fn request_headers(
    authorization_header: Option<&str>,
    request_correlation: &str,
    include_json_body: bool,
    content_length: usize,
) -> Vec<(String, String)> {
    let mut headers = vec![
        (
            REQUEST_CORRELATION_HEADER.to_owned(),
            request_correlation.to_owned(),
        ),
        ("Connection".to_owned(), "close".to_owned()),
    ];

    if let Some(authorization_header) = authorization_header {
        headers.push((
            AUTHORIZATION_HEADER.to_owned(),
            authorization_header.to_owned(),
        ));
    }

    if include_json_body {
        headers.push(("Content-Type".to_owned(), "application/json".to_owned()));
        headers.push(("Content-Length".to_owned(), content_length.to_string()));
    }

    headers
}

fn execute_request(
    target: &HttpTarget,
    request: &DownstreamRequest,
) -> Result<DownstreamHttpResponse, RelayClientError> {
    let mut stream = TcpStream::connect((target.host.as_str(), target.port))
        .map_err(|_| RelayClientError::Unavailable)?;
    stream
        .set_read_timeout(Some(Duration::from_secs(5)))
        .map_err(|_| RelayClientError::Unavailable)?;
    stream
        .set_write_timeout(Some(Duration::from_secs(5)))
        .map_err(|_| RelayClientError::Unavailable)?;

    let raw_request = build_http_request(target.host.as_str(), target.port, request);
    stream
        .write_all(raw_request.as_bytes())
        .map_err(|_| RelayClientError::Unavailable)?;
    stream.flush().map_err(|_| RelayClientError::Unavailable)?;

    let mut raw_response = String::new();
    stream
        .read_to_string(&mut raw_response)
        .map_err(|_| RelayClientError::InvalidResponse)?;
    parse_http_response(raw_response.as_str())
}

fn build_http_request(host: &str, port: u16, request: &DownstreamRequest) -> String {
    let mut rendered = format!(
        "{} {} HTTP/1.1\r\nHost: {}:{}\r\n",
        request.method, request.path, host, port
    );

    for (header_name, header_value) in &request.headers {
        rendered.push_str(&format!("{header_name}: {header_value}\r\n"));
    }
    rendered.push_str("\r\n");
    if let Some(body) = &request.body {
        rendered.push_str(body);
    }

    rendered
}

fn parse_http_response(raw_response: &str) -> Result<DownstreamHttpResponse, RelayClientError> {
    let (head, body) = raw_response
        .split_once("\r\n\r\n")
        .ok_or(RelayClientError::InvalidResponse)?;
    let mut lines = head.lines();
    let status_code = lines
        .next()
        .and_then(|status_line| status_line.split_whitespace().nth(1))
        .and_then(|status| status.parse::<u16>().ok())
        .ok_or(RelayClientError::InvalidResponse)?;

    let mut headers = HashMap::new();
    for line in lines {
        if let Some((name, value)) = line.split_once(':') {
            headers.insert(name.trim().to_ascii_lowercase(), value.trim().to_owned());
        }
    }

    Ok(DownstreamHttpResponse {
        status_code,
        headers,
        body: body.to_owned(),
    })
}
