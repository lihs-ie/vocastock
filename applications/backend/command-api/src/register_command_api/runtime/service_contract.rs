pub const SERVICE_NAME: &str = "command-api";
pub const REGISTER_VOCABULARY_EXPRESSION_PATH: &str = "/commands/register-vocabulary-expression";
pub const ROOT_MESSAGE: &str =
    "command-api accepts register commands and returns accepted/reused-existing or failures without completed payloads";
pub const STATUS_HANDLE_PREFIX: &str = "status";
pub const REGISTERED_STATE: &str = "registered";
pub const EXPLANATION_STATE_QUEUED: &str = "queued";
pub const EXPLANATION_STATE_NOT_STARTED: &str = "not-started";
pub const EXPLANATION_STATE_FAILED_FINAL: &str = "failed-final";

pub fn vocabulary_expression_for(normalized_text: &str) -> String {
    format!("vocabulary:{}", normalized_text.replace(' ', "-"))
}

pub fn status_handle_for(actor_reference: &str, vocabulary_expression: &str) -> String {
    format!("{STATUS_HANDLE_PREFIX}:{actor_reference}:{vocabulary_expression}")
}
