use shared_auth::{self, TokenVerificationPort, VerifiedActorContext};

use super::model::{
    EntitlementBundle, PlanCode, SubscriptionState, SubscriptionStatusView, UsageAllowanceView,
};
use super::source::{SubscriptionRecord, SubscriptionStatusSource};
use crate::runtime::authorization::extract_bearer_token;

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum SubscriptionStatusError {
    Auth(shared_auth::TokenVerificationError),
    InactiveSession,
}

impl SubscriptionStatusError {
    pub fn user_message(&self) -> &'static str {
        match self {
            Self::Auth(error) => error.message(),
            Self::InactiveSession => "session is not active",
        }
    }
}

pub fn read_subscription_status(
    actor_context: &VerifiedActorContext,
    source: &(impl SubscriptionStatusSource + ?Sized),
) -> Result<SubscriptionStatusView, SubscriptionStatusError> {
    if !actor_context.is_active() {
        return Err(SubscriptionStatusError::InactiveSession);
    }

    Ok(source
        .record_for(actor_context)
        .map(map_record)
        .unwrap_or_else(SubscriptionStatusView::pending_sync_default))
}

pub fn read_subscription_status_from_authorization_header(
    authorization_header: Option<&str>,
    verifier: &(impl TokenVerificationPort + ?Sized),
    source: &(impl SubscriptionStatusSource + ?Sized),
) -> Result<SubscriptionStatusView, SubscriptionStatusError> {
    let bearer_token =
        extract_bearer_token(authorization_header).map_err(SubscriptionStatusError::Auth)?;
    let actor_context = verifier
        .verify(bearer_token)
        .map_err(SubscriptionStatusError::Auth)?;

    read_subscription_status(&actor_context, source)
}

fn map_record(record: SubscriptionRecord) -> SubscriptionStatusView {
    SubscriptionStatusView {
        state: SubscriptionState::parse(record.state.as_str()),
        plan: PlanCode::parse(record.plan.as_str()),
        entitlement: EntitlementBundle::parse(record.entitlement.as_str()),
        allowance: UsageAllowanceView {
            remaining_explanation_generations: record.allowance.remaining_explanation_generations,
            remaining_image_generations: record.allowance.remaining_image_generations,
        },
    }
}
