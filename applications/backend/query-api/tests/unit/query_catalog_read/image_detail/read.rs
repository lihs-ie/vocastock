use query_api::{read_image_detail, read_image_detail_from_authorization_header, ImageDetailError};

use crate::support::StubTokenVerifier;
use crate::support::{active_actor, reauth_actor, sample_image_record, ImageDetailTestSource};

#[test]
fn returns_mapped_view_when_record_is_present() {
    let source = ImageDetailTestSource::with_record("actor:learner", sample_image_record());
    let view = read_image_detail(&active_actor(), "stub-img-for-stub-vocab-0000", &source)
        .expect("record resolves")
        .expect("record is Some");
    assert_eq!(view.identifier, "stub-img-for-stub-vocab-0000");
    assert_eq!(view.sense_identifier.as_deref(), Some("s1"));
    assert_eq!(view.sense_label.as_deref(), Some("走る"));
}

#[test]
fn returns_ok_none_when_record_is_missing() {
    let source = ImageDetailTestSource::empty();
    let view = read_image_detail(&active_actor(), "stub-img-missing", &source)
        .expect("missing record is not an error");
    assert!(view.is_none());
}

#[test]
fn rejects_inactive_session() {
    let source = ImageDetailTestSource::with_record("actor:learner", sample_image_record());
    let error = read_image_detail(&reauth_actor(), "stub-img-for-stub-vocab-0000", &source)
        .expect_err("inactive session rejected");
    assert_eq!(error, ImageDetailError::InactiveSession);
}

#[test]
fn rejects_missing_identifier() {
    let source = ImageDetailTestSource::empty();
    let error =
        read_image_detail(&active_actor(), "", &source).expect_err("empty identifier rejected");
    assert_eq!(error, ImageDetailError::MissingIdentifier);
}

#[test]
fn authorization_header_variant_resolves_successfully() {
    let verifier = StubTokenVerifier;
    let source = ImageDetailTestSource::with_record("actor:learner", sample_image_record());
    let view = read_image_detail_from_authorization_header(
        Some("Bearer valid-learner-token"),
        "stub-img-for-stub-vocab-0000",
        &verifier,
        &source,
    )
    .expect("authorized call")
    .expect("record resolves");
    assert_eq!(view.identifier, "stub-img-for-stub-vocab-0000");
}
