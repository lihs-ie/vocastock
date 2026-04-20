use command_api::{
    AcceptanceOutcome, CommandFailure, RegisterVocabularyCommandEnvelope, RequestValidationError,
};

#[test]
fn command_module_exports_expected_types() {
    let envelope_type = std::any::type_name::<RegisterVocabularyCommandEnvelope>();
    assert!(envelope_type.contains("RegisterVocabularyCommandEnvelope"));
    assert_eq!(AcceptanceOutcome::Accepted.as_str(), "accepted");
    assert_eq!(
        RequestValidationError::UnsupportedCommand.message(),
        "unsupported command"
    );
    assert_eq!(
        CommandFailure::validation_failed("bad request").http_status(),
        "400 Bad Request"
    );
}
