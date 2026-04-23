use crate::support::{assert_contains, FeatureRuntime};

#[test]
fn learning_state_reads_seeded_proficiency_from_firestore_emulator() {
    let runtime = FeatureRuntime::start_with_production_adapters();
    let demo_bearer = runtime.demo_bearer();

    let populated = runtime.get(
        "/learning-state?identifier=stub-vocab-0000",
        Some(demo_bearer.as_str()),
    );
    assert_eq!(populated.status, 200);
    assert_contains(
        &populated.body,
        "\"vocabularyExpression\":\"stub-vocab-0000\"",
        "populated learning state",
    );
    assert_contains(
        &populated.body,
        "\"proficiency\":\"LEARNED\"",
        "proficiency is SCREAMING_SNAKE_CASE",
    );

    let missing_record = runtime.get(
        "/learning-state?identifier=stub-vocab-does-not-exist",
        Some(demo_bearer.as_str()),
    );
    assert_eq!(missing_record.status, 200);
    assert_eq!(missing_record.body.trim(), "null");

    let missing_identifier = runtime.get("/learning-state", Some(demo_bearer.as_str()));
    assert_eq!(missing_identifier.status, 400);
    assert_contains(
        &missing_identifier.body,
        "identifier is required",
        "400 body signals a malformed call",
    );

    let missing_token = runtime.get("/learning-state?identifier=stub-vocab-0000", None);
    assert_eq!(missing_token.status, 401);

    // --- batch endpoint (/learning-states, no identifier) ---
    let list = runtime.get("/learning-states", Some(demo_bearer.as_str()));
    assert_eq!(list.status, 200);
    assert_contains(
        &list.body,
        "\"proficiency\":\"LEARNED\"",
        "batch list includes LEARNED entry",
    );
    assert_contains(
        &list.body,
        "\"proficiency\":\"LEARNING\"",
        "batch list includes LEARNING entry",
    );

    let list_missing_token = runtime.get("/learning-states", None);
    assert_eq!(list_missing_token.status, 401);
}
