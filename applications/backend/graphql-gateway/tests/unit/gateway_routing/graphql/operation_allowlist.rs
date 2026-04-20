use graphql_gateway::graphql::{
    allowlisted_operation, GraphqlOperationKind, UnifiedGraphqlRequestEnvelope, VisibleGuarantee,
};

#[test]
fn allowlisted_operation_routes_register_mutation_to_command_api() {
    let envelope = UnifiedGraphqlRequestEnvelope::parse(
        r#"{"query":"mutation RegisterVocabularyExpression($actor: String!, $idempotencyKey: String!, $text: String!) { registerVocabularyExpression(actor: $actor, idempotencyKey: $idempotencyKey, text: $text) { acceptance } }","operationName":"RegisterVocabularyExpression","variables":{"actor":"actor:learner","idempotencyKey":"key","text":"coffee"}}"#,
    )
    .expect("request should parse");

    let decision = allowlisted_operation(&envelope).expect("allowlisted mutation should route");

    assert_eq!(decision.operation_kind, GraphqlOperationKind::Mutation);
    assert_eq!(decision.downstream_service, "command-api");
    assert_eq!(
        decision.downstream_route,
        "/commands/register-vocabulary-expression"
    );
    assert_eq!(decision.visible_guarantee, VisibleGuarantee::AcceptedOnly);
}

#[test]
fn allowlisted_operation_routes_catalog_query_to_query_api() {
    let envelope = UnifiedGraphqlRequestEnvelope::parse(
        r#"{"query":"query VocabularyCatalog { vocabularyCatalog { collectionState } }","operationName":"VocabularyCatalog"}"#,
    )
    .expect("request should parse");

    let decision = allowlisted_operation(&envelope).expect("catalog query should route");

    assert_eq!(decision.operation_kind, GraphqlOperationKind::Query);
    assert_eq!(decision.downstream_service, "query-api");
    assert_eq!(decision.downstream_route, "/vocabulary-catalog");
    assert_eq!(
        decision.visible_guarantee,
        VisibleGuarantee::CompletedOrStatusOnly
    );
}

#[test]
fn allowlisted_operation_rejects_unsupported_root_field() {
    let envelope = UnifiedGraphqlRequestEnvelope::parse(
        r#"{"query":"query UnsupportedOperation { vocabularyDetail { identifier } }","operationName":"UnsupportedOperation"}"#,
    )
    .expect("request should parse");

    let error = allowlisted_operation(&envelope).expect_err("unsupported field should fail");

    assert_eq!(error.envelope.code, "unsupported-operation");
}

#[test]
fn allowlisted_operation_rejects_ambiguous_multi_operation_document() {
    let envelope = UnifiedGraphqlRequestEnvelope::parse(
        r#"{"query":"query VocabularyCatalog { vocabularyCatalog { collectionState } } query AnotherCatalog { vocabularyCatalog { collectionState } }"}"#,
    )
    .expect("request should parse");

    let error = allowlisted_operation(&envelope).expect_err("multi-operation document should fail");

    assert_eq!(error.envelope.code, "ambiguous-operation");
}

#[test]
fn allowlisted_operation_rejects_operation_name_mismatch() {
    let envelope = UnifiedGraphqlRequestEnvelope::parse(
        r#"{"query":"query VocabularyCatalog { vocabularyCatalog { collectionState } }","operationName":"DifferentName"}"#,
    )
    .expect("request should parse");

    let error = allowlisted_operation(&envelope).expect_err("operationName mismatch should fail");

    assert_eq!(error.envelope.code, "ambiguous-operation");
}

#[test]
fn allowlisted_operation_routes_shorthand_query_with_alias() {
    let envelope = UnifiedGraphqlRequestEnvelope::parse(
        r#"{"query":"{ catalog: vocabularyCatalog { collectionState } }"}"#,
    )
    .expect("request should parse");

    let decision = allowlisted_operation(&envelope).expect("aliased shorthand query should route");

    assert_eq!(decision.operation_kind, GraphqlOperationKind::Query);
    assert_eq!(decision.operation_name, "vocabularyCatalog");
    assert_eq!(decision.downstream_service, "query-api");
}

#[test]
fn allowlisted_operation_rejects_register_field_when_declared_as_query() {
    let envelope = UnifiedGraphqlRequestEnvelope::parse(
        r#"{"query":"query RegisterVocabularyExpression { registerVocabularyExpression { acceptance } }","operationName":"RegisterVocabularyExpression"}"#,
    )
    .expect("request should parse");

    let error =
        allowlisted_operation(&envelope).expect_err("mutation field under query should fail");

    assert_eq!(error.envelope.code, "unsupported-operation");
}

#[test]
fn allowlisted_operation_rejects_missing_selection_set() {
    let envelope = UnifiedGraphqlRequestEnvelope::parse(
        r#"{"query":"mutation RegisterVocabularyExpression($actor: String!)","operationName":"RegisterVocabularyExpression"}"#,
    )
    .expect("request should parse");

    let error = allowlisted_operation(&envelope).expect_err("selection set is required");

    assert_eq!(error.envelope.code, "validation-failed");
}

#[test]
fn allowlisted_operation_accepts_document_with_leading_comment() {
    let envelope = UnifiedGraphqlRequestEnvelope::parse(
        "{\n  \"query\":\"# lead comment\\nquery VocabularyCatalog { vocabularyCatalog { collectionState } }\",\n  \"operationName\":\"VocabularyCatalog\"\n}",
    )
    .expect("request should parse");

    let decision = allowlisted_operation(&envelope).expect("commented query should route");

    assert_eq!(decision.operation_kind, GraphqlOperationKind::Query);
    assert_eq!(decision.operation_name, "vocabularyCatalog");
}

#[test]
fn allowlisted_operation_accepts_mutation_with_string_arguments() {
    let envelope = UnifiedGraphqlRequestEnvelope::parse(
        r#"{"query":"mutation RegisterVocabularyExpression { registerVocabularyExpression(text: \"cof\\\"fee\") { acceptance } }","operationName":"RegisterVocabularyExpression"}"#,
    )
    .expect("request should parse");

    let decision =
        allowlisted_operation(&envelope).expect("string arguments should be skipped safely");

    assert_eq!(decision.operation_kind, GraphqlOperationKind::Mutation);
    assert_eq!(decision.operation_name, "registerVocabularyExpression");
}

#[test]
fn allowlisted_operation_rejects_fragment_documents() {
    let envelope = UnifiedGraphqlRequestEnvelope::parse(
        r#"{"query":"fragment CatalogFields on Query { vocabularyCatalog { collectionState } }"}"#,
    )
    .expect("request should parse");

    let error = allowlisted_operation(&envelope).expect_err("fragment document should fail");

    assert_eq!(error.envelope.code, "unsupported-operation");
}

#[test]
fn allowlisted_operation_rejects_empty_selection_set() {
    let envelope =
        UnifiedGraphqlRequestEnvelope::parse(r#"{"query":"{ }"}"#).expect("request should parse");

    let error = allowlisted_operation(&envelope).expect_err("empty selection set should fail");

    assert_eq!(error.envelope.code, "unsupported-operation");
}

#[test]
fn allowlisted_operation_rejects_invalid_alias_syntax() {
    let envelope = UnifiedGraphqlRequestEnvelope::parse(r#"{"query":"{ alias: }"}"#)
        .expect("request should parse");

    let error = allowlisted_operation(&envelope).expect_err("invalid alias should fail");

    assert_eq!(error.envelope.code, "validation-failed");
}
