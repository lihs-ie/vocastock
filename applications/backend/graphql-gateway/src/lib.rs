pub const SERVICE_NAME: &str = "graphql-gateway";
pub const COMMAND_UPSTREAM: &str = "command-api";
pub const QUERY_UPSTREAM: &str = "query-api";

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum GraphqlOperationKind {
    Mutation,
    Query,
    Subscription,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct GatewayRoute {
    pub operation_kind: GraphqlOperationKind,
    pub upstream_service: &'static str,
}

pub fn route_document(document: &str) -> GatewayRoute {
    let operation_kind = classify_operation(document);
    let upstream_service = match operation_kind {
        GraphqlOperationKind::Mutation => COMMAND_UPSTREAM,
        GraphqlOperationKind::Query | GraphqlOperationKind::Subscription => QUERY_UPSTREAM,
    };

    GatewayRoute {
        operation_kind,
        upstream_service,
    }
}

fn classify_operation(document: &str) -> GraphqlOperationKind {
    let first_token = document
        .lines()
        .map(str::trim)
        .find(|line| !line.is_empty() && !line.starts_with('#'))
        .unwrap_or_default();

    if first_token.starts_with("mutation") {
        GraphqlOperationKind::Mutation
    } else if first_token.starts_with("subscription") {
        GraphqlOperationKind::Subscription
    } else {
        GraphqlOperationKind::Query
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn mutation_routes_to_command_api() {
        let route = route_document(
            "mutation RegisterVocabularyExpression { registerVocabularyExpression }",
        );

        assert_eq!(route.operation_kind, GraphqlOperationKind::Mutation);
        assert_eq!(route.upstream_service, COMMAND_UPSTREAM);
    }

    #[test]
    fn query_defaults_to_query_api() {
        let route = route_document("{ vocabularyCatalog }");

        assert_eq!(route.operation_kind, GraphqlOperationKind::Query);
        assert_eq!(route.upstream_service, QUERY_UPSTREAM);
    }
}
