use query_api::{AllowanceRecord, SubscriptionRecord};

#[test]
fn subscription_record_carries_allowance_counters() {
    let record = SubscriptionRecord {
        state: "active".to_owned(),
        plan: "standardMonthly".to_owned(),
        entitlement: "premiumGeneration".to_owned(),
        allowance: AllowanceRecord {
            remaining_explanation_generations: 82,
            remaining_image_generations: 27,
        },
    };
    assert_eq!(record.clone(), record);
    assert_eq!(record.allowance.remaining_explanation_generations, 82);
    assert_eq!(record.allowance.remaining_image_generations, 27);
}
