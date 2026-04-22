//! Firebase Auth ID token verifier.
//!
//! The production command-api / query-api binaries receive Firebase Auth
//! ID tokens from the mobile client (`FirebaseAuthTokenSupplier` on the
//! Flutter side). Rather than re-implementing JWT signature verification
//! in handwritten Rust, we delegate to the Firebase Auth service — the
//! emulator during CI / local development, the production Firebase Auth
//! REST API when connected to live Google infrastructure — which already
//! validates the signature and returns the decoded user record.
//!
//! The verifier is pointed at the Firebase Auth emulator via
//! `FIREBASE_AUTH_EMULATOR_HOST=<host>:<port>`. The emulator ignores the
//! `key` query parameter but still requires one, so we allow callers to
//! override it with `FIREBASE_AUTH_API_KEY` (default sentinel is fine
//! against the emulator).

use std::env;

use crate::{
    ActorReference, AuthAccountReference, SessionReference, SessionState, TokenVerificationError,
    TokenVerificationPort, VerifiedActorContext,
};

pub const FIREBASE_AUTH_EMULATOR_HOST_ENV: &str = "FIREBASE_AUTH_EMULATOR_HOST";
pub const FIREBASE_AUTH_API_KEY_ENV: &str = "FIREBASE_AUTH_API_KEY";
pub const DEFAULT_EMULATOR_API_KEY: &str = "demo-emulator-api-key";

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct FirebaseAuthTokenVerifier {
    emulator_host: String,
    api_key: String,
}

impl FirebaseAuthTokenVerifier {
    pub fn new(emulator_host: impl Into<String>, api_key: impl Into<String>) -> Self {
        Self {
            emulator_host: emulator_host.into(),
            api_key: api_key.into(),
        }
    }

    /// Builds a verifier from `FIREBASE_AUTH_EMULATOR_HOST` +
    /// `FIREBASE_AUTH_API_KEY` (optional). Returns `None` when the
    /// emulator host env var is missing / blank, leaving the caller to
    /// decide whether that should panic or fall back.
    pub fn from_env() -> Option<Self> {
        let emulator_host = env::var(FIREBASE_AUTH_EMULATOR_HOST_ENV)
            .ok()?
            .trim()
            .to_owned();
        if emulator_host.is_empty() {
            return None;
        }
        let api_key = env::var(FIREBASE_AUTH_API_KEY_ENV)
            .ok()
            .filter(|value| !value.trim().is_empty())
            .unwrap_or_else(|| DEFAULT_EMULATOR_API_KEY.to_owned());
        Some(Self::new(emulator_host, api_key))
    }

    pub fn emulator_host(&self) -> &str {
        &self.emulator_host
    }

    pub fn api_key(&self) -> &str {
        &self.api_key
    }

    fn lookup_path(&self) -> String {
        format!(
            "/identitytoolkit.googleapis.com/v1/accounts:lookup?key={}",
            self.api_key
        )
    }

    fn lookup_body(bearer_token: &str) -> String {
        // The emulator only decodes the `idToken` field, so a minimal JSON
        // document is sufficient. Escape the token defensively — it is
        // supplied by the client and must not break out of the JSON
        // string literal.
        let escaped = escape_json_string(bearer_token);
        format!(r#"{{"idToken":"{escaped}"}}"#)
    }
}

impl TokenVerificationPort for FirebaseAuthTokenVerifier {
    fn verify(&self, bearer_token: &str) -> Result<VerifiedActorContext, TokenVerificationError> {
        if bearer_token.trim().is_empty() {
            return Err(TokenVerificationError::MissingToken);
        }

        let body = Self::lookup_body(bearer_token);
        let path = self.lookup_path();
        let response = shared_firestore::execute_post(&self.emulator_host, &path, &body)
            .map_err(|_| TokenVerificationError::InvalidToken)?;

        let payload: serde_json::Value =
            serde_json::from_str(&response).map_err(|_| TokenVerificationError::InvalidToken)?;

        let user = payload
            .get("users")
            .and_then(|users| users.as_array())
            .and_then(|users| users.first())
            .ok_or(TokenVerificationError::InvalidToken)?;

        let local_id = user
            .get("localId")
            .and_then(|value| value.as_str())
            .filter(|value| !value.is_empty())
            .ok_or(TokenVerificationError::InvalidToken)?;

        let auth_account = user
            .get("email")
            .and_then(|value| value.as_str())
            .map(|email| format!("auth:{email}"))
            .unwrap_or_else(|| format!("auth:{local_id}"));

        let session_state = if user
            .get("disabled")
            .and_then(|value| value.as_bool())
            .unwrap_or(false)
        {
            SessionState::ReauthRequired
        } else {
            SessionState::Active
        };

        Ok(VerifiedActorContext::new(
            ActorReference::new(local_id),
            AuthAccountReference::new(auth_account),
            SessionReference::new(format!("session:{local_id}")),
            session_state,
        ))
    }
}

fn escape_json_string(value: &str) -> String {
    let mut escaped = String::with_capacity(value.len());
    for ch in value.chars() {
        match ch {
            '"' => escaped.push_str("\\\""),
            '\\' => escaped.push_str("\\\\"),
            '\n' => escaped.push_str("\\n"),
            '\r' => escaped.push_str("\\r"),
            '\t' => escaped.push_str("\\t"),
            c if (c as u32) < 0x20 => {
                escaped.push_str(&format!("\\u{:04x}", c as u32));
            }
            c => escaped.push(c),
        }
    }
    escaped
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn verifier_rejects_empty_token_before_touching_network() {
        let verifier = FirebaseAuthTokenVerifier::new("127.0.0.1:19099", "demo-key");
        assert_eq!(
            verifier.verify("   "),
            Err(TokenVerificationError::MissingToken)
        );
        assert_eq!(
            verifier.verify(""),
            Err(TokenVerificationError::MissingToken)
        );
    }

    #[test]
    fn lookup_path_embeds_api_key() {
        let verifier = FirebaseAuthTokenVerifier::new("127.0.0.1:19099", "custom-key");
        assert_eq!(
            verifier.lookup_path(),
            "/identitytoolkit.googleapis.com/v1/accounts:lookup?key=custom-key"
        );
    }

    #[test]
    fn lookup_body_escapes_quotes_and_controls() {
        let body = FirebaseAuthTokenVerifier::lookup_body("abc\"def\nghi");
        assert_eq!(body, r#"{"idToken":"abc\"def\nghi"}"#);
    }

    #[test]
    fn escape_json_string_handles_low_controls_via_unicode_escape() {
        let escaped = escape_json_string("a\u{0001}b");
        assert_eq!(escaped, "a\\u0001b");
    }

    #[test]
    fn from_env_returns_none_when_host_missing() {
        // Ensure a clean environment for this test specifically. We
        // cannot rely on it being unset by default, so temporarily
        // remove it and restore at the end.
        let saved = std::env::var(FIREBASE_AUTH_EMULATOR_HOST_ENV).ok();
        std::env::remove_var(FIREBASE_AUTH_EMULATOR_HOST_ENV);
        let verifier = FirebaseAuthTokenVerifier::from_env();
        assert!(verifier.is_none());
        if let Some(value) = saved {
            std::env::set_var(FIREBASE_AUTH_EMULATOR_HOST_ENV, value);
        }
    }
}
