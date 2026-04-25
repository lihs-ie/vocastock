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
    pub sense_identifier: Option<String>,
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
            sense_identifier: None,
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

    pub fn with_sense_identifier(mut self, sense: impl Into<String>) -> Self {
        self.sense_identifier = Some(sense.into());
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
/// reaches downstream workers: the PubSub-backed production adapter
/// lives in `pubsub_dispatch_port`; the deterministic in-memory double
/// consumed by unit tests lives under `tests/support/dispatch_port.rs`.
pub trait DispatchPort {
    fn dispatch(&self, request: DispatchRequest) -> DispatchPlan;
}
