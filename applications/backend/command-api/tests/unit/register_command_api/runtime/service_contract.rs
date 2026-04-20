use command_api::{
    status_handle_for, vocabulary_expression_for, EXPLANATION_STATE_FAILED_FINAL,
    EXPLANATION_STATE_NOT_STARTED, EXPLANATION_STATE_QUEUED, REGISTERED_STATE,
    REGISTER_VOCABULARY_EXPRESSION_PATH, ROOT_MESSAGE, SERVICE_NAME, STATUS_HANDLE_PREFIX,
};

#[test]
fn service_contract_constants_match_expected_values() {
    assert_eq!(SERVICE_NAME, "command-api");
    assert_eq!(
        REGISTER_VOCABULARY_EXPRESSION_PATH,
        "/commands/register-vocabulary-expression"
    );
    assert_eq!(STATUS_HANDLE_PREFIX, "status");
    assert_eq!(REGISTERED_STATE, "registered");
    assert_eq!(EXPLANATION_STATE_QUEUED, "queued");
    assert_eq!(EXPLANATION_STATE_NOT_STARTED, "not-started");
    assert_eq!(EXPLANATION_STATE_FAILED_FINAL, "failed-final");
    assert!(ROOT_MESSAGE.contains("without completed payloads"));
}

#[test]
fn service_contract_helpers_format_target_and_status_handle() {
    assert_eq!(
        vocabulary_expression_for("mixed case"),
        "vocabulary:mixed-case"
    );
    assert_eq!(
        status_handle_for("actor:learner", "vocabulary:mixed-case"),
        "status:actor:learner:vocabulary:mixed-case"
    );
}
