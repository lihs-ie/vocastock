use std::collections::HashMap;
use std::sync::{Mutex, MutexGuard, OnceLock};

use command_api::{RegisterVocabularyExpressionCommand, Request};
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
