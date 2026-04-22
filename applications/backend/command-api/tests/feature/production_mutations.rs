//! End-to-end feature test for the production adapter path.
//!
//! Boots command-api with `VOCAS_PRODUCTION_ADAPTERS=true` so Firestore
//! writes flow through `FirestoreCommandStore` /
//! `FirestoreMutationCommandStore` and dispatches go through
//! `PubSubDispatchPort`. Each endpoint exercise verifies the HTTP
//! envelope; payload propagation into PubSub subscribers is covered by
//! worker feature tests in specs 021/022/023.

use serde_json::json;

use crate::support::{assert_contains, FeatureRuntime};

fn post_body(
    command: &str,
    actor: &str,
    idempotency_key: &str,
    extra: serde_json::Value,
) -> String {
    let mut base = json!({
        "actor": actor,
        "idempotencyKey": idempotency_key,
    });
    if let Some(obj) = base.as_object_mut() {
        if let Some(extra_obj) = extra.as_object() {
            for (key, value) in extra_obj {
                obj.insert(key.clone(), value.clone());
            }
        }
    }
    if command == "registerVocabularyExpression" {
        // The register endpoint reuses the pre-existing envelope shape.
        let body = json!({
            "command": command,
            "actor": actor,
            "idempotencyKey": idempotency_key,
            "body": {
                "text": extra.get("text").and_then(|v| v.as_str()).unwrap_or(""),
            },
        });
        return body.to_string();
    }
    base.to_string()
}

#[test]
fn production_adapters_path_accepts_register_and_five_mutations() {
    let runtime = FeatureRuntime::start_with_production_adapters();
    let demo_bearer = runtime.demo_bearer();

    // --- register vocabulary expression ---
    let register = runtime.post_raw(
        "/commands/register-vocabulary-expression",
        Some(demo_bearer.as_str()),
        post_body(
            "registerVocabularyExpression",
            "stub-actor-demo",
            "feat-register-1",
            json!({"text": "serendipity"}),
        )
        .as_str(),
    );
    assert_eq!(register.status, 202);
    assert_contains(
        &register.body,
        "\"acceptance\":\"accepted\"",
        "register accepted envelope",
    );

    // --- request explanation generation ---
    let explanation = runtime.post_raw(
        "/commands/request-explanation-generation",
        Some(demo_bearer.as_str()),
        post_body(
            "requestExplanationGeneration",
            "stub-actor-demo",
            "feat-explanation-1",
            json!({"vocabularyExpression": "vocabulary:serendipity"}),
        )
        .as_str(),
    );
    assert_eq!(explanation.status, 202);
    assert_contains(
        &explanation.body,
        "\"accepted\":true",
        "explanation accepted envelope",
    );
    assert_contains(
        &explanation.body,
        "\"outcome\":\"ACCEPTED\"",
        "explanation outcome",
    );

    // --- request image generation ---
    let image = runtime.post_raw(
        "/commands/request-image-generation",
        Some(demo_bearer.as_str()),
        post_body(
            "requestImageGeneration",
            "stub-actor-demo",
            "feat-image-1",
            json!({"vocabularyExpression": "vocabulary:serendipity"}),
        )
        .as_str(),
    );
    assert_eq!(image.status, 202);
    assert_contains(
        &image.body,
        "\"outcome\":\"ACCEPTED\"",
        "image accepted envelope",
    );

    // --- retry generation ---
    let retry = runtime.post_raw(
        "/commands/retry-generation",
        Some(demo_bearer.as_str()),
        post_body(
            "retryGeneration",
            "stub-actor-demo",
            "feat-retry-1",
            json!({
                "vocabularyExpression": "vocabulary:serendipity",
                "target": "EXPLANATION",
            }),
        )
        .as_str(),
    );
    assert_eq!(retry.status, 202);
    assert_contains(
        &retry.body,
        "\"outcome\":\"ACCEPTED\"",
        "retry accepted envelope",
    );

    // --- request purchase ---
    let purchase = runtime.post_raw(
        "/commands/request-purchase",
        Some(demo_bearer.as_str()),
        post_body(
            "requestPurchase",
            "stub-actor-demo",
            "feat-purchase-1",
            json!({"planCode": "STANDARD_MONTHLY"}),
        )
        .as_str(),
    );
    assert_eq!(purchase.status, 202);
    assert_contains(
        &purchase.body,
        "\"outcome\":\"ACCEPTED\"",
        "purchase accepted envelope",
    );

    // --- request restore purchase ---
    let restore = runtime.post_raw(
        "/commands/request-restore-purchase",
        Some(demo_bearer.as_str()),
        post_body(
            "requestRestorePurchase",
            "stub-actor-demo",
            "feat-restore-1",
            json!({}),
        )
        .as_str(),
    );
    assert_eq!(restore.status, 202);
    assert_contains(
        &restore.body,
        "\"outcome\":\"ACCEPTED\"",
        "restore purchase accepted envelope",
    );

    // --- idempotency replay returns the same envelope without re-dispatch ---
    let replay = runtime.post_raw(
        "/commands/request-explanation-generation",
        Some(demo_bearer.as_str()),
        post_body(
            "requestExplanationGeneration",
            "stub-actor-demo",
            "feat-explanation-1",
            json!({"vocabularyExpression": "vocabulary:serendipity"}),
        )
        .as_str(),
    );
    assert_eq!(replay.status, 202);
    assert_contains(&replay.body, "\"accepted\":true", "replay envelope");

    // --- idempotency conflict surfaces VALIDATION_FAILED ---
    let conflict = runtime.post_raw(
        "/commands/request-explanation-generation",
        Some(demo_bearer.as_str()),
        post_body(
            "requestExplanationGeneration",
            "stub-actor-demo",
            "feat-explanation-1",
            json!({"vocabularyExpression": "vocabulary:different"}),
        )
        .as_str(),
    );
    assert_eq!(conflict.status, 400);
    assert_contains(
        &conflict.body,
        "\"errorCategory\":\"VALIDATION_FAILED\"",
        "conflict envelope",
    );

    // --- missing auth still surfaces DOWNSTREAM_AUTH_FAILED ---
    let unauthorized = runtime.post_raw(
        "/commands/request-explanation-generation",
        None,
        "{\"actor\":\"stub-actor-demo\",\"idempotencyKey\":\"feat-unauth\",\"vocabularyExpression\":\"vocabulary:run\"}",
    );
    assert_eq!(unauthorized.status, 403);
    assert_contains(
        &unauthorized.body,
        "DOWNSTREAM_AUTH_FAILED",
        "unauthorized envelope",
    );
}
