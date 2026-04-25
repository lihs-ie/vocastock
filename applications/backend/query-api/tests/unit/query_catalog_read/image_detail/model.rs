use query_api::ImageDetailView;

#[test]
fn view_serializes_with_camel_case_and_optional_fields() {
    let view = ImageDetailView {
        identifier: "stub-img".to_owned(),
        explanation: "stub-exp".to_owned(),
        asset_reference: "actors/stub-actor-demo/images/stub-img.png".to_owned(),
        description: "走るランナー".to_owned(),
        sense_identifier: Some("s1".to_owned()),
        sense_label: Some("走る".to_owned()),
        previous_image: Some("stub-img-prior".to_owned()),
    };
    let serialized = serde_json::to_string(&view).expect("view serializes");

    assert!(serialized.contains("\"identifier\":\"stub-img\""));
    assert!(
        serialized.contains("\"assetReference\":\"actors/stub-actor-demo/images/stub-img.png\"")
    );
    assert!(serialized.contains("\"senseIdentifier\":\"s1\""));
    assert!(serialized.contains("\"senseLabel\":\"走る\""));
    assert!(serialized.contains("\"previousImage\":\"stub-img-prior\""));
}

#[test]
fn missing_sense_fields_are_skipped_on_serialization() {
    let view = ImageDetailView {
        identifier: "stub-img".to_owned(),
        explanation: "stub-exp".to_owned(),
        asset_reference: "gs://bucket/x.png".to_owned(),
        description: "-".to_owned(),
        sense_identifier: None,
        sense_label: None,
        previous_image: None,
    };
    let serialized = serde_json::to_string(&view).expect("view serializes");

    assert!(!serialized.contains("senseIdentifier"));
    assert!(!serialized.contains("senseLabel"));
    assert!(!serialized.contains("previousImage"));
}
