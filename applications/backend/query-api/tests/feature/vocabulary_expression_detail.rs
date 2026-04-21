use crate::support::{assert_contains, FeatureRuntime};

#[test]
fn vocabulary_expression_detail_reads_seeded_record_from_firestore_emulator() {
    let runtime = FeatureRuntime::start_with_production_adapters();

    let populated = runtime.get(
        "/vocabulary-expression-detail?identifier=stub-vocab-0000",
        Some("Bearer valid-demo-token"),
    );
    assert_eq!(populated.status, 200);
    assert_contains(
        &populated.body,
        "\"identifier\":\"stub-vocab-0000\"",
        "populated detail response",
    );
    assert_contains(
        &populated.body,
        "\"text\":\"run\"",
        "populated detail response",
    );
    assert_contains(
        &populated.body,
        "\"registrationStatus\":\"ACTIVE\"",
        "populated detail response",
    );
    assert_contains(
        &populated.body,
        "\"explanationStatus\":\"SUCCEEDED\"",
        "populated detail response",
    );
    assert_contains(
        &populated.body,
        "\"currentExplanation\":\"stub-exp-for-stub-vocab-0000\"",
        "populated detail response",
    );

    let missing_record = runtime.get(
        "/vocabulary-expression-detail?identifier=stub-vocab-does-not-exist",
        Some("Bearer valid-demo-token"),
    );
    assert_eq!(missing_record.status, 200);
    assert_eq!(
        missing_record.body.trim(),
        "null",
        "non-existent identifier yields JSON null so GraphQL nullable fields stay consistent"
    );

    let missing_identifier = runtime.get(
        "/vocabulary-expression-detail",
        Some("Bearer valid-demo-token"),
    );
    assert_eq!(missing_identifier.status, 400);
    assert_contains(
        &missing_identifier.body,
        "identifier is required",
        "400 body signals a malformed call",
    );

    let missing_token = runtime.get(
        "/vocabulary-expression-detail?identifier=stub-vocab-0000",
        None,
    );
    assert_eq!(missing_token.status, 401);

    let method_not_allowed = runtime.post("/vocabulary-expression-detail", None);
    assert_eq!(method_not_allowed.status, 405);
}
