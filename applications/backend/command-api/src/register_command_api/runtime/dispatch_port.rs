use std::sync::Mutex;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum DispatchKind {
    /// `registerVocabularyExpression` と `requestExplanationGeneration`
    /// が使う topic — vocabulary に紐づく explanation の生成依頼。
    ExplanationGeneration,
    ImageGeneration,
    Retry,
    Purchase,
    RestorePurchase,
}

impl DispatchKind {
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::ExplanationGeneration => "explanation-generation",
            Self::ImageGeneration => "image-generation",
            Self::Retry => "retry",
            Self::Purchase => "purchase",
            Self::RestorePurchase => "restore-purchase",
        }
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct DispatchRequest {
    pub actor_reference: String,
    pub idempotency_key: String,
    pub normalized_text: String,
    pub target_vocabulary_expression: String,
    pub restart_requested: bool,
    pub kind: DispatchKind,
    pub retry_target: Option<String>,
    pub plan_code: Option<String>,
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
            kind: DispatchKind::ExplanationGeneration,
            retry_target: None,
            plan_code: None,
        }
    }

    pub fn with_kind(mut self, kind: DispatchKind) -> Self {
        self.kind = kind;
        self
    }

    pub fn with_retry_target(mut self, target: impl Into<String>) -> Self {
        self.retry_target = Some(target.into());
        self
    }

    pub fn with_plan_code(mut self, plan_code: impl Into<String>) -> Self {
        self.plan_code = Some(plan_code.into());
        self
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

/// Port for workflow dispatch. Implementations decide how a command
/// reaches downstream workers: the in-memory variant records requests
/// for tests, while the production adapter publishes to PubSub.
pub trait DispatchPort {
    fn dispatch(&self, request: DispatchRequest) -> DispatchPlan;
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

impl DispatchPort for InMemoryDispatchPort {
    fn dispatch(&self, request: DispatchRequest) -> DispatchPlan {
        Self::dispatch(self, request)
    }
}
