use serde_json::{json, Value};

use crate::support::{
    assert_contains, assert_not_contains, unused_host_base_url, FeatureRuntime,
    FeatureRuntimeOptions, StubResponse, StubServer,
};

#[test]
fn public_graphql_gateway_relays_allowlisted_operations_against_dockerized_services() {
    let runtime = FeatureRuntime::start();

    let root = runtime.get("/");
    assert_eq!(root.status, 200);
    assert_contains(&root.body, "/graphql", "root response");

    let dependency = runtime.get("/dependencies/firebase");
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

    let accepted = runtime.post_json(
        "/graphql",
        Some("Bearer valid-demo-token"),
        Some("client-accepted"),
        &register_mutation_payload("feature-accepted", "  Mixed   Case  ", None),
    );
    assert_eq!(accepted.status, 200);
    assert_contains(
        &accepted.body,
        "\"registerVocabularyExpression\"",
        "accepted mutation response",
    );
    assert_contains(
        &accepted.body,
        "\"acceptance\":\"accepted\"",
        "accepted mutation response",
    );
    assert_contains(
        &accepted.body,
        "\"vocabularyExpression\":\"vocabulary:mixed-case\"",
        "accepted mutation response",
    );

    let replay = runtime.post_json(
        "/graphql",
        Some("Bearer valid-demo-token"),
        Some("client-accepted"),
        &register_mutation_payload("feature-accepted", "  Mixed   Case  ", None),
    );
    assert_eq!(replay.status, 200);
    assert_contains(
        &replay.body,
        "\"replayedByIdempotency\":true",
        "replay mutation response",
    );

    let reused = runtime.post_json(
        "/graphql",
        Some("Bearer valid-demo-token"),
        Some("client-reused"),
        &register_mutation_payload("feature-reuse", "mixed case", None),
    );
    assert_eq!(reused.status, 200);
    assert_contains(
        &reused.body,
        "\"acceptance\":\"reused-existing\"",
        "reused-existing mutation response",
    );

    let not_started = runtime.post_json(
        "/graphql",
        Some("Bearer valid-demo-token"),
        Some("client-not-started"),
        &register_mutation_payload("feature-no-dispatch", "silent term", Some(false)),
    );
    assert_eq!(not_started.status, 200);
    assert_contains(
        &not_started.body,
        "\"explanation\":\"not-started\"",
        "startExplanation=false response",
    );

    // Note: the legacy InMemoryDispatchPort recognised a magic
    // "rollback term" text to simulate a dispatch failure + subsequent
    // retry. The production PubSub adapter has no such hook, so the
    // dispatch_failed / accepted_after_failure scenarios that relied on
    // it are no longer reproducible through this E2E path. The
    // equivalent command-api error envelopes remain unit-tested against
    // the error-producing adapter substitutes in
    // `register_command_api/http/endpoint.rs` unit tests.

    let conflict_first = runtime.post_json(
        "/graphql",
        Some("Bearer valid-demo-token"),
        Some("client-conflict"),
        &register_mutation_payload("feature-conflict", "conflict one", None),
    );
    assert_eq!(conflict_first.status, 200);
    let conflict = runtime.post_json(
        "/graphql",
        Some("Bearer valid-demo-token"),
        Some("client-conflict"),
        &register_mutation_payload("feature-conflict", "conflict two", None),
    );
    assert_eq!(conflict.status, 409);
    assert_contains(
        &conflict.body,
        "\"code\":\"idempotency-conflict\"",
        "idempotency conflict response",
    );

    let catalog = runtime.post_json(
        "/graphql",
        Some("Bearer valid-demo-token"),
        Some("client-catalog"),
        &catalog_query_payload(),
    );
    assert_eq!(catalog.status, 200);
    assert_contains(&catalog.body, "\"vocabularyCatalog\"", "catalog response");
    assert_contains(
        &catalog.body,
        "\"visibility\":\"completed-summary\"",
        "catalog response",
    );
    assert_contains(
        &catalog.body,
        "\"visibility\":\"status-only\"",
        "catalog response",
    );
    assert_not_contains(&catalog.body, "detailPayload", "catalog response");

    let empty_catalog = runtime.post_json(
        "/graphql",
        Some("Bearer valid-free-token"),
        Some("client-empty-catalog"),
        &catalog_query_payload(),
    );
    assert_eq!(empty_catalog.status, 200);
    assert_contains(
        &empty_catalog.body,
        "\"collectionState\":\"empty\"",
        "empty catalog response",
    );

    let missing_auth = runtime.post_json(
        "/graphql",
        None,
        Some("client-missing-auth"),
        &catalog_query_payload(),
    );
    assert_eq!(missing_auth.status, 401);
    assert_contains(
        &missing_auth.body,
        "\"code\":\"downstream-auth-failed\"",
        "missing auth response",
    );
    assert_contains(
        &missing_auth.body,
        "missing bearer token",
        "missing auth response",
    );

    let reauth = runtime.post_json(
        "/graphql",
        Some("Bearer reauth-token"),
        Some("client-reauth"),
        &catalog_query_payload(),
    );
    assert_eq!(reauth.status, 403);
    assert_contains(
        &reauth.body,
        "\"code\":\"downstream-auth-failed\"",
        "reauth response",
    );
    assert_contains(&reauth.body, "reauthentication", "reauth response");

    let unsupported = runtime.post_json(
        "/graphql",
        Some("Bearer valid-demo-token"),
        Some("client-unsupported"),
        &unsupported_query_payload(),
    );
    assert_eq!(unsupported.status, 400);
    assert_contains(
        &unsupported.body,
        "\"code\":\"unsupported-operation\"",
        "unsupported operation response",
    );

    let ambiguous = runtime.post_json(
        "/graphql",
        Some("Bearer valid-demo-token"),
        Some("client-ambiguous"),
        &ambiguous_query_payload(),
    );
    assert_eq!(ambiguous.status, 400);
    assert_contains(
        &ambiguous.body,
        "\"code\":\"ambiguous-operation\"",
        "ambiguous operation response",
    );
}

