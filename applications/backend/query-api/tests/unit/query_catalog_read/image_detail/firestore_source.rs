use query_api::image_detail::parse_image_document;
use serde_json::json;

#[test]
fn parses_fully_populated_image_document() {
    let payload = json!({
        "name": "projects/demo-vocastock/databases/(default)/documents/actors/stub-actor-demo/images/stub-img-for-stub-vocab-0000",
        "fields": {
            "id": {"stringValue": "stub-img-for-stub-vocab-0000"},
            "explanation": {"stringValue": "stub-exp-for-stub-vocab-0000"},
            "assetReference": {"stringValue": "actors/stub-actor-demo/images/stub-img-for-stub-vocab-0000.png"},
            "description": {"stringValue": "「run」を視覚化したイラスト"},
            "senseIdentifier": {"stringValue": "s1"},
            "senseLabel": {"stringValue": "走る"},
            "previousImage": {"stringValue": "stub-img-prior"}
        }
    });

    let record = parse_image_document(&payload).expect("document parses");
    assert_eq!(record.identifier, "stub-img-for-stub-vocab-0000");
    assert_eq!(record.explanation, "stub-exp-for-stub-vocab-0000");
    assert_eq!(
        record.asset_reference,
        "actors/stub-actor-demo/images/stub-img-for-stub-vocab-0000.png"
    );
    assert_eq!(record.sense_identifier.as_deref(), Some("s1"));
    assert_eq!(record.sense_label.as_deref(), Some("走る"));
    assert_eq!(record.previous_image.as_deref(), Some("stub-img-prior"));
}

#[test]
fn parses_document_with_null_sense_fields() {
    let payload = json!({
        "fields": {
            "id": {"stringValue": "stub-img"},
            "explanation": {"stringValue": "stub-exp"},
            "assetReference": {"stringValue": "gs://bucket/x.png"},
            "description": {"stringValue": "-"},
            "senseIdentifier": {"nullValue": null},
            "senseLabel": {"nullValue": null}
        }
    });

    let record = parse_image_document(&payload).expect("document parses");
    assert!(record.sense_identifier.is_none());
    assert!(record.sense_label.is_none());
    assert!(record.previous_image.is_none());
}

#[test]
fn parses_document_with_explicit_null_previous_image() {
    let payload = json!({
        "fields": {
            "id": {"stringValue": "stub-img"},
            "explanation": {"stringValue": "stub-exp"},
            "assetReference": {"stringValue": "gs://bucket/x.png"},
            "description": {"stringValue": "-"},
            "previousImage": {"nullValue": null}
        }
    });

    let record = parse_image_document(&payload).expect("document parses");
    assert!(record.previous_image.is_none());
}

#[test]
fn returns_none_for_document_without_fields() {
    assert!(parse_image_document(&json!({})).is_none());
}
