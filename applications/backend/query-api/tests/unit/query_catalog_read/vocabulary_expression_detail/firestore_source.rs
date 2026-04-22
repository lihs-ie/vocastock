use query_api::vocabulary_expression_detail::parse_vocabulary_expression_document;
use serde_json::json;

#[test]
fn parses_fully_populated_document() {
    let payload = json!({
        "name": "projects/demo-vocastock/databases/(default)/documents/actors/stub-actor-demo/vocabularyExpressions/stub-vocab-0000",
        "fields": {
            "id": {"stringValue": "stub-vocab-0000"},
            "text": {"stringValue": "run"},
            "registrationStatus": {"stringValue": "active"},
            "explanationStatus": {"stringValue": "succeeded"},
            "imageStatus": {"stringValue": "succeeded"},
            "currentExplanation": {"stringValue": "stub-exp-for-stub-vocab-0000"},
            "currentImage": {"stringValue": "stub-img-for-stub-vocab-0000"},
            "registeredAt": {"stringValue": "2026-04-05T10:00:00.000Z"}
        }
    });

    let record =
        parse_vocabulary_expression_document(&payload).expect("well-formed document should parse");

    assert_eq!(record.identifier, "stub-vocab-0000");
    assert_eq!(record.text, "run");
    assert_eq!(record.registration_status, "active");
    assert_eq!(record.explanation_status, "succeeded");
    assert_eq!(record.image_status, "succeeded");
    assert_eq!(
        record.current_explanation.as_deref(),
        Some("stub-exp-for-stub-vocab-0000")
    );
    assert_eq!(
        record.current_image.as_deref(),
        Some("stub-img-for-stub-vocab-0000")
    );
    assert_eq!(record.registered_at, "2026-04-05T10:00:00.000Z");
}

#[test]
fn parses_document_with_null_nested_fields() {
    let payload = json!({
        "fields": {
            "id": {"stringValue": "stub-vocab-0002"},
            "text": {"stringValue": "ubiquitous"},
            "registrationStatus": {"stringValue": "active"},
            "explanationStatus": {"stringValue": "pending"},
            "imageStatus": {"stringValue": "pending"},
            "currentExplanation": {"nullValue": null},
            "currentImage": {"nullValue": null},
            "registeredAt": {"stringValue": "2026-04-18T08:15:00.000Z"}
        }
    });

    let record = parse_vocabulary_expression_document(&payload)
        .expect("document with explicit nulls should parse");

    assert!(record.current_explanation.is_none());
    assert!(record.current_image.is_none());
}

#[test]
fn returns_none_for_document_without_fields_envelope() {
    let payload = json!({
        "error": {
            "code": 404,
            "message": "Document not found",
            "status": "NOT_FOUND"
        }
    });

    assert!(
        parse_vocabulary_expression_document(&payload).is_none(),
        "a 404 response body should not be mistaken for a record"
    );
}

#[test]
fn returns_none_when_required_fields_are_missing() {
    let payload = json!({
        "fields": {
            "text": {"stringValue": "run"}
        }
    });

    assert!(
        parse_vocabulary_expression_document(&payload).is_none(),
        "missing the id field should disqualify the record"
    );
}
