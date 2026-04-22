use command_api::parse_mutation_idempotency_document;
use serde_json::json;

#[test]
fn parses_full_document() {
    let payload = json!({
        "fields": {
            "commandName": {"stringValue": "requestExplanationGeneration"},
            "payloadHash": {"stringValue": "vocab=vocabulary:run"},
            "responseJson": {"stringValue": "{\"accepted\":true,\"outcome\":\"ACCEPTED\",\"message\":{\"key\":\"k\",\"text\":\"t\"}}"},
        }
    });
    let document = parse_mutation_idempotency_document(&payload).expect("valid doc");
    assert_eq!(document.command_name, "requestExplanationGeneration");
    assert_eq!(document.payload_hash, "vocab=vocabulary:run");
    let envelope = document.decode_envelope().expect("decodable");
    assert!(envelope.accepted);
}

#[test]
fn rejects_missing_fields() {
    let payload = json!({"fields": {}});
    assert!(parse_mutation_idempotency_document(&payload).is_none());
}
