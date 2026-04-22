//! Minimal PubSub emulator REST publisher.
//!
//! Uses the HTTP TCP client from `shared_firestore` since both services
//! target the same Firebase emulator suite and both avoid tokio/reqwest
//! transitive dependencies. The publisher encodes messages in the
//! canonical Google PubSub REST format (`data` field base64-encoded).

use std::env;

use shared_firestore::http::{execute_post, FirestoreHttpError};

/// Environment variable the PubSub emulator exports
/// (e.g. `127.0.0.1:18085`).
pub const PUBSUB_EMULATOR_HOST_ENV: &str = "PUBSUB_EMULATOR_HOST";

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct PubSubPublisher {
    emulator_host: String,
    project_id: String,
}

impl PubSubPublisher {
    /// Construct a publisher from environment variables. Returns `None`
    /// when `VOCAS_PRODUCTION_ADAPTERS` is not enabled or the emulator
    /// host is not set, matching the pattern used by
    /// `shared_firestore` adapters.
    pub fn from_env() -> Option<Self> {
        if !shared_firestore::production_adapters_enabled() {
            return None;
        }
        let host = env::var(PUBSUB_EMULATOR_HOST_ENV).ok()?;
        let host = host.trim().to_owned();
        if host.is_empty() {
            return None;
        }
        Some(Self {
            emulator_host: host,
            project_id: shared_firestore::resolve_project_id(),
        })
    }

    pub fn new(emulator_host: impl Into<String>, project_id: impl Into<String>) -> Self {
        Self {
            emulator_host: emulator_host.into(),
            project_id: project_id.into(),
        }
    }

    pub fn emulator_host(&self) -> &str {
        &self.emulator_host
    }

    pub fn project_id(&self) -> &str {
        &self.project_id
    }

    /// Publish one or more messages to a topic and return the resulting
    /// message IDs. The emulator will return an HTTP error if the topic
    /// does not exist — tests and local dev are expected to seed topics
    /// via `firebase/seed/seed.mjs`.
    pub fn publish(
        &self,
        topic: &str,
        messages: &[PubSubMessage],
    ) -> Result<Vec<String>, PubSubPublishError> {
        let path = format!("/v1/projects/{}/topics/{}:publish", self.project_id, topic);
        let body = build_publish_body(messages);
        let response = execute_post(self.emulator_host.as_str(), path.as_str(), body.as_str())
            .map_err(map_http_error)?;
        parse_message_ids(response.as_str()).ok_or(PubSubPublishError::InvalidResponse)
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct PubSubMessage {
    pub data: Vec<u8>,
    pub attributes: Vec<(String, String)>,
}

impl PubSubMessage {
    pub fn new(data: impl Into<Vec<u8>>) -> Self {
        Self {
            data: data.into(),
            attributes: Vec::new(),
        }
    }

    pub fn with_attribute(mut self, key: impl Into<String>, value: impl Into<String>) -> Self {
        self.attributes.push((key.into(), value.into()));
        self
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum PubSubPublishError {
    Transport,
    HttpStatus(u16),
    InvalidResponse,
}

fn map_http_error(error: FirestoreHttpError) -> PubSubPublishError {
    match error {
        FirestoreHttpError::Transport => PubSubPublishError::Transport,
        FirestoreHttpError::HttpStatus(code) => PubSubPublishError::HttpStatus(code),
        FirestoreHttpError::InvalidResponse => PubSubPublishError::InvalidResponse,
    }
}

pub(crate) fn build_publish_body(messages: &[PubSubMessage]) -> String {
    use serde_json::{json, Value};
    let entries: Vec<Value> = messages
        .iter()
        .map(|message| {
            let mut attributes = serde_json::Map::new();
            for (key, value) in &message.attributes {
                attributes.insert(key.clone(), Value::String(value.clone()));
            }
            let mut entry = serde_json::Map::new();
            entry.insert(
                "data".to_owned(),
                Value::String(encode_base64(&message.data)),
            );
            if !attributes.is_empty() {
                entry.insert("attributes".to_owned(), Value::Object(attributes));
            }
            Value::Object(entry)
        })
        .collect();
    json!({ "messages": entries }).to_string()
}

pub(crate) fn parse_message_ids(body: &str) -> Option<Vec<String>> {
    let payload = serde_json::from_str::<serde_json::Value>(body).ok()?;
    let ids = payload.get("messageIds")?.as_array()?;
    Some(
        ids.iter()
            .filter_map(|id| id.as_str().map(str::to_owned))
            .collect(),
    )
}

/// Standard base64 encoder (RFC 4648, no line breaks, `+/` alphabet and
/// `=` padding). Tiny hand-rolled implementation to avoid pulling in a
/// crate solely for PubSub publish bodies.
pub fn encode_base64(data: &[u8]) -> String {
    const ALPHABET: &[u8; 64] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    let mut encoded = String::with_capacity(data.len().div_ceil(3) * 4);
    let mut chunks = data.chunks_exact(3);
    for chunk in chunks.by_ref() {
        let combined = ((chunk[0] as u32) << 16) | ((chunk[1] as u32) << 8) | (chunk[2] as u32);
        encoded.push(ALPHABET[((combined >> 18) & 0x3F) as usize] as char);
        encoded.push(ALPHABET[((combined >> 12) & 0x3F) as usize] as char);
        encoded.push(ALPHABET[((combined >> 6) & 0x3F) as usize] as char);
        encoded.push(ALPHABET[(combined & 0x3F) as usize] as char);
    }
    let remainder = chunks.remainder();
    match remainder.len() {
        0 => {}
        1 => {
            let combined = (remainder[0] as u32) << 16;
            encoded.push(ALPHABET[((combined >> 18) & 0x3F) as usize] as char);
            encoded.push(ALPHABET[((combined >> 12) & 0x3F) as usize] as char);
            encoded.push('=');
            encoded.push('=');
        }
        2 => {
            let combined = ((remainder[0] as u32) << 16) | ((remainder[1] as u32) << 8);
            encoded.push(ALPHABET[((combined >> 18) & 0x3F) as usize] as char);
            encoded.push(ALPHABET[((combined >> 12) & 0x3F) as usize] as char);
            encoded.push(ALPHABET[((combined >> 6) & 0x3F) as usize] as char);
            encoded.push('=');
        }
        _ => unreachable!(),
    }
    encoded
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn encode_base64_round_trips_canonical_fixtures() {
        assert_eq!(encode_base64(b""), "");
        assert_eq!(encode_base64(b"f"), "Zg==");
        assert_eq!(encode_base64(b"fo"), "Zm8=");
        assert_eq!(encode_base64(b"foo"), "Zm9v");
        assert_eq!(encode_base64(b"foob"), "Zm9vYg==");
        assert_eq!(encode_base64(b"fooba"), "Zm9vYmE=");
        assert_eq!(encode_base64(b"foobar"), "Zm9vYmFy");
    }

    #[test]
    fn build_publish_body_embeds_base64_data_and_attributes() {
        let body = build_publish_body(&[
            PubSubMessage::new(b"hello".to_vec()).with_attribute("correlation", "abc")
        ]);
        assert!(body.contains("\"data\":\"aGVsbG8=\""));
        assert!(body.contains("\"attributes\":{\"correlation\":\"abc\"}"));
    }

    #[test]
    fn parse_message_ids_reads_google_pubsub_shape() {
        let ids = parse_message_ids("{\"messageIds\":[\"1\",\"2\"]}").unwrap();
        assert_eq!(ids, vec!["1".to_owned(), "2".to_owned()]);
    }
}
