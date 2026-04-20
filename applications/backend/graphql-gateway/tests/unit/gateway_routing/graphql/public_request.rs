use graphql_gateway::graphql::UnifiedGraphqlRequestEnvelope;

#[test]
fn parse_public_request_accepts_query_with_object_variables() {
    let envelope = UnifiedGraphqlRequestEnvelope::parse(
        r#"{"query":"query VocabularyCatalog { vocabularyCatalog { collectionState } }","variables":{"actor":"actor:learner"}}"#,
    )
    .expect("request should parse");

    assert_eq!(
        envelope.query,
        "query VocabularyCatalog { vocabularyCatalog { collectionState } }"
    );
    assert_eq!(
        envelope
            .variables_object()
            .and_then(|variables| variables.get("actor"))
            .and_then(serde_json::Value::as_str),
        Some("actor:learner")
    );
}

#[test]
fn parse_public_request_rejects_empty_query() {
    let error =
        UnifiedGraphqlRequestEnvelope::parse(r#"{"query":"   ","variables":{"actor":"x"}}"#)
            .expect_err("empty query should be rejected");

    assert_eq!(error.envelope.code, "validation-failed");
    assert!(error.envelope.message.contains("query must not be empty"));
}

#[test]
fn parse_public_request_rejects_non_object_variables() {
    let error = UnifiedGraphqlRequestEnvelope::parse(
        r#"{"query":"query VocabularyCatalog { vocabularyCatalog { collectionState } }","variables":["not","object"]}"#,
    )
    .expect_err("non-object variables should be rejected");

    assert_eq!(error.envelope.code, "validation-failed");
    assert!(error
        .envelope
        .message
        .contains("variables must be a JSON object"));
}

#[test]
fn parse_public_request_rejects_invalid_json_body() {
    let error = UnifiedGraphqlRequestEnvelope::parse(r#"{"query":"query VocabularyCatalog { }""#)
        .expect_err("invalid json should fail");

    assert_eq!(error.envelope.code, "validation-failed");
    assert!(error
        .envelope
        .message
        .contains("request body must be valid JSON"));
}
