use query_api::{
    read_vocabulary_expression_detail, read_vocabulary_expression_detail_from_authorization_header,
    GenerationStatus, RegistrationStatus, StubTokenVerifier, VocabularyExpressionDetailError,
};

use crate::support::{
    active_actor, reauth_actor, sample_vocabulary_expression_record,
    VocabularyExpressionDetailTestSource,
};

#[test]
fn returns_mapped_view_when_record_is_present() {
    let source = VocabularyExpressionDetailTestSource::with_record(
        "actor:learner",
        sample_vocabulary_expression_record(),
    );

    let view = read_vocabulary_expression_detail(&active_actor(), "stub-vocab-0000", &source)
        .expect("present record resolves to Ok(Some)")
        .expect("record is mapped to Some");

    assert_eq!(view.identifier, "stub-vocab-0000");
    assert_eq!(view.registration_status, RegistrationStatus::Active);
    assert_eq!(view.explanation_status, GenerationStatus::Succeeded);
    assert_eq!(view.image_status, GenerationStatus::Succeeded);
    assert_eq!(
        view.current_explanation.as_deref(),
        Some("stub-exp-for-stub-vocab-0000")
    );
    assert_eq!(
        source.calls(),
        vec![("actor:learner".to_owned(), "stub-vocab-0000".to_owned())]
    );
}

#[test]
fn returns_ok_none_when_record_is_missing() {
    let source = VocabularyExpressionDetailTestSource::empty();

    let view = read_vocabulary_expression_detail(&active_actor(), "stub-vocab-missing", &source)
        .expect("missing record is not an error");
    assert!(
        view.is_none(),
        "missing records should resolve to Ok(None), not an error"
    );
}

#[test]
fn rejects_inactive_session() {
    let source = VocabularyExpressionDetailTestSource::with_record(
        "actor:learner",
        sample_vocabulary_expression_record(),
    );
    let error = read_vocabulary_expression_detail(&reauth_actor(), "stub-vocab-0000", &source)
        .expect_err("reauth-required session should be rejected");

    assert_eq!(error, VocabularyExpressionDetailError::InactiveSession);
}

#[test]
fn rejects_missing_identifier() {
    let source = VocabularyExpressionDetailTestSource::empty();

    let error = read_vocabulary_expression_detail(&active_actor(), "", &source)
        .expect_err("empty identifier is a malformed call");

    assert_eq!(error, VocabularyExpressionDetailError::MissingIdentifier);
}

#[test]
fn authorization_header_variant_resolves_successfully() {
    let verifier = StubTokenVerifier;
    let source = VocabularyExpressionDetailTestSource::with_record(
        "actor:learner",
        sample_vocabulary_expression_record(),
    );

    let view = read_vocabulary_expression_detail_from_authorization_header(
        Some("Bearer valid-learner-token"),
        "stub-vocab-0000",
        &verifier,
        &source,
    )
    .expect("authorized call returns Ok")
    .expect("record resolves to Some");

    assert_eq!(view.identifier, "stub-vocab-0000");
}

#[test]
fn missing_authorization_header_is_rejected() {
    let verifier = StubTokenVerifier;
    let source = VocabularyExpressionDetailTestSource::empty();

    let error = read_vocabulary_expression_detail_from_authorization_header(
        None,
        "stub-vocab-0000",
        &verifier,
        &source,
    )
    .expect_err("missing header is an auth error");

    assert_eq!(
        error,
        VocabularyExpressionDetailError::Auth(shared_auth::TokenVerificationError::MissingToken)
    );
}
