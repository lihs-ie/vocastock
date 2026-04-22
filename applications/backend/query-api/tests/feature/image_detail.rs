use crate::support::{assert_contains, FeatureRuntime};

#[test]
fn image_detail_reads_seeded_record_with_sense_metadata() {
    let runtime = FeatureRuntime::start_with_production_adapters();
    let demo_bearer = runtime.demo_bearer();

    let populated = runtime.get(
        "/image-detail?identifier=stub-img-for-stub-vocab-0000",
        Some(demo_bearer.as_str()),
    );
    assert_eq!(populated.status, 200);
    assert_contains(
        &populated.body,
        "\"identifier\":\"stub-img-for-stub-vocab-0000\"",
        "populated image detail",
    );
    assert_contains(
        &populated.body,
        "\"explanation\":\"stub-exp-for-stub-vocab-0000\"",
        "populated image detail",
    );
    assert_contains(
        &populated.body,
        "\"assetReference\":\"actors/stub-actor-demo/images/stub-img-for-stub-vocab-0000.png\"",
        "asset reference is parsed verbatim from Firestore",
    );
    assert_contains(
        &populated.body,
        "\"senseIdentifier\":\"s1\"",
        "senseIdentifier is present",
    );
    assert_contains(
        &populated.body,
        "\"senseLabel\":\"走る\"",
        "senseLabel is present",
    );

    let missing_record = runtime.get(
        "/image-detail?identifier=stub-img-missing",
        Some(demo_bearer.as_str()),
    );
    assert_eq!(missing_record.status, 200);
    assert_eq!(missing_record.body.trim(), "null");

    let missing_identifier = runtime.get("/image-detail", Some(demo_bearer.as_str()));
    assert_eq!(missing_identifier.status, 400);

    let missing_token = runtime.get(
        "/image-detail?identifier=stub-img-for-stub-vocab-0000",
        None,
    );
    assert_eq!(missing_token.status, 401);
}
