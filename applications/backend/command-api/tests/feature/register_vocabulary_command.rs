use serde_json::json;

use crate::support::{assert_contains, assert_not_contains, FeatureRuntime};

#[test]
fn register_vocabulary_command_runs_against_dockerized_command_api_and_firebase_emulator() {
    let runtime = FeatureRuntime::start();

    let root = runtime.get("/", None);
    assert_eq!(root.status, 200);
    assert_contains(&root.body, "accepted/reused-existing", "root response");

    let dependency = runtime.get("/dependencies/firebase", None);
    assert_eq!(dependency.status, 200);
    assert_contains(
        &dependency.body,
        &format!(
            "firestore=host.docker.internal:{} (reachable",
            runtime.firestore_port()
        ),
        "firebase dependency report",
    );
    assert_contains(
        &dependency.body,
        &format!(
            "storage=host.docker.internal:{} (reachable",
            runtime.storage_port()
        ),
        "firebase dependency report",
    );
    assert_contains(
        &dependency.body,
        &format!(
            "auth=host.docker.internal:{} (reachable",
            runtime.auth_port()
        ),
        "firebase dependency report",
    );

    let accepted_payload = json!({
        "command": "registerVocabularyExpression",
        "actor": "actor:learner",
        "idempotencyKey": "feature-accepted",
        "body": {
            "text": "  Mixed   Case  "
        }
    });
    let accepted = runtime.post_json(
        "/commands/register-vocabulary-expression",
        Some("Bearer valid-learner-token"),
        &accepted_payload,
    );
    assert_eq!(accepted.status, 202);
    assert_contains(
        &accepted.body,
        "\"acceptance\":\"accepted\"",
        "accepted response",
    );
    assert_contains(
        &accepted.body,
        "\"vocabularyExpression\":\"vocabulary:mixed-case\"",
        "accepted response",
    );
    assert_contains(
        &accepted.body,
        "\"explanation\":\"queued\"",
        "accepted response",
    );
    assert_contains(
        &accepted.body,
        "\"replayedByIdempotency\":false",
        "accepted response",
    );
    assert_not_contains(&accepted.body, "duplicateReuse", "accepted response");
    assert_not_contains(&accepted.body, "completedSummary", "accepted response");
    assert_not_contains(&accepted.body, "imagePayload", "accepted response");

    let replay = runtime.post_json(
        "/commands/register-vocabulary-expression",
        Some("Bearer valid-learner-token"),
        &accepted_payload,
    );
    assert_eq!(replay.status, 202);
    assert_contains(
        &replay.body,
        "\"replayedByIdempotency\":true",
        "replay response",
    );

    let reused = runtime.post_json(
        "/commands/register-vocabulary-expression",
        Some("Bearer valid-learner-token"),
        &json!({
            "command": "registerVocabularyExpression",
            "actor": "actor:learner",
            "idempotencyKey": "feature-reuse",
            "body": {
                "text": "mixed case"
            }
        }),
    );
    assert_eq!(reused.status, 202);
    assert_contains(
        &reused.body,
        "\"acceptance\":\"reused-existing\"",
        "reused-existing response",
    );
    assert_contains(
        &reused.body,
        "\"duplicateReuse\":",
        "reused-existing response",
    );

    let without_dispatch = runtime.post_json(
        "/commands/register-vocabulary-expression",
        Some("Bearer valid-learner-token"),
        &json!({
            "command": "registerVocabularyExpression",
            "actor": "actor:learner",
            "idempotencyKey": "feature-no-dispatch",
            "body": {
                "text": "Silent term",
                "startExplanation": false
            }
        }),
    );
    assert_eq!(without_dispatch.status, 202);
    assert_contains(
        &without_dispatch.body,
        "\"explanation\":\"not-started\"",
        "startExplanation=false response",
    );

    let missing = runtime.post_json(
        "/commands/register-vocabulary-expression",
        None,
        &json!({
            "command": "registerVocabularyExpression",
            "actor": "actor:learner",
            "idempotencyKey": "feature-missing-auth",
            "body": {
                "text": "coffee"
            }
        }),
    );
    assert_eq!(missing.status, 401);
    assert_contains(
        &missing.body,
        "missing bearer token",
        "missing auth response",
    );

    let reauth = runtime.post_json(
        "/commands/register-vocabulary-expression",
        Some("Bearer reauth-token"),
        &json!({
            "command": "registerVocabularyExpression",
            "actor": "actor:learner",
            "idempotencyKey": "feature-reauth",
            "body": {
                "text": "coffee"
            }
        }),
    );
    assert_eq!(reauth.status, 403);
    assert_contains(&reauth.body, "reauthentication", "reauth response");

    let conflict_first = runtime.post_json(
        "/commands/register-vocabulary-expression",
        Some("Bearer valid-learner-token"),
        &json!({
            "command": "registerVocabularyExpression",
            "actor": "actor:learner",
            "idempotencyKey": "feature-conflict",
            "body": {
                "text": "conflict one"
            }
        }),
    );
    assert_eq!(conflict_first.status, 202);

    let conflict = runtime.post_json(
        "/commands/register-vocabulary-expression",
        Some("Bearer valid-learner-token"),
        &json!({
            "command": "registerVocabularyExpression",
            "actor": "actor:learner",
            "idempotencyKey": "feature-conflict",
            "body": {
                "text": "conflict two"
            }
        }),
    );
    assert_eq!(conflict.status, 409);
    assert_contains(&conflict.body, "idempotency-conflict", "conflict response");

    let dispatch_failed = runtime.post_json(
        "/commands/register-vocabulary-expression",
        Some("Bearer valid-learner-token"),
        &json!({
            "command": "registerVocabularyExpression",
            "actor": "actor:learner",
            "idempotencyKey": "feature-dispatch-fail",
            "body": {
                "text": "rollback term"
            }
        }),
    );
    assert_eq!(dispatch_failed.status, 503);
    assert_contains(
        &dispatch_failed.body,
        "dispatch-failed",
        "dispatch failure response",
    );

    let accepted_after_failure = runtime.post_json(
        "/commands/register-vocabulary-expression",
        Some("Bearer valid-learner-token"),
        &json!({
            "command": "registerVocabularyExpression",
            "actor": "actor:learner",
            "idempotencyKey": "feature-dispatch-retry",
            "body": {
                "text": "rollback term"
            }
        }),
    );
    assert_eq!(accepted_after_failure.status, 202);
    assert_contains(
        &accepted_after_failure.body,
        "\"acceptance\":\"accepted\"",
        "accepted after failed dispatch",
    );

    let method_not_allowed = runtime.get(
        "/commands/register-vocabulary-expression",
        Some("Bearer valid-learner-token"),
    );
    assert_eq!(method_not_allowed.status, 405);
    assert_contains(
        &method_not_allowed.body,
        "method not allowed",
        "method not allowed response",
    );
}
