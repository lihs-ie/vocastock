//! TCP / HTTP-1.1 helpers for the Firestore emulator.
//!
//! The emulator does not honour `Connection: close` reliably, so we
//! read the response headers first, then consume exactly the number of
//! body bytes indicated by `Content-Length` (or the chunked transfer
//! encoding). This avoids the `read_to_string` hang observed in the
//! initial query-api port.

use std::env;
use std::io::{BufRead, BufReader, Write};
use std::net::TcpStream;
use std::time::Duration;

/// Environment variable the Firestore emulator exports
/// (e.g. `127.0.0.1:18080`).
pub const FIRESTORE_EMULATOR_HOST_ENV: &str = "FIRESTORE_EMULATOR_HOST";

/// Opt-in flag that switches adapters from the in-memory fixture to the
/// Firestore-backed reader/writer.
pub const PRODUCTION_ADAPTERS_ENV: &str = "VOCAS_PRODUCTION_ADAPTERS";

/// Default demo project ID; production wiring should override via env.
pub const DEFAULT_PROJECT_ID: &str = "demo-vocastock";

#[derive(Debug, Clone, Eq, PartialEq)]
pub enum FirestoreHttpError {
    /// TCP connect / IO failure, including DNS resolution errors.
    Transport,
    /// The server responded but with a non-2xx status.
    HttpStatus(u16),
    /// The response body was truncated or malformed.
    InvalidResponse,
}

pub fn production_adapters_enabled() -> bool {
    env::var(PRODUCTION_ADAPTERS_ENV)
        .ok()
        .map(|value| matches!(value.trim(), "true" | "1" | "yes"))
        .unwrap_or(false)
}

pub fn resolve_emulator_host() -> Option<String> {
    let host = env::var(FIRESTORE_EMULATOR_HOST_ENV).ok()?;
    let host = host.trim().to_owned();
    if host.is_empty() {
        None
    } else {
        Some(host)
    }
}

pub fn resolve_project_id() -> String {
    env::var("FIREBASE_PROJECT")
        .ok()
        .filter(|value| !value.trim().is_empty())
        .unwrap_or_else(|| DEFAULT_PROJECT_ID.to_owned())
}

pub fn execute_get(host_port: &str, path: &str) -> Result<String, FirestoreHttpError> {
    execute_request(host_port, "GET", path, None)
}

pub fn execute_post(
    host_port: &str,
    path: &str,
    json_body: &str,
) -> Result<String, FirestoreHttpError> {
    execute_request(host_port, "POST", path, Some(json_body))
}

fn execute_request(
    host_port: &str,
    method: &str,
    path: &str,
    json_body: Option<&str>,
) -> Result<String, FirestoreHttpError> {
    let (host, port) = parse_host_port(host_port).ok_or(FirestoreHttpError::Transport)?;
    let stream =
        TcpStream::connect((host.as_str(), port)).map_err(|_| FirestoreHttpError::Transport)?;
    stream
        .set_read_timeout(Some(Duration::from_secs(5)))
        .map_err(|_| FirestoreHttpError::Transport)?;
    stream
        .set_write_timeout(Some(Duration::from_secs(5)))
        .map_err(|_| FirestoreHttpError::Transport)?;

    let mut reader = BufReader::new(stream);
    let mut request =
        format!("{method} {path} HTTP/1.1\r\nHost: {host}:{port}\r\nConnection: close\r\n");
    if let Some(body) = json_body {
        request.push_str("Content-Type: application/json; charset=utf-8\r\n");
        request.push_str(&format!("Content-Length: {}\r\n", body.len()));
        request.push_str("\r\n");
        request.push_str(body);
    } else {
        request.push_str("\r\n");
    }

    reader
        .get_mut()
        .write_all(request.as_bytes())
        .map_err(|_| FirestoreHttpError::Transport)?;
    reader
        .get_mut()
        .flush()
        .map_err(|_| FirestoreHttpError::Transport)?;

    read_http_response_body(&mut reader)
}