#[test]
fn public_graphql_gateway_propagates_auth_and_request_correlation_to_stubbed_command_upstream() {
    {
        let stub = StubServer::start(StubResponse::json(
            202,
            stubbed_accepted_command_result("vocabulary:coffee"),
        ));
        let runtime = FeatureRuntime::start_with_options(FeatureRuntimeOptions {
            command_upstream_base_url: Some(stub.base_url()),
            query_upstream_base_url: None,
        });

        let response = runtime.post_json(
            "/graphql",
            Some("Bearer forwarded-token"),
            Some("client-correlation"),
            &register_mutation_payload("feature-forwarded", "coffee", Some(false)),
        );
        assert_eq!(response.status, 200);
        assert_contains(
            &response.body,
            "\"acceptance\":\"accepted\"",
            "stubbed command response",
        );

        drop(runtime);
        let captured = stub.capture();
        assert_eq!(
            captured.headers.get("authorization").map(String::as_str),
            Some("Bearer forwarded-token")
        );
        assert_eq!(
            captured
                .headers
                .get("x-request-correlation")
                .map(String::as_str),
            Some("client-correlation")
        );
        assert_contains(
            &captured.body,
            "\"command\":\"registerVocabularyExpression\"",
            "captured downstream body",
        );
        assert_contains(
            &captured.body,
            "\"startExplanation\":false",
            "captured downstream body",
        );
    }

    {
        let stub = StubServer::start(StubResponse::json(
            202,
            stubbed_accepted_command_result("vocabulary:tea"),
        ));
        let runtime = FeatureRuntime::start_with_options(FeatureRuntimeOptions {
            command_upstream_base_url: Some(stub.base_url()),
            query_upstream_base_url: None,
        });

        let response = runtime.post_json(
            "/graphql",
            Some("Bearer generated-correlation-token"),
            None,
            &register_mutation_payload("feature-generated", "tea", None),
        );
        assert_eq!(response.status, 200);

        drop(runtime);
        let captured = stub.capture();
        let generated = captured
            .headers
            .get("x-request-correlation")
            .expect("generated correlation header should exist");
        assert!(generated.starts_with("gateway-"));
    }
}

