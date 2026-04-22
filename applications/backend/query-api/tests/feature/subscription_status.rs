use crate::support::{assert_contains, FeatureRuntime};

#[test]
fn subscription_status_reflects_seeded_plans_per_actor() {
    let runtime = FeatureRuntime::start_with_production_adapters();

    let demo = runtime.get("/subscription-status", Some("Bearer valid-demo-token"));
    assert_eq!(demo.status, 200);
    assert_contains(
        &demo.body,
        "\"state\":\"ACTIVE\"",
        "demo actor has an active subscription",
    );
    assert_contains(
        &demo.body,
        "\"plan\":\"STANDARD_MONTHLY\"",
        "demo actor is on the standardMonthly plan",
    );
    assert_contains(
        &demo.body,
        "\"entitlement\":\"PREMIUM_GENERATION\"",
        "demo actor holds premium entitlement",
    );
    assert_contains(
        &demo.body,
        "\"remainingExplanationGenerations\":82",
        "allowance counters round-trip through integerValue parsing",
    );
    assert_contains(
        &demo.body,
        "\"remainingImageGenerations\":27",
        "allowance counters round-trip through integerValue parsing",
    );

    let free = runtime.get("/subscription-status", Some("Bearer valid-free-token"));
    assert_eq!(free.status, 200);
    assert_contains(
        &free.body,
        "\"plan\":\"FREE\"",
        "free actor is on the free plan",
    );
    assert_contains(
        &free.body,
        "\"entitlement\":\"FREE_BASIC\"",
        "free actor has the basic entitlement",
    );
    assert_contains(
        &free.body,
        "\"remainingExplanationGenerations\":7",
        "free allowance is read as seeded",
    );

    let missing_token = runtime.get("/subscription-status", None);
    assert_eq!(missing_token.status, 401);
}
