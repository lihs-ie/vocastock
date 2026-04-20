use serde_json::{json, Map, Value};

use command_api::SERVICE_NAME as COMMAND_API_SERVICE_NAME;
use query_api::SERVICE_NAME as QUERY_API_SERVICE_NAME;

use super::{
    failure_envelope::GatewayFailure,
    operation_allowlist::REGISTER_VOCABULARY_EXPRESSION_OPERATION,
    operation_allowlist::VOCABULARY_CATALOG_OPERATION,
};

pub fn mutation_success_response(payload: Value) -> Result<String, GatewayFailure> {
    let payload_object = payload
        .as_object()
        .ok_or_else(|| GatewayFailure::downstream_invalid_response(COMMAND_API_SERVICE_NAME))?;

    require_string(payload_object, "acceptance", COMMAND_API_SERVICE_NAME)?;
    require_nested_string(
        payload_object,
        "target",
        "vocabularyExpression",
        COMMAND_API_SERVICE_NAME,
    )?;
    require_nested_string(
        payload_object,
        "state",
        "registration",
        COMMAND_API_SERVICE_NAME,
    )?;
    require_nested_string(
        payload_object,
        "state",
        "explanation",
        COMMAND_API_SERVICE_NAME,
    )?;
    require_string(payload_object, "statusHandle", COMMAND_API_SERVICE_NAME)?;
    require_string(payload_object, "message", COMMAND_API_SERVICE_NAME)?;
    require_bool(
        payload_object,
        "replayedByIdempotency",
        COMMAND_API_SERVICE_NAME,
    )?;

    let acceptance = payload_object
        .get("acceptance")
        .and_then(Value::as_str)
        .unwrap_or_default();
    if acceptance != "accepted" && acceptance != "reused-existing" {
        return Err(GatewayFailure::downstream_invalid_response(
            COMMAND_API_SERVICE_NAME,
        ));
    }

    Ok(wrap_data(REGISTER_VOCABULARY_EXPRESSION_OPERATION, payload))
}

pub fn catalog_success_response(payload: Value) -> Result<String, GatewayFailure> {
    let payload_object = payload
        .as_object()
        .ok_or_else(|| GatewayFailure::downstream_invalid_response(QUERY_API_SERVICE_NAME))?;

    require_string(payload_object, "collectionState", QUERY_API_SERVICE_NAME)?;
    require_array(payload_object, "items", QUERY_API_SERVICE_NAME)?;

    let collection_state = payload_object
        .get("collectionState")
        .and_then(Value::as_str)
        .unwrap_or_default();
    if collection_state != "empty" && collection_state != "populated" {
        return Err(GatewayFailure::downstream_invalid_response(
            QUERY_API_SERVICE_NAME,
        ));
    }

    let items = payload_object
        .get("items")
        .and_then(Value::as_array)
        .ok_or_else(|| GatewayFailure::downstream_invalid_response(QUERY_API_SERVICE_NAME))?;
    for item in items {
        let item_object = item
            .as_object()
            .ok_or_else(|| GatewayFailure::downstream_invalid_response(QUERY_API_SERVICE_NAME))?;
        require_string(item_object, "vocabularyExpression", QUERY_API_SERVICE_NAME)?;
        require_string(item_object, "registrationState", QUERY_API_SERVICE_NAME)?;
        require_string(item_object, "explanationState", QUERY_API_SERVICE_NAME)?;
        require_string(item_object, "visibility", QUERY_API_SERVICE_NAME)?;
        if item_object.contains_key("detailPayload") {
            return Err(GatewayFailure::downstream_invalid_response(
                QUERY_API_SERVICE_NAME,
            ));
        }
        let visibility = item_object
            .get("visibility")
            .and_then(Value::as_str)
            .unwrap_or_default();
        if visibility != "completed-summary" && visibility != "status-only" {
            return Err(GatewayFailure::downstream_invalid_response(
                QUERY_API_SERVICE_NAME,
            ));
        }
    }

    Ok(wrap_data(VOCABULARY_CATALOG_OPERATION, payload))
}

fn wrap_data(operation_name: &str, payload: Value) -> String {
    let mut data = Map::new();
    data.insert(operation_name.to_owned(), payload);

    json!({
        "data": data
    })
    .to_string()
}

fn require_string(
    payload_object: &Map<String, Value>,
    key: &str,
    service_name: &str,
) -> Result<(), GatewayFailure> {
    if payload_object.get(key).and_then(Value::as_str).is_some() {
        Ok(())
    } else {
        Err(GatewayFailure::downstream_invalid_response(service_name))
    }
}

fn require_bool(
    payload_object: &Map<String, Value>,
    key: &str,
    service_name: &str,
) -> Result<(), GatewayFailure> {
    if payload_object.get(key).and_then(Value::as_bool).is_some() {
        Ok(())
    } else {
        Err(GatewayFailure::downstream_invalid_response(service_name))
    }
}

fn require_array(
    payload_object: &Map<String, Value>,
    key: &str,
    service_name: &str,
) -> Result<(), GatewayFailure> {
    if payload_object.get(key).and_then(Value::as_array).is_some() {
        Ok(())
    } else {
        Err(GatewayFailure::downstream_invalid_response(service_name))
    }
}

fn require_nested_string(
    payload_object: &Map<String, Value>,
    parent_key: &str,
    child_key: &str,
    service_name: &str,
) -> Result<(), GatewayFailure> {
    if payload_object
        .get(parent_key)
        .and_then(Value::as_object)
        .and_then(|nested| nested.get(child_key))
        .and_then(Value::as_str)
        .is_some()
    {
        Ok(())
    } else {
        Err(GatewayFailure::downstream_invalid_response(service_name))
    }
}
