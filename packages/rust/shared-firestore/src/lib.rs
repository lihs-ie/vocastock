//! Shared helpers for the Firestore emulator REST surface.
//!
//! The crate is deliberately stdlib-only aside from `serde_json`: both
//! `query-api` and `command-api` use the hand-rolled TCP client so the
//! workspace avoids pulling in tokio / reqwest transitive dependencies.
//! Production deployments will need TLS and request signing that a
//! future adapter can layer on top of this foundation.

pub mod http;
pub mod value;

pub use http::{
    execute_get, execute_post, percent_encode_path, production_adapters_enabled,
    resolve_emulator_host, resolve_project_id, FirestoreHttpError, DEFAULT_PROJECT_ID,
    FIRESTORE_EMULATOR_HOST_ENV, PRODUCTION_ADAPTERS_ENV,
};
pub use value::{
    read_array_field, read_integer_field, read_map_field, read_nullable_string_field,
    read_string_field, value_as_map,
};
