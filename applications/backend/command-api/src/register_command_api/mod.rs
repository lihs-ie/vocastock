pub mod command;
pub mod http;
pub mod runtime;

pub use command::{
    accept_register_command, normalize_text, parse_register_command, AcceptanceOutcome,
    AcceptedCommandFields, AcceptedCommandResult, CommandFailure, DuplicateReuseResult,
    RegisterVocabularyCommandEnvelope, RegisterVocabularyExpressionCommand, RequestValidationError,
    StateSummary, TargetReference,
};
pub use http::{
    read_request, render_command_failure, route_request, write_response, RenderedResponse, Request,
    RequestReadError,
};
pub use runtime::{
    bind_listener, handle_connection, run_accept_loop, run_server, serve_incoming_stream,
    startup_message, status_handle_for, vocabulary_expression_for, DispatchOutcome, DispatchPlan,
    DispatchRequest, InMemoryCommandStore, InMemoryDispatchPort, ServerConfig, StoreDecision,
    StubTokenVerifier, EXPLANATION_STATE_FAILED_FINAL, EXPLANATION_STATE_NOT_STARTED,
    EXPLANATION_STATE_QUEUED, REGISTERED_STATE, REGISTER_VOCABULARY_EXPRESSION_PATH, ROOT_MESSAGE,
    SERVICE_NAME, STATUS_HANDLE_PREFIX,
};
