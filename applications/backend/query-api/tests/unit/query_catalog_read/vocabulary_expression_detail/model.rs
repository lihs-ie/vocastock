use query_api::{GenerationStatus, RegistrationStatus, VocabularyExpressionEntryView};

#[test]
fn registration_status_parse_covers_all_supported_variants() {
    assert_eq!(
        RegistrationStatus::parse("active"),
        RegistrationStatus::Active
    );
    assert_eq!(
        RegistrationStatus::parse("archived"),
        RegistrationStatus::Archived
    );
    assert_eq!(
        RegistrationStatus::parse("unknown"),
        RegistrationStatus::Active,
        "unknown values fall back to Active so catalog entries remain visible"
    );
}

#[test]
fn generation_status_parse_maps_firestore_casings() {
    assert_eq!(
        GenerationStatus::parse("pending"),
        GenerationStatus::Pending
    );
    assert_eq!(
        GenerationStatus::parse("running"),
        GenerationStatus::Running
    );
    assert_eq!(
        GenerationStatus::parse("retryScheduled"),
        GenerationStatus::RetryScheduled
    );
    assert_eq!(
        GenerationStatus::parse("timedOut"),
        GenerationStatus::TimedOut
    );
    assert_eq!(
        GenerationStatus::parse("succeeded"),
        GenerationStatus::Succeeded
    );
    assert_eq!(
        GenerationStatus::parse("failedFinal"),
        GenerationStatus::FailedFinal
    );
    assert_eq!(
        GenerationStatus::parse("deadLettered"),
        GenerationStatus::DeadLettered
    );
    assert_eq!(
        GenerationStatus::parse("bogus"),
        GenerationStatus::Pending,
        "unknown values fall back to Pending so the UI treats them as in-progress"
    );
}

#[test]
fn view_serializes_with_graphql_enum_strings_and_camel_case_keys() {
    let view = VocabularyExpressionEntryView {
        identifier: "stub-vocab-0000".to_owned(),
        text: "run".to_owned(),
        registration_status: RegistrationStatus::Active,
        explanation_status: GenerationStatus::Succeeded,
        image_status: GenerationStatus::RetryScheduled,
        current_explanation: Some("stub-exp-for-stub-vocab-0000".to_owned()),
        current_image: None,
        registered_at: "2026-04-05T10:00:00.000Z".to_owned(),
    };
    let serialized = serde_json::to_string(&view).expect("view should serialize");

    assert!(serialized.contains("\"identifier\":\"stub-vocab-0000\""));
    assert!(serialized.contains("\"text\":\"run\""));
    assert!(serialized.contains("\"registrationStatus\":\"ACTIVE\""));
    assert!(serialized.contains("\"explanationStatus\":\"SUCCEEDED\""));
    assert!(serialized.contains("\"imageStatus\":\"RETRY_SCHEDULED\""));
    assert!(serialized.contains("\"currentExplanation\":\"stub-exp-for-stub-vocab-0000\""));
    assert!(serialized.contains("\"registeredAt\":\"2026-04-05T10:00:00.000Z\""));
    assert!(
        !serialized.contains("\"currentImage\""),
        "None-valued currentImage must be skipped on serialization"
    );
}
