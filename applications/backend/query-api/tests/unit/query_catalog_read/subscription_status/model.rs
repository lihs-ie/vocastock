use query_api::{
    EntitlementBundle, PlanCode, SubscriptionState, SubscriptionStatusView, UsageAllowanceView,
};

#[test]
fn state_plan_entitlement_parse_covers_expected_variants() {
    assert_eq!(
        SubscriptionState::parse("active"),
        SubscriptionState::Active
    );
    assert_eq!(SubscriptionState::parse("grace"), SubscriptionState::Grace);
    assert_eq!(
        SubscriptionState::parse("pendingSync"),
        SubscriptionState::PendingSync
    );
    assert_eq!(
        SubscriptionState::parse("expired"),
        SubscriptionState::Expired
    );
    assert_eq!(
        SubscriptionState::parse("revoked"),
        SubscriptionState::Revoked
    );
    assert_eq!(
        SubscriptionState::parse("unknown"),
        SubscriptionState::PendingSync,
        "unknown states default to PendingSync so feature gating stays conservative"
    );

    assert_eq!(PlanCode::parse("free"), PlanCode::Free);
    assert_eq!(
        PlanCode::parse("standardMonthly"),
        PlanCode::StandardMonthly
    );
    assert_eq!(PlanCode::parse("proMonthly"), PlanCode::ProMonthly);
    assert_eq!(PlanCode::parse("unknown"), PlanCode::Free);

    assert_eq!(
        EntitlementBundle::parse("freeBasic"),
        EntitlementBundle::FreeBasic
    );
    assert_eq!(
        EntitlementBundle::parse("premiumGeneration"),
        EntitlementBundle::PremiumGeneration
    );
}

#[test]
fn view_serializes_with_graphql_enum_strings() {
    let view = SubscriptionStatusView {
        state: SubscriptionState::Active,
        plan: PlanCode::StandardMonthly,
        entitlement: EntitlementBundle::PremiumGeneration,
        allowance: UsageAllowanceView {
            remaining_explanation_generations: 82,
            remaining_image_generations: 27,
        },
    };
    let serialized = serde_json::to_string(&view).expect("serializes");
    assert!(serialized.contains("\"state\":\"ACTIVE\""));
    assert!(serialized.contains("\"plan\":\"STANDARD_MONTHLY\""));
    assert!(serialized.contains("\"entitlement\":\"PREMIUM_GENERATION\""));
    assert!(serialized.contains(
        "\"allowance\":{\"remainingExplanationGenerations\":82,\"remainingImageGenerations\":27}"
    ));
}

#[test]
fn pending_sync_default_serializes_as_non_entitled() {
    let view = SubscriptionStatusView::pending_sync_default();
    assert_eq!(view.state, SubscriptionState::PendingSync);
    assert_eq!(view.plan, PlanCode::Free);
    assert_eq!(view.entitlement, EntitlementBundle::FreeBasic);
    assert_eq!(view.allowance.remaining_explanation_generations, 0);
    assert_eq!(view.allowance.remaining_image_generations, 0);
}
