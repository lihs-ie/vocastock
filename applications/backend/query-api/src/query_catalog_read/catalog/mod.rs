pub(crate) mod firestore_http;
mod firestore_source;
pub(crate) mod firestore_value;
mod model;
mod read;
mod source;

pub use firestore_http::{
    DEFAULT_PROJECT_ID, FIRESTORE_EMULATOR_HOST_ENV, PRODUCTION_ADAPTERS_ENV,
};
pub use firestore_source::FirestoreCatalogProjectionSource;
pub use model::{
    CatalogReadResponse, CatalogVisibility, CollectionState, ProjectionFreshness,
    VocabularyCatalogItem, WorkflowState,
};
pub use read::{read_catalog, read_catalog_from_authorization_header, CatalogReadError};
pub use source::{
    CatalogProjectionSource, InMemoryCatalogProjectionSource, ProjectionSourceRecord,
};
