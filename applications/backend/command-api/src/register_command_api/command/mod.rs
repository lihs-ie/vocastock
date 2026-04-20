pub mod acceptance;
pub mod request;
pub mod response;

pub use acceptance::accept_register_command;
pub use request::{
    normalize_text, parse_register_command, RegisterVocabularyCommandEnvelope,
    RegisterVocabularyExpressionCommand, RequestValidationError,
};
pub use response::{
    AcceptanceOutcome, AcceptedCommandFields, AcceptedCommandResult, CommandFailure,
    DuplicateReuseResult, StateSummary, TargetReference,
};
