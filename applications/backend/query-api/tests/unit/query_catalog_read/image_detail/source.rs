use query_api::ImageDetailRecord;

#[test]
fn image_detail_record_preserves_nullable_sense_fields() {
    let record = ImageDetailRecord {
        identifier: "stub-img".to_owned(),
        explanation: "stub-exp".to_owned(),
        asset_reference: "gs://bucket/x.png".to_owned(),
        description: "-".to_owned(),
        sense_identifier: None,
        sense_label: None,
    };
    assert!(record.sense_identifier.is_none());
    assert!(record.sense_label.is_none());
    assert_eq!(record.identifier, "stub-img");
}
