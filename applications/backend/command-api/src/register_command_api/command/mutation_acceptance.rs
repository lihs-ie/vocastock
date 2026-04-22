//! Acceptance flow shared across the five mutation endpoints.
//!
//! 1. Look up the idempotency record. If present and matching, replay.
//!    If present but diverging, return `ValidationFailed`.
//! 2. Dispatch the downstream PubSub message. On failure, return
//!    `DispatchFailed` without committing the idempotency record.
//! 3. On success, commit the idempotency record so subsequent replays
//!    return the same envelope.

use crate::runtime::{DispatchOutcome, DispatchPort, IdempotencyDecision, MutationCommandStore};

use super::mutation_request::{fingerprint_for, success_envelope, MutationCommand};
use super::mutation_response::{CommandErrorCategory, CommandResponseEnvelope, UserFacingMessage};

pub fn accept_mutation_command<C>(
    command: &C,
    store: &(impl MutationCommandStore + ?Sized),
    dispatcher: &(impl DispatchPort + ?Sized),
) -> CommandResponseEnvelope
where
    C: MutationCommand + ?Sized,
{
    let fingerprint = fingerprint_for(command);

    match store.idempotency_decision(
        command.actor_reference(),
        command.idempotency_key(),
        &fingerprint,
    ) {
        IdempotencyDecision::Replay(envelope) => envelope,
        IdempotencyDecision::Conflict => CommandResponseEnvelope::rejected(
            CommandErrorCategory::ValidationFailed,
            UserFacingMessage::new(
                "command.idempotency_conflict",
                "idempotency key was reused with a different payload",
            ),
        ),
        IdempotencyDecision::Fresh => {
            let plan = dispatcher.dispatch(command.dispatch_request());
            if plan.dispatch_outcome == DispatchOutcome::Failed {
                return CommandResponseEnvelope::rejected(
                    CommandErrorCategory::DispatchFailed,
                    UserFacingMessage::new(
                        "command.dispatch_failed",
                        "downstream workflow dispatch failed; request was not accepted",
                    ),
                );
            }

            let envelope = success_envelope(command);
            store.commit_mutation(
                command.actor_reference(),
                command.idempotency_key(),
                &fingerprint,
                &envelope,
            );
            envelope
        }
    }
}
