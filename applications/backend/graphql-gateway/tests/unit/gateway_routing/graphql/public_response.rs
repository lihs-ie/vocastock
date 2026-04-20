use graphql_gateway::graphql::{catalog_success_response, mutation_success_response};
use serde_json::json;

#[test]
fn mutation_success_response_wraps_command_payload_under_graphql_data() {
    let response = mutation_success_response(json!({
        "acceptance": "accepted",
        "target": {
            "vocabularyExpression": "vocabulary:coffee"
        },
        "state": {
            "registration": "registered",
            "explanation": "queued"
        },
        "statusHandle": "status:actor:learner:vocabulary:coffee",
        "message": "registerVocabularyExpression was accepted for asynchronous processing",
        "replayedByIdempotency": false
    }))
    .expect("mutation payload should wrap");

    assert!(response.contains("\"data\""));
    assert!(response.contains("\"registerVocabularyExpression\""));
    assert!(response.contains("\"acceptance\":\"accepted\""));
}

#[test]
fn mutation_success_response_rejects_invalid_acceptance_family() {
    let error = mutation_success_response(json!({
        "acceptance": "completed",
        "target": {
            "vocabularyExpression": "vocabulary:coffee"
        },
        "state": {
            "registration": "registered",
            "explanation": "queued"
        },
        "statusHandle": "status:actor:learner:vocabulary:coffee",
        "message": "invalid",
        "replayedByIdempotency": false
    }))
    .expect_err("invalid acceptance should fail");

    assert_eq!(error.envelope.code, "downstream-invalid-response");
}

#[test]
fn catalog_success_response_wraps_catalog_payload_under_graphql_data() {
    let response = catalog_success_response(json!({
        "collectionState": "populated",
        "projectionFreshness": "eventual",
        "items": [
            {
                "vocabularyExpression": "vocabulary:coffee",
                "registrationState": "registered",
                "explanationState": "completed",
                "visibility": "completed-summary",
                "completedSummary": {
                    "headline": "done"
                }
            }
        ]
    }))
    .expect("catalog payload should wrap");

    assert!(response.contains("\"vocabularyCatalog\""));
    assert!(response.contains("\"collectionState\":\"populated\""));
}

#[test]
fn catalog_success_response_rejects_invalid_visibility() {
    let error = catalog_success_response(json!({
        "collectionState": "populated",
        "items": [
            {
                "vocabularyExpression": "vocabulary:coffee",
                "registrationState": "registered",
                "explanationState": "completed",
                "visibility": "detail"
            }
        ]
    }))
    .expect_err("invalid visibility should fail");

    assert_eq!(error.envelope.code, "downstream-invalid-response");
}

#[test]
fn mutation_success_response_rejects_missing_target_identifier() {
    let error = mutation_success_response(json!({
        "acceptance": "accepted",
        "target": {},
        "state": {
            "registration": "registered",
            "explanation": "queued"
        },
        "statusHandle": "status:actor:learner:vocabulary:coffee",
        "message": "registerVocabularyExpression was accepted for asynchronous processing",
        "replayedByIdempotency": false
    }))
    .expect_err("missing target identifier should fail");

    assert_eq!(error.envelope.code, "downstream-invalid-response");
}

#[test]
fn catalog_success_response_rejects_detail_payload_leakage() {
    let error = catalog_success_response(json!({
        "collectionState": "populated",
        "items": [
            {
                "vocabularyExpression": "vocabulary:coffee",
                "registrationState": "registered",
                "explanationState": "completed",
                "visibility": "completed-summary",
                "detailPayload": {
                    "headline": "should not leak"
                }
            }
        ]
    }))
    .expect_err("detail payload should not be exposed");

    assert_eq!(error.envelope.code, "downstream-invalid-response");
}

#[test]
fn catalog_success_response_rejects_invalid_collection_state() {
    let error = catalog_success_response(json!({
        "collectionState": "loading",
        "items": []
    }))
    .expect_err("unsupported collection state should fail");

    assert_eq!(error.envelope.code, "downstream-invalid-response");
}

#[test]
fn mutation_success_response_rejects_non_boolean_replayed_flag() {
    let error = mutation_success_response(json!({
        "acceptance": "accepted",
        "target": {
            "vocabularyExpression": "vocabulary:coffee"
        },
        "state": {
            "registration": "registered",
            "explanation": "queued"
        },
        "statusHandle": "status:actor:learner:vocabulary:coffee",
        "message": "registerVocabularyExpression was accepted for asynchronous processing",
        "replayedByIdempotency": "false"
    }))
    .expect_err("replayed flag must be boolean");

    assert_eq!(error.envelope.code, "downstream-invalid-response");
}

#[test]
fn catalog_success_response_rejects_missing_items_array() {
    let error = catalog_success_response(json!({
        "collectionState": "empty"
    }))
    .expect_err("items array is required");

    assert_eq!(error.envelope.code, "downstream-invalid-response");
}

#[test]
fn catalog_success_response_rejects_non_object_item() {
    let error = catalog_success_response(json!({
        "collectionState": "populated",
        "items": ["not-object"]
    }))
    .expect_err("items must be objects");

    assert_eq!(error.envelope.code, "downstream-invalid-response");
}

#[test]
fn mutation_success_response_rejects_missing_message() {
    let error = mutation_success_response(json!({
        "acceptance": "accepted",
        "target": {
            "vocabularyExpression": "vocabulary:coffee"
        },
        "state": {
            "registration": "registered",
            "explanation": "queued"
        },
        "statusHandle": "status:actor:learner:vocabulary:coffee",
        "replayedByIdempotency": false
    }))
    .expect_err("message is required");

    assert_eq!(error.envelope.code, "downstream-invalid-response");
}

#[test]
fn catalog_success_response_rejects_missing_visibility() {
    let error = catalog_success_response(json!({
        "collectionState": "populated",
        "items": [
            {
                "vocabularyExpression": "vocabulary:coffee",
                "registrationState": "registered",
                "explanationState": "completed"
            }
        ]
    }))
    .expect_err("visibility is required");

    assert_eq!(error.envelope.code, "downstream-invalid-response");
}
