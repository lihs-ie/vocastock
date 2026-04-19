use shared_auth::VerifiedActorContext;

pub const SERVICE_NAME: &str = "query-api";

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum ProjectionState {
    Pending,
    Running,
    Succeeded,
    Failed,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum QueryReadResponse {
    StatusOnly {
        state: ProjectionState,
        message: String,
    },
    Completed {
        payload_summary: String,
    },
}

pub fn read_projection(
    _actor_context: &VerifiedActorContext,
    state: ProjectionState,
    completed_summary: Option<&str>,
) -> QueryReadResponse {
    match (state, completed_summary) {
        (ProjectionState::Succeeded, Some(payload_summary)) => QueryReadResponse::Completed {
            payload_summary: payload_summary.to_owned(),
        },
        (state, _) => QueryReadResponse::StatusOnly {
            state,
            message: "projection is not ready; return status-only".to_owned(),
        },
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use shared_auth::{
        ActorReference, AuthAccountReference, SessionReference, SessionState, VerifiedActorContext,
    };

    fn sample_actor() -> VerifiedActorContext {
        VerifiedActorContext::new(
            ActorReference::new("actor:learner"),
            AuthAccountReference::new("auth:learner"),
            SessionReference::new("session:primary"),
            SessionState::Active,
        )
    }

    #[test]
    fn pending_projection_returns_status_only() {
        let response = read_projection(&sample_actor(), ProjectionState::Pending, None);

        assert_eq!(
            response,
            QueryReadResponse::StatusOnly {
                state: ProjectionState::Pending,
                message: "projection is not ready; return status-only".to_owned(),
            }
        );
    }

    #[test]
    fn succeeded_projection_without_payload_stays_status_only() {
        let response = read_projection(&sample_actor(), ProjectionState::Succeeded, None);

        assert!(matches!(
            response,
            QueryReadResponse::StatusOnly {
                state: ProjectionState::Succeeded,
                ..
            }
        ));
    }

    #[test]
    fn succeeded_projection_with_payload_returns_completed() {
        let response = read_projection(
            &sample_actor(),
            ProjectionState::Succeeded,
            Some("completed explanation detail"),
        );

        assert_eq!(
            response,
            QueryReadResponse::Completed {
                payload_summary: "completed explanation detail".to_owned(),
            }
        );
    }
}
