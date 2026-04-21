use serde::Serialize;

#[derive(Clone, Copy, Debug, Eq, PartialEq, Serialize)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
pub enum SubscriptionState {
    Active,
    Grace,
    PendingSync,
    Expired,
    Revoked,
}

impl SubscriptionState {
    pub fn parse(raw: &str) -> Self {
        match raw {
            "active" => Self::Active,
            "grace" => Self::Grace,
            "expired" => Self::Expired,
            "revoked" => Self::Revoked,
            _ => Self::PendingSync,
        }
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq, Serialize)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
pub enum PlanCode {
    Free,
    StandardMonthly,
    ProMonthly,
}

impl PlanCode {
    pub fn parse(raw: &str) -> Self {
        match raw {
            "standardMonthly" => Self::StandardMonthly,
            "proMonthly" => Self::ProMonthly,
            _ => Self::Free,
        }
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq, Serialize)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
pub enum EntitlementBundle {
    FreeBasic,
    PremiumGeneration,
}

impl EntitlementBundle {
    pub fn parse(raw: &str) -> Self {
        match raw {
            "premiumGeneration" => Self::PremiumGeneration,
            _ => Self::FreeBasic,
        }
    }
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct UsageAllowanceView {
    pub remaining_explanation_generations: i64,
    pub remaining_image_generations: i64,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct SubscriptionStatusView {
    pub state: SubscriptionState,
    pub plan: PlanCode,
    pub entitlement: EntitlementBundle,
    pub allowance: UsageAllowanceView,
}

impl SubscriptionStatusView {
    /// Contract-safe default for actors whose subscription document
    /// has not been provisioned yet. GraphQL declares the whole view
    /// as non-null, so returning *something* is mandatory; using
    /// `PENDING_SYNC` / `FREE` / `FREE_BASIC` is semantically honest
    /// ("we have no authoritative record yet") without inventing
    /// entitlements the user has not earned.
    pub fn pending_sync_default() -> Self {
        Self {
            state: SubscriptionState::PendingSync,
            plan: PlanCode::Free,
            entitlement: EntitlementBundle::FreeBasic,
            allowance: UsageAllowanceView {
                remaining_explanation_generations: 0,
                remaining_image_generations: 0,
            },
        }
    }
}
