use crate::support::{assert_contains, FeatureRuntime};

#[test]
fn explanation_detail_reads_nested_firestore_document() {
    let runtime = FeatureRuntime::start_with_production_adapters();

    let populated = runtime.get(
        "/explanation-detail?identifier=stub-exp-for-stub-vocab-0000",
        Some("Bearer valid-demo-token"),
    );
    assert_eq!(populated.status, 200);
    assert_contains(
        &populated.body,
        "\"identifier\":\"stub-exp-for-stub-vocab-0000\"",
        "populated explanation detail",
    );
    assert_contains(
        &populated.body,
        "\"vocabularyExpression\":\"stub-vocab-0000\"",
        "populated explanation detail",
    );
    assert_contains(
        &populated.body,
        "\"pronunciation\":{\"weak\":\"/run/\",\"strong\":\"/RUN/\"}",
        "pronunciation map is parsed and re-serialized",
    );
    assert_contains(
        &populated.body,
        "\"frequency\":\"OFTEN\"",
        "frequency enum is serialized in SCREAMING_SNAKE_CASE",
    );
    assert_contains(
        &populated.body,
        "\"sophistication\":\"VERY_BASIC\"",
        "sophistication enum is serialized in SCREAMING_SNAKE_CASE",
    );
    assert_contains(
        &populated.body,
        "\"label\":\"走る\"",
        "senses labels are preserved through Firestore parse round-trip",
    );
    assert_contains(
        &populated.body,
        "I run every morning before work.",
        "nested examples survive Firestore array parsing",
    );

    let missing_record = runtime.get(
        "/explanation-detail?identifier=stub-exp-missing",
        Some("Bearer valid-demo-token"),
    );
    assert_eq!(missing_record.status, 200);
    assert_eq!(missing_record.body.trim(), "null");

    let missing_identifier = runtime.get("/explanation-detail", Some("Bearer valid-demo-token"));
    assert_eq!(missing_identifier.status, 400);

    let missing_token = runtime.get(
        "/explanation-detail?identifier=stub-exp-for-stub-vocab-0000",
        None,
    );
    assert_eq!(missing_token.status, 401);
}
