use crate::support::{
    active_actor, reauth_actor, sample_learning_state_record, LearningStateTestSource,
    StubTokenVerifier,
};
use query_api::{read_learning_state, LearningStateError, ProficiencyLevel};

#[test]
fn returns_mapped_view_when_record_is_present() {
    let source =
        LearningStateTestSource::with_record("actor:learner", sample_learning_state_record());
    let result = read_learning_state(&active_actor(), "stub-vocab-0000", &source);
    let view = result.expect("should succeed").expect("should be Some");
    assert_eq!(view.vocabulary_expression, "stub-vocab-0000");
    assert_eq!(view.proficiency, ProficiencyLevel::Learned);
    assert_eq!(view.created_at, "2026-04-05T10:00:00.000Z");
}

#[test]
fn returns_ok_none_when_record_is_missing() {
    let source = LearningStateTestSource::empty();
    let result = read_learning_state(&active_actor(), "stub-vocab-missing", &source);
    assert_eq!(result, Ok(None));
}

#[test]
fn returns_ok_none_when_proficiency_is_unrecognised() {
    let mut record = sample_learning_state_record();
    record.proficiency = "invalid-level".to_owned();
    let source = LearningStateTestSource::with_record("actor:learner", record);
    let result = read_learning_state(&active_actor(), "stub-vocab-0000", &source);
    assert_eq!(result, Ok(None));
}

#[test]
fn rejects_inactive_session() {
    let source = LearningStateTestSource::empty();
    let result = read_learning_state(&reauth_actor(), "stub-vocab-0000", &source);
    assert_eq!(result, Err(LearningStateError::ReauthRequired));
}

#[test]
fn authorization_header_variant_resolves_successfully() {
    use query_api::read_learning_state_from_authorization_header;
    let verifier = StubTokenVerifier;
    let source =
        LearningStateTestSource::with_record("actor:learner", sample_learning_state_record());
    let result = read_learning_state_from_authorization_header(
        Some("Bearer valid-learner-token"),
        Some("stub-vocab-0000"),
        &verifier,
        &source,
    );
    assert!(result.is_ok());
    assert!(result.unwrap().is_some());
}

#[test]
fn missing_authorization_header_is_rejected() {
    use query_api::read_learning_state_from_authorization_header;
    let verifier = StubTokenVerifier;
    let source = LearningStateTestSource::empty();
    let result =
        read_learning_state_from_authorization_header(None, Some("vocab"), &verifier, &source);
    assert_eq!(result, Err(LearningStateError::MissingToken));
}

#[test]
fn rejects_missing_identifier() {
    use query_api::read_learning_state_from_authorization_header;
    let verifier = StubTokenVerifier;
    let source = LearningStateTestSource::empty();
    let result = read_learning_state_from_authorization_header(
        Some("Bearer valid-learner-token"),
        None,
        &verifier,
        &source,
    );
    assert_eq!(result, Err(LearningStateError::MissingIdentifier));
}
