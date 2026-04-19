use std::collections::BTreeMap;

use query_api::{InMemoryCatalogProjectionSource, ProjectionSourceRecord};
use shared_auth::{
    ActorReference, AuthAccountReference, SessionReference, SessionState, VerifiedActorContext,
};

pub fn active_actor() -> VerifiedActorContext {
    VerifiedActorContext::new(
        ActorReference::new("actor:learner"),
        AuthAccountReference::new("auth:actor:learner"),
        SessionReference::new("session:actor:learner"),
        SessionState::Active,
    )
}

pub fn reauth_actor() -> VerifiedActorContext {
    VerifiedActorContext::new(
        ActorReference::new("actor:learner"),
        AuthAccountReference::new("auth:actor:learner"),
        SessionReference::new("session:actor:learner"),
        SessionState::ReauthRequired,
    )
}

pub fn empty_actor() -> VerifiedActorContext {
    custom_actor("actor:empty")
}

pub fn other_actor() -> VerifiedActorContext {
    custom_actor("actor:other")
}

pub fn custom_actor(actor_reference: &str) -> VerifiedActorContext {
    VerifiedActorContext::new(
        ActorReference::new(actor_reference),
        AuthAccountReference::new(format!("auth:{actor_reference}")),
        SessionReference::new(format!("session:{actor_reference}")),
        SessionState::Active,
    )
}

pub fn custom_source(records: Vec<ProjectionSourceRecord>) -> InMemoryCatalogProjectionSource {
    let mut actor_records = BTreeMap::new();
    actor_records.insert("actor:learner".to_owned(), records);
    InMemoryCatalogProjectionSource::from_actor_records(actor_records)
}
