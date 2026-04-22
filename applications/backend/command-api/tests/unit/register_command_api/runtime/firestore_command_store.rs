use command_api::{parse_idempotency_document, parse_registration_document};
use serde_json::json;

#[test]
fn parse_registration_document_extracts_states() {
    let payload = json!({
        "fields": {
            "vocabularyExpression": {"stringValue": "vocabulary:run"},
            "registrationState": {"stringValue": "registered"},
            "explanationState": {"stringValue": "queued"},
        }
    });
    let record = parse_registration_document(&payload).expect("valid document");
    assert_eq!(record.vocabulary_expression, "vocabulary:run");
    assert_eq!(record.registration_state, "registered");
    assert_eq!(record.explanation_state, "queued");
}

#[test]
fn parse_registration_document_rejects_missing_fields() {
    assert!(parse_registration_document(&json!({})).is_none());
}

#[test]
fn parse_idempotency_document_extracts_fingerprint_and_response() {
    let payload = json!({
        "fields": {
            "commandName": {"stringValue": "registerVocabularyExpression"},
            "fingerprintHash": {"stringValue": "true|coffee"},
            "startExplanation": {"booleanValue": true},
            "responseJson": {"stringValue": "{\"acceptance\":\"accepted\",\"target\":{\"vocabularyExpression\":\"vocabulary:coffee\"},\"state\":{\"registration\":\"registered\",\"explanation\":\"queued\"},\"statusHandle\":\"status:actor:demo:vocabulary:coffee\",\"message\":\"accepted\",\"replayedByIdempotency\":false}"},
        }
    });
    let document = parse_idempotency_document(&payload).expect("valid document");
    assert!(document.matches_fingerprint("coffee", true));
    let decoded = document.decode_result().expect("decodable result");
    assert_eq!(decoded.acceptance, "accepted");
}

#[test]
fn idempotency_document_rejects_mismatched_fingerprint() {
    let payload = json!({
        "fields": {
            "commandName": {"stringValue": "registerVocabularyExpression"},
            "fingerprintHash": {"stringValue": "true|coffee"},
            "startExplanation": {"booleanValue": true},
            "responseJson": {"stringValue": "{}"},
        }
    });
    let document = parse_idempotency_document(&payload).unwrap();
    assert!(!document.matches_fingerprint("coffee", false));
    assert!(!document.matches_fingerprint("tea", true));
}
