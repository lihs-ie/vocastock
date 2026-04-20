use command_api::{normalize_text, parse_register_command, RequestValidationError};

use crate::support::{active_actor, register_command_json};

#[test]
fn normalize_text_trims_lowercases_and_collapses_whitespace() {
    assert_eq!(
        normalize_text("  Mixed \n  CASE\tvalue  ").as_deref(),
        Some("mixed case value")
    );
}

#[test]
fn normalize_text_rejects_blank_and_control_characters() {
    assert_eq!(normalize_text("   "), None);
    assert_eq!(normalize_text("bad\u{0007}value"), None);
}

#[test]
fn parse_register_command_defaults_start_explanation_to_true() {
    let actor = active_actor();
    let payload = register_command_json("actor:learner", "req-001", "  Fresh   Term  ", None);

    let command = parse_register_command(&payload, &actor).expect("request should parse");

    assert_eq!(command.actor.actor().as_str(), "actor:learner");
    assert_eq!(command.idempotency_key, "req-001");
    assert_eq!(command.normalized_text, "fresh term");
    assert!(command.start_explanation);
}

#[test]
fn parse_register_command_allows_false_start_explanation() {
    let actor = active_actor();
    let payload = register_command_json("actor:learner", "req-002", "Coffee", Some(false));

    let command = parse_register_command(&payload, &actor).expect("request should parse");

    assert_eq!(command.normalized_text, "coffee");
    assert!(!command.start_explanation);
}

#[test]
fn parse_register_command_rejects_invalid_shapes() {
    let actor = active_actor();
    let cases = vec![
        ("not-json".to_owned(), RequestValidationError::InvalidJson),
        (
            serde_json::json!({
                "command": "unknownCommand",
                "actor": "actor:learner",
                "idempotencyKey": "req",
                "body": { "text": "coffee" }
            })
            .to_string(),
            RequestValidationError::UnsupportedCommand,
        ),
        (
            serde_json::json!({
                "command": "registerVocabularyExpression",
                "actor": " ",
                "idempotencyKey": "req",
                "body": { "text": "coffee" }
            })
            .to_string(),
            RequestValidationError::MissingActor,
        ),
        (
            serde_json::json!({
                "command": "registerVocabularyExpression",
                "actor": "actor:other",
                "idempotencyKey": "req",
                "body": { "text": "coffee" }
            })
            .to_string(),
            RequestValidationError::OwnershipMismatch,
        ),
        (
            serde_json::json!({
                "command": "registerVocabularyExpression",
                "actor": "actor:learner",
                "idempotencyKey": " ",
                "body": { "text": "coffee" }
            })
            .to_string(),
            RequestValidationError::MissingIdempotencyKey,
        ),
        (
            serde_json::json!({
                "command": "registerVocabularyExpression",
                "actor": "actor:learner",
                "idempotencyKey": "req",
                "body": { "text": " " }
            })
            .to_string(),
            RequestValidationError::MissingText,
        ),
        (
            serde_json::json!({
                "command": "registerVocabularyExpression",
                "actor": "actor:learner",
                "idempotencyKey": "req",
                "body": { "text": "bad\u{0001}value" }
            })
            .to_string(),
            RequestValidationError::InvalidText,
        ),
    ];

    for (payload, expected) in cases {
        let error = parse_register_command(&payload, &actor).expect_err("request must fail");
        assert_eq!(error, expected);
    }
}

#[test]
fn validation_errors_expose_stable_codes_and_messages() {
    let cases = [
        (
            RequestValidationError::InvalidJson,
            "validation-failed",
            "request body must be valid JSON",
        ),
        (
            RequestValidationError::UnsupportedCommand,
            "validation-failed",
            "unsupported command",
        ),
        (
            RequestValidationError::MissingActor,
            "validation-failed",
            "actor handoff is required",
        ),
        (
            RequestValidationError::OwnershipMismatch,
            "ownership-mismatch",
            "actor handoff does not match bearer token",
        ),
        (
            RequestValidationError::MissingIdempotencyKey,
            "validation-failed",
            "idempotencyKey is required",
        ),
        (
            RequestValidationError::MissingText,
            "validation-failed",
            "body.text is required",
        ),
        (
            RequestValidationError::InvalidText,
            "validation-failed",
            "body.text contains invalid characters",
        ),
    ];

    for (error, expected_code, expected_message) in cases {
        assert_eq!(error.code(), expected_code);
        assert_eq!(error.message(), expected_message);
    }
}