#[test]
fn public_graphql_gateway_shapes_downstream_unavailable_and_invalid_response_failures() {
    let invalid_stub = StubServer::start(StubResponse {
        status: 202,
        content_type: "application/json".to_owned(),
        body: "not-json".to_owned(),
    });
    let invalid_runtime = FeatureRuntime::start_with_options(FeatureRuntimeOptions {
        command_upstream_base_url: Some(invalid_stub.base_url()),
        query_upstream_base_url: None,
    });

    let invalid_response = invalid_runtime.post_json(
        "/graphql",
        Some("Bearer valid-demo-token"),
        Some("client-invalid-response"),
        &register_mutation_payload("feature-invalid", "coffee", None),
    );
    assert_eq!(invalid_response.status, 502);
    assert_contains(
        &invalid_response.body,
        "\"code\":\"downstream-invalid-response\"",
        "invalid response envelope",
    );
    assert_not_contains(
        &invalid_response.body,
        "http://host.docker.internal",
        "invalid response envelope",
    );
    drop(invalid_runtime);
    let _ = invalid_stub.capture();

    let unavailable_runtime = FeatureRuntime::start_with_options(FeatureRuntimeOptions {
        command_upstream_base_url: None,
        query_upstream_base_url: Some(unused_host_base_url()),
    });
    let unavailable = unavailable_runtime.post_json(
        "/graphql",
        Some("Bearer valid-demo-token"),
        Some("client-unavailable"),
        &catalog_query_payload(),
    );
    assert_eq!(unavailable.status, 503);
    assert_contains(
        &unavailable.body,
        "\"code\":\"downstream-unavailable\"",
        "downstream unavailable envelope",
    );
}

fn register_mutation_payload(
    idempotency_key: &str,
    text: &str,
    start_explanation: Option<bool>,
) -> Value {
    let mut variables = json!({
        "actor": "stub-actor-demo",
        "idempotencyKey": idempotency_key,
        "text": text
    });
    if let Some(start_explanation) = start_explanation {
        variables["startExplanation"] = Value::Bool(start_explanation);
    }

    json!({
        "query": "mutation RegisterVocabularyExpression($actor: String!, $idempotencyKey: String!, $text: String!, $startExplanation: Boolean) { registerVocabularyExpression(actor: $actor, idempotencyKey: $idempotencyKey, text: $text, startExplanation: $startExplanation) { acceptance target { vocabularyExpression } state { registration explanation } statusHandle message replayedByIdempotency duplicateReuse { registrationState explanationState restartDecision restartCondition } } }",
        "operationName": "RegisterVocabularyExpression",
        "variables": variables
    })
}

fn catalog_query_payload() -> Value {
    json!({
        "query": "query VocabularyCatalog { vocabularyCatalog { collectionState items { vocabularyExpression visibility } } }",
        "operationName": "VocabularyCatalog"
    })
}

fn unsupported_query_payload() -> Value {
    json!({
        "query": "query UnsupportedOperation { vocabularyDetail { identifier } }",
        "operationName": "UnsupportedOperation"
    })
}

fn ambiguous_query_payload() -> Value {
    json!({
        "query": "query VocabularyCatalog { vocabularyCatalog { collectionState } } query AnotherCatalog { vocabularyCatalog { collectionState } }"
    })
}

fn stubbed_accepted_command_result(vocabulary_expression: &str) -> Value {
    json!({
        "acceptance": "accepted",
        "target": {
            "vocabularyExpression": vocabulary_expression
        },
        "state": {
            "registration": "registered",
            "explanation": "queued"
        },
        "statusHandle": format!("status:stub-actor-demo:{vocabulary_expression}"),
        "message": "registerVocabularyExpression was accepted for asynchronous processing",
        "replayedByIdempotency": false
    })
}
