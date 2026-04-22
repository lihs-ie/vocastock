use query_api::{
    read_subscription_status, read_subscription_status_from_authorization_header,
    EntitlementBundle, PlanCode, StubTokenVerifier, SubscriptionState, SubscriptionStatusError,
};

use crate::support::{
    active_actor, reauth_actor, sample_subscription_record, SubscriptionStatusTestSource,
};

#[test]
fn returns_mapped_view_when_record_is_present() {
    let source =
        SubscriptionStatusTestSource::with_record("actor:learner", sample_subscription_record());
    let view = read_subscription_status(&active_actor(), &source).expect("record resolves");
    assert_eq!(view.state, SubscriptionState::Active);
    assert_eq!(view.plan, PlanCode::StandardMonthly);
    assert_eq!(view.entitlement, EntitlementBundle::PremiumGeneration);
    assert_eq!(view.allowance.remaining_explanation_generations, 82);
    assert_eq!(view.allowance.remaining_image_generations, 27);
}

#[test]
fn synthesizes_pending_sync_default_when_record_is_missing() {
    let source = SubscriptionStatusTestSource::empty();
    let view = read_subscription_status(&active_actor(), &source).expect("synthetic default");
    assert_eq!(view.state, SubscriptionState::PendingSync);
    assert_eq!(view.plan, PlanCode::Free);
    assert_eq!(view.entitlement, EntitlementBundle::FreeBasic);
    assert_eq!(view.allowance.remaining_explanation_generations, 0);
    assert_eq!(view.allowance.remaining_image_generations, 0);
}

#[test]
fn rejects_inactive_session() {
    let source = SubscriptionStatusTestSource::empty();
    let error =
        read_subscription_status(&reauth_actor(), &source).expect_err("reauth-required rejected");
    assert_eq!(error, SubscriptionStatusError::InactiveSession);
}

#[test]
fn authorization_header_variant_resolves_successfully() {
    let verifier = StubTokenVerifier;
    let source =
        SubscriptionStatusTestSource::with_record("actor:learner", sample_subscription_record());
    let view = read_subscription_status_from_authorization_header(
        Some("Bearer valid-learner-token"),
        &verifier,
        &source,
    )
    .expect("authorized call");
    assert_eq!(view.plan, PlanCode::StandardMonthly);
}
