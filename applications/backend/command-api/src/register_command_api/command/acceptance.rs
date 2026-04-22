use crate::runtime::{status_handle_for, CommandStore, DispatchPort, REGISTERED_STATE};

use super::request::RegisterVocabularyExpressionCommand;
use super::response::{
    AcceptanceOutcome, AcceptedCommandFields, AcceptedCommandResult, CommandFailure, StateSummary,
    TargetReference,
};

#[allow(clippy::result_large_err)]
pub fn accept_register_command(
    command: &RegisterVocabularyExpressionCommand,
    store: &(impl CommandStore + ?Sized),
    dispatcher: &(impl DispatchPort + ?Sized),
) -> Result<AcceptedCommandResult, CommandFailure> {
    match store.plan(command) {
        crate::runtime::StoreDecision::ReplayExisting(result) => Ok(result.replay()),
        crate::runtime::StoreDecision::Conflict => Err(CommandFailure::idempotency_conflict()),
        crate::runtime::StoreDecision::AcceptNew(plan) => {
            let dispatch_plan = if plan.dispatch_required {
                dispatcher.dispatch(crate::runtime::DispatchRequest::new(
                    command.actor.actor().as_str(),
                    command.idempotency_key.as_str(),
                    command.normalized_text.as_str(),
                    plan.vocabulary_expression.as_str(),
                    false,
                ))
            } else {
                crate::runtime::DispatchPlan::not_requested()
            };

            if dispatch_plan.dispatch_outcome == crate::runtime::DispatchOutcome::Failed {
                return Err(CommandFailure::dispatch_failed());
            }

            let result = AcceptedCommandResult::new(
                AcceptanceOutcome::Accepted,
                AcceptedCommandFields {
                    target: TargetReference {
                        vocabulary_expression: plan.vocabulary_expression.clone(),
                    },
                    state: StateSummary {
                        registration: REGISTERED_STATE.to_owned(),
                        explanation: plan.explanation_state.clone(),
                    },
                    status_handle: status_handle_for(
                        command.actor.actor().as_str(),
                        plan.vocabulary_expression.as_str(),
                    ),
                    message: accepted_message(command.start_explanation),
                    replayed_by_idempotency: false,
                    duplicate_reuse: None,
                },
            );
            store.commit_new(command, &plan, &result);
            Ok(result)
        }
        crate::runtime::StoreDecision::ReuseExisting(plan) => {
            let dispatch_plan = if plan.dispatch_required {
                dispatcher.dispatch(crate::runtime::DispatchRequest::new(
                    command.actor.actor().as_str(),
                    command.idempotency_key.as_str(),
                    command.normalized_text.as_str(),
                    plan.existing_registration.vocabulary_expression.as_str(),
                    true,
                ))
            } else {
                crate::runtime::DispatchPlan::not_requested()
            };

            if dispatch_plan.dispatch_outcome == crate::runtime::DispatchOutcome::Failed {
                return Err(CommandFailure::dispatch_failed());
            }

            let result = AcceptedCommandResult::new(
                AcceptanceOutcome::ReusedExisting,
                AcceptedCommandFields {
                    target: TargetReference {
                        vocabulary_expression: plan
                            .existing_registration
                            .vocabulary_expression
                            .clone(),
                    },
                    state: StateSummary {
                        registration: plan.existing_registration.registration_state.clone(),
                        explanation: plan.resulting_explanation_state.clone(),
                    },
                    status_handle: status_handle_for(
                        command.actor.actor().as_str(),
                        plan.existing_registration.vocabulary_expression.as_str(),
                    ),
                    message: reused_existing_message(plan.dispatch_required),
                    replayed_by_idempotency: false,
                    duplicate_reuse: Some(plan.duplicate_reuse.clone()),
                },
            );
            store.commit_reuse(command, &plan, &result);
            Ok(result)
        }
    }
}

fn accepted_message(start_explanation: bool) -> String {
    if start_explanation {
        "registration accepted and queued for explanation dispatch".to_owned()
    } else {
        "registration accepted without explanation dispatch".to_owned()
    }
}

fn reused_existing_message(restarted: bool) -> String {
    if restarted {
        "existing registration reused and explanation restart accepted".to_owned()
    } else {
        "existing registration reused without explanation restart".to_owned()
    }
}
