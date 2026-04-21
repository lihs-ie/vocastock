use command_api::{
    REGISTER_VOCABULARY_EXPRESSION_PATH, REQUEST_EXPLANATION_GENERATION_PATH,
    REQUEST_IMAGE_GENERATION_PATH, REQUEST_PURCHASE_PATH, REQUEST_RESTORE_PURCHASE_PATH,
    RETRY_GENERATION_PATH, SERVICE_NAME as COMMAND_API_SERVICE_NAME,
};
use query_api::{
    ACTOR_HANDOFF_STATUS_PATH, EXPLANATION_DETAIL_PATH, IMAGE_DETAIL_PATH, LEARNING_STATE_PATH,
    SERVICE_NAME as QUERY_API_SERVICE_NAME, SUBSCRIPTION_STATUS_PATH, VOCABULARY_CATALOG_PATH,
    VOCABULARY_EXPRESSION_DETAIL_PATH,
};

use super::{failure_envelope::GatewayFailure, public_request::UnifiedGraphqlRequestEnvelope};

pub const REGISTER_VOCABULARY_EXPRESSION_OPERATION: &str = "registerVocabularyExpression";
pub const VOCABULARY_CATALOG_OPERATION: &str = "vocabularyCatalog";
pub const VOCABULARY_EXPRESSION_DETAIL_OPERATION: &str = "vocabularyExpressionDetail";
pub const EXPLANATION_DETAIL_OPERATION: &str = "explanationDetail";
pub const IMAGE_DETAIL_OPERATION: &str = "imageDetail";
pub const SUBSCRIPTION_STATUS_OPERATION: &str = "subscriptionStatus";
pub const ACTOR_HANDOFF_STATUS_OPERATION: &str = "actorHandoffStatus";
pub const LEARNING_STATE_OPERATION: &str = "learningState";
pub const REQUEST_EXPLANATION_GENERATION_OPERATION: &str = "requestExplanationGeneration";
pub const REQUEST_IMAGE_GENERATION_OPERATION: &str = "requestImageGeneration";
pub const RETRY_GENERATION_OPERATION: &str = "retryGeneration";
pub const REQUEST_PURCHASE_OPERATION: &str = "requestPurchase";
pub const REQUEST_RESTORE_PURCHASE_OPERATION: &str = "requestRestorePurchase";

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum GraphqlOperationKind {
    Mutation,
    Query,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum VisibleGuarantee {
    AcceptedOnly,
    CompletedOrStatusOnly,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct GatewayRoutingDecision {
    pub operation_kind: GraphqlOperationKind,
    pub operation_name: String,
    pub downstream_service: &'static str,
    pub downstream_route: &'static str,
    pub visible_guarantee: VisibleGuarantee,
}

#[derive(Clone, Debug, Eq, PartialEq)]
struct ParsedOperation {
    operation_kind: GraphqlOperationKind,
    operation_name: Option<String>,
    root_fields: Vec<String>,
}

pub fn allowlisted_operation(
    envelope: &UnifiedGraphqlRequestEnvelope,
) -> Result<GatewayRoutingDecision, GatewayFailure> {
    let parsed = parse_single_operation(envelope.query.as_str())?;

    if let Some(request_operation_name) = envelope.operation_name.as_deref() {
        match parsed.operation_name.as_deref() {
            Some(document_operation_name) if document_operation_name == request_operation_name => {}
            _ => return Err(GatewayFailure::ambiguous_operation()),
        }
    }

    if parsed.root_fields.len() != 1 {
        return Err(GatewayFailure::ambiguous_operation());
    }

    match (parsed.operation_kind, parsed.root_fields[0].as_str()) {
        (GraphqlOperationKind::Mutation, REGISTER_VOCABULARY_EXPRESSION_OPERATION) => {
            Ok(command_mutation(
                REGISTER_VOCABULARY_EXPRESSION_OPERATION,
                REGISTER_VOCABULARY_EXPRESSION_PATH,
            ))
        }
        (GraphqlOperationKind::Mutation, REQUEST_EXPLANATION_GENERATION_OPERATION) => {
            Ok(command_mutation(
                REQUEST_EXPLANATION_GENERATION_OPERATION,
                REQUEST_EXPLANATION_GENERATION_PATH,
            ))
        }
        (GraphqlOperationKind::Mutation, REQUEST_IMAGE_GENERATION_OPERATION) => {
            Ok(command_mutation(
                REQUEST_IMAGE_GENERATION_OPERATION,
                REQUEST_IMAGE_GENERATION_PATH,
            ))
        }
        (GraphqlOperationKind::Mutation, RETRY_GENERATION_OPERATION) => Ok(command_mutation(
            RETRY_GENERATION_OPERATION,
            RETRY_GENERATION_PATH,
        )),
        (GraphqlOperationKind::Mutation, REQUEST_PURCHASE_OPERATION) => Ok(command_mutation(
            REQUEST_PURCHASE_OPERATION,
            REQUEST_PURCHASE_PATH,
        )),
        (GraphqlOperationKind::Mutation, REQUEST_RESTORE_PURCHASE_OPERATION) => {
            Ok(command_mutation(
                REQUEST_RESTORE_PURCHASE_OPERATION,
                REQUEST_RESTORE_PURCHASE_PATH,
            ))
        }
        (GraphqlOperationKind::Query, VOCABULARY_CATALOG_OPERATION) => {
            Ok(query(VOCABULARY_CATALOG_OPERATION, VOCABULARY_CATALOG_PATH))
        }
        (GraphqlOperationKind::Query, VOCABULARY_EXPRESSION_DETAIL_OPERATION) => Ok(query(
            VOCABULARY_EXPRESSION_DETAIL_OPERATION,
            VOCABULARY_EXPRESSION_DETAIL_PATH,
        )),
        (GraphqlOperationKind::Query, EXPLANATION_DETAIL_OPERATION) => {
            Ok(query(EXPLANATION_DETAIL_OPERATION, EXPLANATION_DETAIL_PATH))
        }
        (GraphqlOperationKind::Query, IMAGE_DETAIL_OPERATION) => {
            Ok(query(IMAGE_DETAIL_OPERATION, IMAGE_DETAIL_PATH))
        }
        (GraphqlOperationKind::Query, SUBSCRIPTION_STATUS_OPERATION) => Ok(query(
            SUBSCRIPTION_STATUS_OPERATION,
            SUBSCRIPTION_STATUS_PATH,
        )),
        (GraphqlOperationKind::Query, ACTOR_HANDOFF_STATUS_OPERATION) => Ok(query(
            ACTOR_HANDOFF_STATUS_OPERATION,
            ACTOR_HANDOFF_STATUS_PATH,
        )),
        (GraphqlOperationKind::Query, LEARNING_STATE_OPERATION) => {
            Ok(query(LEARNING_STATE_OPERATION, LEARNING_STATE_PATH))
        }
        _ => Err(GatewayFailure::unsupported_operation()),
    }
}

fn command_mutation(
    operation_name: &'static str,
    downstream_route: &'static str,
) -> GatewayRoutingDecision {
    GatewayRoutingDecision {
        operation_kind: GraphqlOperationKind::Mutation,
        operation_name: operation_name.to_owned(),
        downstream_service: COMMAND_API_SERVICE_NAME,
        downstream_route,
        visible_guarantee: VisibleGuarantee::AcceptedOnly,
    }
}

fn query(operation_name: &'static str, downstream_route: &'static str) -> GatewayRoutingDecision {
    GatewayRoutingDecision {
        operation_kind: GraphqlOperationKind::Query,
        operation_name: operation_name.to_owned(),
        downstream_service: QUERY_API_SERVICE_NAME,
        downstream_route,
        visible_guarantee: VisibleGuarantee::CompletedOrStatusOnly,
    }
}

fn parse_single_operation(document: &str) -> Result<ParsedOperation, GatewayFailure> {
    let trimmed_index = skip_ignored(document, 0);
    let bytes = document.as_bytes();
    if trimmed_index >= bytes.len() {
        return Err(GatewayFailure::validation_failed("query must not be empty"));
    }

    let (operation_kind, operation_name, selection_start, selection_end) =
        if matches_keyword(document, trimmed_index, "mutation") {
            parse_explicit_operation(
                document,
                trimmed_index + "mutation".len(),
                GraphqlOperationKind::Mutation,
            )?
        } else if matches_keyword(document, trimmed_index, "query") {
            parse_explicit_operation(
                document,
                trimmed_index + "query".len(),
                GraphqlOperationKind::Query,
            )?
        } else if bytes[trimmed_index] == b'{' {
            let selection_end = skip_group(document, trimmed_index, b'{', b'}')?;
            let trailing = skip_ignored(document, selection_end);
            if trailing != bytes.len() {
                return Err(GatewayFailure::ambiguous_operation());
            }
            (
                GraphqlOperationKind::Query,
                None,
                trimmed_index,
                selection_end,
            )
        } else {
            return Err(GatewayFailure::unsupported_operation());
        };

    let root_fields = extract_root_fields(&document[selection_start..selection_end])?;

    Ok(ParsedOperation {
        operation_kind,
        operation_name,
        root_fields,
    })
}

fn parse_explicit_operation(
    document: &str,
    mut index: usize,
    operation_kind: GraphqlOperationKind,
) -> Result<(GraphqlOperationKind, Option<String>, usize, usize), GatewayFailure> {
    index = skip_ignored(document, index);

    let (operation_name, next_index) =
        if let Some((identifier, next_index)) = parse_identifier(document, index) {
            (Some(identifier), next_index)
        } else {
            (None, index)
        };

    index = skip_ignored(document, next_index);
    if document.as_bytes().get(index) == Some(&b'(') {
        index = skip_group(document, index, b'(', b')')?;
        index = skip_ignored(document, index);
    }

    if document.as_bytes().get(index) != Some(&b'{') {
        return Err(GatewayFailure::validation_failed(
            "GraphQL operation must contain a selection set",
        ));
    }

    let selection_start = index;
    let selection_end = skip_group(document, selection_start, b'{', b'}')?;
    let trailing = skip_ignored(document, selection_end);
    if trailing != document.len() {
        return Err(GatewayFailure::ambiguous_operation());
    }

    Ok((
        operation_kind,
        operation_name,
        selection_start,
        selection_end,
    ))
}

fn extract_root_fields(selection: &str) -> Result<Vec<String>, GatewayFailure> {
    let bytes = selection.as_bytes();
    let mut index = 0;
    let mut depth = 0usize;
    let mut fields = Vec::new();

    while index < bytes.len() {
        match bytes[index] {
            b'"' => index = skip_string(selection, index)?,
            b'#' => index = skip_comment(selection, index),
            b'{' => {
                depth += 1;
                index += 1;
            }
            b'}' => {
                if depth == 0 {
                    return Err(GatewayFailure::validation_failed(
                        "selection set closed unexpectedly",
                    ));
                }
                depth -= 1;
                index += 1;
            }
            b'(' if depth >= 1 => index = skip_group(selection, index, b'(', b')')?,
            byte if depth == 1 && (byte.is_ascii_whitespace() || byte == b',') => index += 1,
            byte if depth == 1 && is_identifier_start(byte) => {
                let (token, mut next_index) = parse_identifier(selection, index)
                    .ok_or_else(|| GatewayFailure::validation_failed("field name is required"))?;
                next_index = skip_ignored(selection, next_index);
                let field_name = if selection.as_bytes().get(next_index) == Some(&b':') {
                    next_index += 1;
                    next_index = skip_ignored(selection, next_index);
                    let (aliased_field, alias_end) = parse_identifier(selection, next_index)
                        .ok_or_else(|| {
                            GatewayFailure::validation_failed("field alias is invalid")
                        })?;
                    next_index = alias_end;
                    aliased_field
                } else {
                    token
                };
                fields.push(field_name);
                index = next_index;
            }
            _ => index += 1,
        }
    }

    if fields.is_empty() {
        return Err(GatewayFailure::unsupported_operation());
    }

    Ok(fields)
}

fn matches_keyword(document: &str, index: usize, keyword: &str) -> bool {
    let bytes = document.as_bytes();
    let keyword_bytes = keyword.as_bytes();
    if bytes.len() < index + keyword_bytes.len() {
        return false;
    }

    if &bytes[index..index + keyword_bytes.len()] != keyword_bytes {
        return false;
    }

    bytes
        .get(index + keyword_bytes.len())
        .map(|byte| !is_identifier_part(*byte))
        .unwrap_or(true)
}

fn parse_identifier(document: &str, index: usize) -> Option<(String, usize)> {
    let bytes = document.as_bytes();
    if !is_identifier_start(*bytes.get(index)?) {
        return None;
    }

    let mut end = index + 1;
    while end < bytes.len() && is_identifier_part(bytes[end]) {
        end += 1;
    }

    Some((document[index..end].to_owned(), end))
}

fn skip_comment(document: &str, mut index: usize) -> usize {
    let bytes = document.as_bytes();
    while index < bytes.len() && bytes[index] != b'\n' {
        index += 1;
    }
    index
}

fn skip_string(document: &str, mut index: usize) -> Result<usize, GatewayFailure> {
    let bytes = document.as_bytes();
    index += 1;

    while index < bytes.len() {
        match bytes[index] {
            b'\\' => index += 2,
            b'"' => return Ok(index + 1),
            _ => index += 1,
        }
    }

    Err(GatewayFailure::validation_failed(
        "string literal must be terminated",
    ))
}

fn skip_group(
    document: &str,
    mut index: usize,
    open: u8,
    close: u8,
) -> Result<usize, GatewayFailure> {
    let bytes = document.as_bytes();
    let mut depth = 0usize;

    while index < bytes.len() {
        match bytes[index] {
            b'"' => index = skip_string(document, index)?,
            byte if byte == open => {
                depth += 1;
                index += 1;
            }
            byte if byte == close => {
                depth = depth.saturating_sub(1);
                index += 1;
                if depth == 0 {
                    return Ok(index);
                }
            }
            b'#' => index = skip_comment(document, index),
            _ => index += 1,
        }
    }

    Err(GatewayFailure::validation_failed(
        "GraphQL document contains an unterminated group",
    ))
}

fn skip_ignored(document: &str, mut index: usize) -> usize {
    let bytes = document.as_bytes();

    while index < bytes.len() {
        match bytes[index] {
            byte if byte.is_ascii_whitespace() || byte == b',' => index += 1,
            b'#' => index = skip_comment(document, index),
            _ => break,
        }
    }

    index
}

fn is_identifier_start(byte: u8) -> bool {
    byte.is_ascii_alphabetic() || byte == b'_'
}

fn is_identifier_part(byte: u8) -> bool {
    is_identifier_start(byte) || byte.is_ascii_digit()
}
