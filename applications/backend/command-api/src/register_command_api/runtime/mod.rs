pub mod command_store;
pub mod dispatch_port;
pub mod firestore_command_store;
pub mod firestore_mutation_command_store;
pub mod mutation_command_store;
pub mod pubsub_dispatch_port;
pub mod server_loop;
pub mod service_contract;

pub use command_store::{
    CommandStore, InMemoryCommandStore, PlannedNewRegistration, PlannedReuseRegistration,
    StoreDecision, StoredRegistration,
};
pub use dispatch_port::{
    DispatchKind, DispatchOutcome, DispatchPlan, DispatchPort, DispatchRequest,
    InMemoryDispatchPort,
};
pub use firestore_command_store::{
    parse_idempotency_document, parse_registration_document, FirestoreCommandStore,
    IdempotencyDocument,
};
pub use firestore_mutation_command_store::{
    parse_mutation_idempotency_document, FirestoreMutationCommandStore, MutationIdempotencyDocument,
};
pub use mutation_command_store::{IdempotencyDecision, MutationCommandStore, MutationFingerprint};
pub use pubsub_dispatch_port::{build_dispatch_message, PubSubDispatchPort};
pub use server_loop::{
    bind_listener, handle_connection, run_accept_loop, run_server, serve_incoming_stream,
    startup_message, ServerConfig,
};
pub use service_contract::{
    status_handle_for, vocabulary_expression_for, EXPLANATION_STATE_FAILED_FINAL,
    EXPLANATION_STATE_NOT_STARTED, EXPLANATION_STATE_QUEUED, REGISTERED_STATE,
    REGISTER_VOCABULARY_EXPRESSION_PATH, REQUEST_EXPLANATION_GENERATION_PATH,
    REQUEST_IMAGE_GENERATION_PATH, REQUEST_PURCHASE_PATH, REQUEST_RESTORE_PURCHASE_PATH,
    RETRY_GENERATION_PATH, ROOT_MESSAGE, SERVICE_NAME, STATUS_HANDLE_PREFIX,
};
