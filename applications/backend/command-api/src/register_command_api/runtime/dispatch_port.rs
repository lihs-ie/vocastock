use std::sync::Mutex;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct DispatchRequest {
    pub actor_reference: String,
    pub idempotency_key: String,
    pub normalized_text: String,
    pub target_vocabulary_expression: String,
    pub restart_requested: bool,
}

impl DispatchRequest {
    pub fn new(
        actor_reference: impl Into<String>,
        idempotency_key: impl Into<String>,
        normalized_text: impl Into<String>,
        target_vocabulary_expression: impl Into<String>,
        restart_requested: bool,
    ) -> Self {
        Self {
            actor_reference: actor_reference.into(),
            idempotency_key: idempotency_key.into(),
            normalized_text: normalized_text.into(),
            target_vocabulary_expression: target_vocabulary_expression.into(),
            restart_requested,
        }
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum DispatchOutcome {
    NotRequested,
    Accepted,
    Failed,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct DispatchPlan {
    pub dispatch_required: bool,
    pub dispatch_outcome: DispatchOutcome,
}

impl DispatchPlan {
    pub fn not_requested() -> Self {
        Self {
            dispatch_required: false,
            dispatch_outcome: DispatchOutcome::NotRequested,
        }
    }

    pub fn accepted() -> Self {
        Self {
            dispatch_required: true,
            dispatch_outcome: DispatchOutcome::Accepted,
        }
    }

    pub fn failed() -> Self {
        Self {
            dispatch_required: true,
            dispatch_outcome: DispatchOutcome::Failed,
        }
    }
}

#[derive(Debug, Default)]
pub struct InMemoryDispatchPort {
    requests: Mutex<Vec<DispatchRequest>>,
}

impl InMemoryDispatchPort {
    pub fn dispatch(&self, request: DispatchRequest) -> DispatchPlan {
        self.requests
            .lock()
            .expect("dispatch port lock poisoned")
            .push(request.clone());

        if request.idempotency_key.contains("dispatch-fail") {
            DispatchPlan::failed()
        } else {
            DispatchPlan::accepted()
        }
    }

    pub fn recorded_requests(&self) -> Vec<DispatchRequest> {
        self.requests
            .lock()
            .expect("dispatch port lock poisoned")
            .clone()
    }
}
