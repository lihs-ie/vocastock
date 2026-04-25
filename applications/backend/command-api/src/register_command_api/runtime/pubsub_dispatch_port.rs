//! PubSub-backed implementation of `DispatchPort`.
//!
//! Each dispatch request is published as a single message on the
//! topic associated with its `DispatchKind`. Topics are resolved via
//! env vars so the compose layer can route per-environment; seed-time
//! topics are created by `firebase/seed/seed.mjs`.

use std::env;

use serde_json::json;
use shared_pubsub::{PubSubMessage, PubSubPublisher};

use super::dispatch_port::{DispatchKind, DispatchPlan, DispatchPort, DispatchRequest};

pub const TOPIC_EXPLANATION_ENV: &str = "VOCAS_PUBSUB_TOPIC_EXPLANATION";
pub const TOPIC_IMAGE_ENV: &str = "VOCAS_PUBSUB_TOPIC_IMAGE";
pub const TOPIC_RETRY_ENV: &str = "VOCAS_PUBSUB_TOPIC_RETRY";
pub const TOPIC_PURCHASE_ENV: &str = "VOCAS_PUBSUB_TOPIC_PURCHASE";

pub const DEFAULT_TOPIC_EXPLANATION: &str = "workflow.explanation-jobs";
pub const DEFAULT_TOPIC_IMAGE: &str = "workflow.image-jobs";
pub const DEFAULT_TOPIC_RETRY: &str = "workflow.retry-jobs";
pub const DEFAULT_TOPIC_PURCHASE: &str = "billing.purchase-jobs";

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct PubSubDispatchPort {
    publisher: PubSubPublisher,
}

impl PubSubDispatchPort {
    pub fn from_env() -> Option<Self> {
        PubSubPublisher::from_env().map(|publisher| Self { publisher })
    }

    pub fn new(publisher: PubSubPublisher) -> Self {
        Self { publisher }
    }

    fn topic_for(kind: DispatchKind) -> String {
        match kind {
            DispatchKind::ExplanationGeneration => env::var(TOPIC_EXPLANATION_ENV)
                .unwrap_or_else(|_| DEFAULT_TOPIC_EXPLANATION.to_owned()),
            DispatchKind::ImageGeneration => {
                env::var(TOPIC_IMAGE_ENV).unwrap_or_else(|_| DEFAULT_TOPIC_IMAGE.to_owned())
            }
            DispatchKind::Retry => {
                env::var(TOPIC_RETRY_ENV).unwrap_or_else(|_| DEFAULT_TOPIC_RETRY.to_owned())
            }
            DispatchKind::Purchase | DispatchKind::RestorePurchase => {
                env::var(TOPIC_PURCHASE_ENV).unwrap_or_else(|_| DEFAULT_TOPIC_PURCHASE.to_owned())
            }
        }
    }
}

impl DispatchPort for PubSubDispatchPort {
    fn dispatch(&self, request: DispatchRequest) -> DispatchPlan {
        let topic = Self::topic_for(request.kind);
        let message = build_dispatch_message(&request);
        match self.publisher.publish(topic.as_str(), &[message]) {
            Ok(_ids) => DispatchPlan::accepted(),
            Err(error) => {
                eprintln!(
                    "[pubsub_dispatch_port] publish failed topic={topic} kind={kind} error={error:?}",
                    kind = request.kind.as_str(),
                );
                DispatchPlan::failed()
            }
        }
    }
}

pub fn build_dispatch_message(request: &DispatchRequest) -> PubSubMessage {
    let payload = build_dispatch_payload(request);
    let mut message = PubSubMessage::new(payload.into_bytes())
        .with_attribute("actor", request.actor_reference.clone())
        .with_attribute("idempotencyKey", request.idempotency_key.clone())
        .with_attribute("kind", request.kind.as_str().to_owned());
    if let Some(retry_target) = request.retry_target.as_ref() {
        message = message.with_attribute("retryTarget", retry_target.clone());
    }
    if let Some(plan_code) = request.plan_code.as_ref() {
        message = message.with_attribute("planCode", plan_code.clone());
    }
    if let Some(sense_identifier) = request.sense_identifier.as_ref() {
        message = message.with_attribute("senseIdentifier", sense_identifier.clone());
    }
    message
}

fn build_dispatch_payload(request: &DispatchRequest) -> String {
    let mut payload = json!({
        "actor": request.actor_reference,
        "idempotencyKey": request.idempotency_key,
        "kind": request.kind.as_str(),
        "vocabularyExpression": request.target_vocabulary_expression,
        "restartRequested": request.restart_requested,
    });
    if let Some(value) = payload.as_object_mut() {
        if !request.normalized_text.is_empty() {
            value.insert(
                "normalizedText".to_owned(),
                serde_json::Value::String(request.normalized_text.clone()),
            );
        }
        if let Some(retry_target) = request.retry_target.as_ref() {
            value.insert(
                "retryTarget".to_owned(),
                serde_json::Value::String(retry_target.clone()),
            );
        }
        if let Some(plan_code) = request.plan_code.as_ref() {
            value.insert(
                "planCode".to_owned(),
                serde_json::Value::String(plan_code.clone()),
            );
        }
        if let Some(sense_identifier) = request.sense_identifier.as_ref() {
            value.insert(
                "senseIdentifier".to_owned(),
                serde_json::Value::String(sense_identifier.clone()),
            );
        }
    }
    payload.to_string()
}
