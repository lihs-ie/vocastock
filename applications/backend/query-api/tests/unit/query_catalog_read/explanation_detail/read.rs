use query_api::{
    read_explanation_detail, read_explanation_detail_from_authorization_header,
    ExplanationDetailError, FrequencyLevel, SophisticationLevel,
};

use crate::support::{
    active_actor, reauth_actor, sample_explanation_record, ExplanationDetailTestSource,
    StubTokenVerifier,
};

#[test]
fn returns_mapped_view_when_record_is_present() {
    let source =
        ExplanationDetailTestSource::with_record("actor:learner", sample_explanation_record());
    let view = read_explanation_detail(&active_actor(), "stub-exp-for-stub-vocab-0000", &source)
        .expect("record resolves without auth error")
        .expect("record is mapped");

    assert_eq!(view.frequency, FrequencyLevel::Often);
    assert_eq!(view.sophistication, SophisticationLevel::VeryBasic);
    assert_eq!(view.senses.len(), 1);
    assert_eq!(view.senses[0].label, "走る");
    assert_eq!(view.similarities.len(), 1);
}

#[test]
fn returns_ok_none_when_record_is_missing() {
    let source = ExplanationDetailTestSource::empty();
    let view = read_explanation_detail(&active_actor(), "stub-exp-missing", &source)
        .expect("missing record is not an error");
    assert!(view.is_none());
}

#[test]
fn rejects_inactive_session() {
    let source =
        ExplanationDetailTestSource::with_record("actor:learner", sample_explanation_record());
    let error = read_explanation_detail(&reauth_actor(), "stub-exp-for-stub-vocab-0000", &source)
        .expect_err("reauth-required should be rejected");
    assert_eq!(error, ExplanationDetailError::InactiveSession);
}

#[test]
fn rejects_missing_identifier() {
    let source = ExplanationDetailTestSource::empty();
    let error = read_explanation_detail(&active_actor(), "   ", &source)
        .expect_err("whitespace identifier is treated as missing");
    assert_eq!(error, ExplanationDetailError::MissingIdentifier);
}

#[test]
fn authorization_header_variant_resolves_successfully() {
    let verifier = StubTokenVerifier;
    let source =
        ExplanationDetailTestSource::with_record("actor:learner", sample_explanation_record());
    let view = read_explanation_detail_from_authorization_header(
        Some("Bearer valid-learner-token"),
        "stub-exp-for-stub-vocab-0000",
        &verifier,
        &source,
    )
    .expect("authorized call")
    .expect("record resolves to Some");
    assert_eq!(view.identifier, "stub-exp-for-stub-vocab-0000");
}
