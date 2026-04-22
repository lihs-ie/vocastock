use std::cell::RefCell;
use std::collections::HashMap;
use std::sync::{Mutex, MutexGuard, OnceLock};

use command_api::{
    CommandResponseEnvelope, DispatchPlan, DispatchPort, DispatchRequest, IdempotencyDecision,
    MutationCommandStore, MutationFingerprint, RegisterVocabularyExpressionCommand, Request,
};
use serde_json::json;
use shared_auth::{
    ActorReference, AuthAccountReference, SessionReference, SessionState, VerifiedActorContext,
};

pub fn active_actor() -> VerifiedActorContext {
    actor("actor:learner")
}

pub fn other_actor() -> VerifiedActorContext {
    actor("actor:other")
}

pub fn actor(actor_reference: &str) -> VerifiedActorContext {
    VerifiedActorContext::new(
        ActorReference::new(actor_reference),
        AuthAccountReference::new(format!("auth:{actor_reference}")),
        SessionReference::new(format!("session:{actor_reference}")),
        SessionState::Active,
    )
}

pub fn command(
    actor_context: &VerifiedActorContext,
    idempotency_key: &str,
    normalized_text: &str,
    start_explanation: bool,
) -> RegisterVocabularyExpressionCommand {
    RegisterVocabularyExpressionCommand {
        actor: actor_context.clone(),
        idempotency_key: idempotency_key.to_owned(),
        normalized_text: normalized_text.to_owned(),
        start_explanation,
    }
}

pub fn register_command_json(
    actor_reference: &str,
    idempotency_key: &str,
    text: &str,
    start_explanation: Option<bool>,
) -> String {
    let mut body = json!({
        "command": "registerVocabularyExpression",
        "actor": actor_reference,
        "idempotencyKey": idempotency_key,
        "body": {
            "text": text
        }
    });

    if let Some(start_explanation) = start_explanation {
        body["body"]["startExplanation"] = json!(start_explanation);
    }

    body.to_string()
}

pub fn request(method: &str, path: &str, authorization: Option<&str>, body: &str) -> Request {
    let mut headers = HashMap::new();
    if let Some(authorization) = authorization {
        headers.insert("authorization".to_owned(), authorization.to_owned());
    }

    Request {
        method: method.to_owned(),
        path: path.to_owned(),
        headers,
        body: body.to_owned(),
    }
}

pub fn env_lock() -> MutexGuard<'static, ()> {
    static LOCK: OnceLock<Mutex<()>> = OnceLock::new();
    LOCK.get_or_init(|| Mutex::new(()))
        .lock()
        .expect("unit env lock poisoned")
}

// ---------- Test doubles (tests/support only, not in production crate) ----

#[derive(Default)]
pub struct MutationCommandStoreTestDouble {
    decisions: RefCell<HashMap<(String, String), StoredDecision>>,
    commits: RefCell<Vec<CommitRecord>>,
}

#[derive(Clone)]
pub struct StoredDecision {
    pub fingerprint: MutationFingerprint,
    pub envelope: CommandResponseEnvelope,
}

#[derive(Clone)]
#[allow(dead_code)]
pub struct CommitRecord {
    pub actor: String,
    pub idempotency_key: String,
    pub fingerprint: MutationFingerprint,
    pub envelope: CommandResponseEnvelope,
}

impl MutationCommandStoreTestDouble {
    pub fn with_existing(
        actor: &str,
        idempotency_key: &str,
        fingerprint: MutationFingerprint,
        envelope: CommandResponseEnvelope,
    ) -> Self {
        let mut decisions = HashMap::new();
        decisions.insert(
            (actor.to_owned(), idempotency_key.to_owned()),
            StoredDecision {
                fingerprint,
                envelope,
            },
        );
        Self {
            decisions: RefCell::new(decisions),
            commits: RefCell::new(Vec::new()),
        }
    }

    pub fn commits(&self) -> Vec<CommitRecord> {
        self.commits.borrow().clone()
    }
}

impl MutationCommandStore for MutationCommandStoreTestDouble {
    fn idempotency_decision(
        &self,
        actor: &str,
        idempotency_key: &str,
        fingerprint: &MutationFingerprint,
    ) -> IdempotencyDecision {
        match self
            .decisions
            .borrow()
            .get(&(actor.to_owned(), idempotency_key.to_owned()))
        {
            Some(stored) if &stored.fingerprint == fingerprint => {
                IdempotencyDecision::Replay(stored.envelope.clone())
            }
            Some(_) => IdempotencyDecision::Conflict,
            None => IdempotencyDecision::Fresh,
        }
    }

    fn commit_mutation(
        &self,
        actor: &str,
        idempotency_key: &str,
        fingerprint: &MutationFingerprint,
        envelope: &CommandResponseEnvelope,
    ) {
        self.commits.borrow_mut().push(CommitRecord {
            actor: actor.to_owned(),
            idempotency_key: idempotency_key.to_owned(),
            fingerprint: fingerprint.clone(),
            envelope: envelope.clone(),
        });
    }
}

#[derive(Default)]
pub struct DispatchPortTestDouble {
    requests: RefCell<Vec<DispatchRequest>>,
    force_fail: bool,
}

impl DispatchPortTestDouble {
    pub fn accepting() -> Self {
        Self::default()
    }

    pub fn failing() -> Self {
        Self {
            requests: RefCell::new(Vec::new()),
            force_fail: true,
        }
    }

    pub fn dispatched(&self) -> Vec<DispatchRequest> {
        self.requests.borrow().clone()
    }
}

impl DispatchPort for DispatchPortTestDouble {
    fn dispatch(&self, request: DispatchRequest) -> DispatchPlan {
        self.requests.borrow_mut().push(request);
        if self.force_fail {
            DispatchPlan::failed()
        } else {
            DispatchPlan::accepted()
        }
    }
}