fn read_http_response_body<R: BufRead>(reader: &mut R) -> Result<String, FirestoreHttpError> {
    let mut status_line = String::new();
    if reader
        .read_line(&mut status_line)
        .map_err(|_| FirestoreHttpError::Transport)?
        == 0
    {
        return Err(FirestoreHttpError::InvalidResponse);
    }
    let status_code =
        parse_status_code(status_line.as_str()).ok_or(FirestoreHttpError::InvalidResponse)?;

    let mut content_length: Option<usize> = None;
    let mut transfer_encoding_chunked = false;
    loop {
        let mut header_line = String::new();
        let bytes = reader
            .read_line(&mut header_line)
            .map_err(|_| FirestoreHttpError::Transport)?;
        if bytes == 0 || header_line == "\r\n" || header_line == "\n" {
            break;
        }
        if let Some((name, value)) = header_line.split_once(':') {
            let name = name.trim().to_ascii_lowercase();
            let value = value.trim();
            if name == "content-length" {
                content_length = value.parse::<usize>().ok();
            } else if name == "transfer-encoding" && value.eq_ignore_ascii_case("chunked") {
                transfer_encoding_chunked = true;
            }
        }
    }

    let body = if transfer_encoding_chunked {
        read_chunked_body(reader)?
    } else {
        let length = content_length.ok_or(FirestoreHttpError::InvalidResponse)?;
        read_exact_body(reader, length)?
    };

    if !(200..=299).contains(&status_code) {
        return Err(FirestoreHttpError::HttpStatus(status_code));
    }

    Ok(body)
}

fn read_exact_body<R: BufRead>(
    reader: &mut R,
    length: usize,
) -> Result<String, FirestoreHttpError> {
    let mut buffer = vec![0u8; length];
    reader
        .read_exact(&mut buffer)
        .map_err(|_| FirestoreHttpError::InvalidResponse)?;
    String::from_utf8(buffer).map_err(|_| FirestoreHttpError::InvalidResponse)
}

fn read_chunked_body<R: BufRead>(reader: &mut R) -> Result<String, FirestoreHttpError> {
    let mut body = Vec::new();
    loop {
        let mut size_line = String::new();
        if reader
            .read_line(&mut size_line)
            .map_err(|_| FirestoreHttpError::Transport)?
            == 0
        {
            return Err(FirestoreHttpError::InvalidResponse);
        }
        let size_hex = size_line.trim_end_matches(['\r', '\n']);
        let size_hex = size_hex.split(';').next().unwrap_or("").trim();
        let size =
            usize::from_str_radix(size_hex, 16).map_err(|_| FirestoreHttpError::InvalidResponse)?;
        if size == 0 {
            break;
        }
        let mut chunk = vec![0u8; size];
        reader
            .read_exact(&mut chunk)
            .map_err(|_| FirestoreHttpError::InvalidResponse)?;
        body.extend_from_slice(&chunk);
        let mut trailing = [0u8; 2];
        reader
            .read_exact(&mut trailing)
            .map_err(|_| FirestoreHttpError::InvalidResponse)?;
    }
    String::from_utf8(body).map_err(|_| FirestoreHttpError::InvalidResponse)
}

fn parse_status_code(status_line: &str) -> Option<u16> {
    status_line.split_whitespace().nth(1)?.parse::<u16>().ok()
}

fn parse_host_port(host_port: &str) -> Option<(String, u16)> {
    let (host, port) = host_port.split_once(':')?;
    let port = port.parse::<u16>().ok()?;
    Some((host.trim().to_owned(), port))
}

pub fn percent_encode_path(raw: &str) -> String {
    let mut buffer = String::with_capacity(raw.len());
    for byte in raw.as_bytes() {
        match byte {
            b'A'..=b'Z' | b'a'..=b'z' | b'0'..=b'9' | b'-' | b'_' | b'.' | b'~' => {
                buffer.push(*byte as char);
            }
            _ => buffer.push_str(&format!("%{byte:02X}")),
        }
    }
    buffer
}
