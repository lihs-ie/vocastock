pub mod command;
pub mod http;
pub mod runtime;

pub use command::{
    accept_mutation_command, accept_register_command, fingerprint_for, normalize_text,
    parse_register_command, parse_request_explanation_generation, parse_request_image_generation,
    parse_request_purchase, parse_request_restore_purchase, parse_retry_generation,
    success_envelope, AcceptanceOutcome, AcceptanceOutcomeCode, AcceptedCommandFields,
    AcceptedCommandResult, CommandErrorCategory, CommandFailure, CommandResponseEnvelope,
    DuplicateReuseResult, GenerationTargetKind, MutationCommand, MutationRequestError, PlanCode,
    RegisterVocabularyCommandEnvelope, RegisterVocabularyExpressionCommand,
    RequestExplanationGenerationCommand, RequestImageGenerationCommand, RequestPurchaseCommand,
    RequestRestorePurchaseCommand, RequestValidationError, RetryGenerationCommand, StateSummary,
    TargetReference, UserFacingMessage,
};
pub use http::{
    read_request, render_command_failure, route_request, write_response, RenderedResponse, Request,
    RequestReadError, RouteContext,
};
pub use runtime::{
    bind_listener, build_dispatch_message, handle_connection, parse_idempotency_document,
    parse_mutation_idempotency_document, parse_registration_document, run_accept_loop, run_server,
    serve_incoming_stream, startup_message, status_handle_for, vocabulary_expression_for,
    CommandStore, DispatchKind, DispatchOutcome, DispatchPlan, DispatchPort, DispatchRequest,
    FirestoreCommandStore, FirestoreMutationCommandStore, IdempotencyDecision, IdempotencyDocument,
    InMemoryCommandStore, InMemoryDispatchPort, MutationCommandStore, MutationFingerprint,
    MutationIdempotencyDocument, PubSubDispatchPort, ServerConfig, StoreDecision,
    StoredRegistration, StubTokenVerifier, EXPLANATION_STATE_FAILED_FINAL,
    EXPLANATION_STATE_NOT_STARTED, EXPLANATION_STATE_QUEUED, REGISTERED_STATE,
    REGISTER_VOCABULARY_EXPRESSION_PATH, REQUEST_EXPLANATION_GENERATION_PATH,
    REQUEST_IMAGE_GENERATION_PATH, REQUEST_PURCHASE_PATH, REQUEST_RESTORE_PURCHASE_PATH,
    RETRY_GENERATION_PATH, ROOT_MESSAGE, SERVICE_NAME, STATUS_HANDLE_PREFIX,
};
