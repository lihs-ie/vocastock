use shared_auth::VerifiedActorContext;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct AllowanceRecord {
    pub remaining_explanation_generations: i64,
    pub remaining_image_generations: i64,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct SubscriptionRecord {
    pub state: String,
    pub plan: String,
    pub entitlement: String,
    pub allowance: AllowanceRecord,
}

pub trait SubscriptionStatusSource {
    fn record_for(&self, actor_context: &VerifiedActorContext) -> Option<SubscriptionRecord>;
}
