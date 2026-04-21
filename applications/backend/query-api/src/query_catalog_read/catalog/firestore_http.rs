//! Shared TCP-based Firestore emulator REST helpers. This module is
//! intentionally minimal: each detail reader uses `execute_get` against
//! `FIRESTORE_EMULATOR_HOST`, so there is no tokio / reqwest transitive
//! dependency. Production deployments will need TLS and request signing
//! that a future `shared-firestore` crate can encapsulate; for now the
//! emulator surface is enough.

use std::env;
use std::io::{BufRead, BufReader, Write};
use std::net::TcpStream;
use std::time::Duration;

/// Environment variable the Firestore emulator exports
/// (e.g. `127.0.0.1:18080`).
pub const FIRESTORE_EMULATOR_HOST_ENV: &str = "FIRESTORE_EMULATOR_HOST";

/// Opt-in flag that switches read sources from the in-memory fixture
/// (where applicable) to the Firestore-backed readers.
pub const PRODUCTION_ADAPTERS_ENV: &str = "VOCAS_PRODUCTION_ADAPTERS";

/// Default demo project ID; production wiring should override via env.
pub const DEFAULT_PROJECT_ID: &str = "demo-vocastock";

pub(crate) fn production_adapters_enabled() -> bool {
    env::var(PRODUCTION_ADAPTERS_ENV)
        .ok()
        .map(|value| matches!(value.trim(), "true" | "1" | "yes"))
        .unwrap_or(false)
}

pub(crate) fn resolve_emulator_host() -> Option<String> {
    let host = env::var(FIRESTORE_EMULATOR_HOST_ENV).ok()?;
    let host = host.trim().to_owned();
    if host.is_empty() {
        None
    } else {
        Some(host)
    }
}

pub(crate) fn resolve_project_id() -> String {
    env::var("FIREBASE_PROJECT")
        .ok()
        .filter(|value| !value.trim().is_empty())
        .unwrap_or_else(|| DEFAULT_PROJECT_ID.to_owned())
}

pub(crate) fn execute_get(host_port: &str, path: &str) -> Result<String, ()> {
    let (host, port) = parse_host_port(host_port).ok_or(())?;
    let stream = TcpStream::connect((host.as_str(), port)).map_err(|_| ())?;
    stream
        .set_read_timeout(Some(Duration::from_secs(3)))
        .map_err(|_| ())?;
    stream
        .set_write_timeout(Some(Duration::from_secs(3)))
        .map_err(|_| ())?;

    let mut reader = BufReader::new(stream);
    let request =
        format!("GET {path} HTTP/1.1\r\nHost: {host}:{port}\r\nConnection: close\r\n\r\n");
    reader
        .get_mut()
        .write_all(request.as_bytes())
        .map_err(|_| ())?;
    reader.get_mut().flush().map_err(|_| ())?;

    read_http_response_body(&mut reader)
}

fn read_http_response_body<R: BufRead>(reader: &mut R) -> Result<String, ()> {
    // Parse the status line purely to confirm we received an HTTP/1.x
    // response. Non-2xx statuses are surfaced to the caller as an empty
    // body via an Err so detail readers can map them to "None".
    let mut status_line = String::new();
    if reader.read_line(&mut status_line).map_err(|_| ())? == 0 {
        return Err(());
    }
    let status_code = parse_status_code(status_line.as_str()).ok_or(())?;

    // Accumulate headers until the blank line; this also avoids
    // allocating the entire response into a single String when the
    // server pins the connection open with keep-alive semantics even
    // after we send `Connection: close` (Firestore emulator does this).
    let mut content_length: Option<usize> = None;
    let mut transfer_encoding_chunked = false;
    loop {
        let mut header_line = String::new();
        let bytes = reader.read_line(&mut header_line).map_err(|_| ())?;
        if bytes == 0 || header_line == "\r\n" || header_line == "\n" {
            break;
        }
        if let Some((name, value)) = header_line.split_once(':') {
            let name = name.trim().to_ascii_lowercase();
            let value = value.trim();
            if name == "content-length" {
                content_length = value.parse::<usize>().ok();
            } else if name == "transfer-encoding"
                && value.eq_ignore_ascii_case("chunked")
            {
                transfer_encoding_chunked = true;
            }
        }
    }

    if !(200..=299).contains(&status_code) {
        return Err(());
    }

    if transfer_encoding_chunked {
        return read_chunked_body(reader);
    }

    let length = content_length.ok_or(())?;
    let mut body = vec![0u8; length];
    reader.read_exact(&mut body).map_err(|_| ())?;
    String::from_utf8(body).map_err(|_| ())
}

fn read_chunked_body<R: BufRead>(reader: &mut R) -> Result<String, ()> {
    let mut body = Vec::new();
    loop {
        let mut size_line = String::new();
        if reader.read_line(&mut size_line).map_err(|_| ())? == 0 {
            return Err(());
        }
        let size_hex = size_line.trim_end_matches(['\r', '\n']);
        let size_hex = size_hex.split(';').next().unwrap_or("").trim();
        let size = usize::from_str_radix(size_hex, 16).map_err(|_| ())?;
        if size == 0 {
            break;
        }
        let mut chunk = vec![0u8; size];
        reader.read_exact(&mut chunk).map_err(|_| ())?;
        body.extend_from_slice(&chunk);
        let mut trailing = [0u8; 2];
        reader.read_exact(&mut trailing).map_err(|_| ())?;
    }
    String::from_utf8(body).map_err(|_| ())
}

fn parse_status_code(status_line: &str) -> Option<u16> {
    status_line.split_whitespace().nth(1)?.parse::<u16>().ok()
}

fn parse_host_port(host_port: &str) -> Option<(String, u16)> {
    let (host, port) = host_port.split_once(':')?;
    let port = port.parse::<u16>().ok()?;
    Some((host.trim().to_owned(), port))
}

pub(crate) fn percent_encode_path(raw: &str) -> String {
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
