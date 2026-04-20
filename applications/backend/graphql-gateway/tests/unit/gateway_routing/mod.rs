use graphql_gateway::{route_document, GraphqlOperationKind, COMMAND_UPSTREAM, QUERY_UPSTREAM};

#[test]
fn mutation_routes_to_command_api() {
    let route =
        route_document("mutation RegisterVocabularyExpression { registerVocabularyExpression }");

    assert_eq!(route.operation_kind, GraphqlOperationKind::Mutation);
    assert_eq!(route.upstream_service, COMMAND_UPSTREAM);
}

#[test]
fn subscription_routes_to_query_api() {
    let route = route_document("subscription GenerationStatus { generationStatus }");

    assert_eq!(route.operation_kind, GraphqlOperationKind::Subscription);
    assert_eq!(route.upstream_service, QUERY_UPSTREAM);
}

#[test]
fn comments_and_blank_lines_still_route_query_documents() {
    let route =
        route_document("\n# app shell query\n\nquery VocabularyCatalog { vocabularyCatalog }");

    assert_eq!(route.operation_kind, GraphqlOperationKind::Query);
    assert_eq!(route.upstream_service, QUERY_UPSTREAM);
}
