use query_api::VocabularyExpressionDetailRecord;

#[test]
fn record_is_a_plain_data_struct_with_public_fields() {
    let record = VocabularyExpressionDetailRecord {
        identifier: "stub-vocab-0000".to_owned(),
        text: "run".to_owned(),
        registration_status: "active".to_owned(),
        explanation_status: "succeeded".to_owned(),
        image_status: "succeeded".to_owned(),
        current_explanation: Some("stub-exp-for-stub-vocab-0000".to_owned()),
        current_image: Some("stub-img-for-stub-vocab-0000".to_owned()),
        registered_at: "2026-04-05T10:00:00.000Z".to_owned(),
    };

    let cloned = record.clone();
    assert_eq!(record, cloned);
    assert_eq!(record.registered_at, "2026-04-05T10:00:00.000Z");
    assert!(record.current_explanation.is_some());
    assert!(record.current_image.is_some());
}
