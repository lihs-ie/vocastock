//! Idempotency / replay store for the five non-register mutations.
//!
//! The register endpoint keeps its richer `CommandStore` trait because
//! it persists registration state in Firestore alongside idempotency
//! records. The other five mutations are explanation / image
//! generation requests, retry, purchase, and restore-purchase — none
//! of which own authoritative aggregate state: workers are the system
//! of record for explanation/image status, and the billing service
//! owns subscription state. Command-api only tracks idempotency here
//! so replays return the same envelope without re-dispatching.

use crate::command::CommandResponseEnvelope;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct MutationFingerprint {
    pub command_name: String,
    pub payload_hash: String,
}

impl MutationFingerprint {
    pub fn new(command_name: impl Into<String>, payload_hash: impl Into<String>) -> Self {
        Self {
            command_name: command_name.into(),
            payload_hash: payload_hash.into(),
        }
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum IdempotencyDecision {
    Replay(CommandResponseEnvelope),
    Conflict,
    Fresh,
}

pub trait MutationCommandStore {
    fn idempotency_decision(
        &self,
        actor_reference: &str,
        idempotency_key: &str,
        fingerprint: &MutationFingerprint,
    ) -> IdempotencyDecision;

    fn commit_mutation(
        &self,
        actor_reference: &str,
        idempotency_key: &str,
        fingerprint: &MutationFingerprint,
        envelope: &CommandResponseEnvelope,
    );
}
