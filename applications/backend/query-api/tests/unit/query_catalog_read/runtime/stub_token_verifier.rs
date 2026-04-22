use crate::support::StubTokenVerifier;
use shared_auth::TokenVerificationPort;

#[test]
fn stub_verifier_resolves_known_tokens() {
    let verifier = StubTokenVerifier;

    let learner = verifier
        .verify("valid-learner-token")
        .expect("learner token should resolve");
    let empty = verifier
        .verify("valid-empty-token")
        .expect("empty token should resolve");
    let other = verifier
        .verify("valid-other-token")
        .expect("other token should resolve");

    assert_eq!(learner.actor().as_str(), "actor:learner");
    assert_eq!(empty.actor().as_str(), "actor:empty");
    assert_eq!(other.actor().as_str(), "actor:other");
}

#[test]
fn stub_verifier_rejects_invalid_inputs() {
    let verifier = StubTokenVerifier;

    assert_eq!(
        verifier.verify("").expect_err("empty token must fail"),
        shared_auth::TokenVerificationError::MissingToken
    );
    assert_eq!(
        verifier
            .verify("reauth-token")
            .expect_err("reauth token must fail"),
        shared_auth::TokenVerificationError::ReauthRequired
    );
    assert_eq!(
        verifier
            .verify("invalid-token")
            .expect_err("invalid token must fail"),
        shared_auth::TokenVerificationError::InvalidToken
    );
}
