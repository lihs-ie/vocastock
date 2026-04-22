use query_api::subscription_status::parse_subscription_document;
use serde_json::json;

#[test]
fn parses_subscription_document_with_integer_string_allowance() {
    let payload = json!({
        "fields": {
            "state": {"stringValue": "active"},
            "plan": {"stringValue": "standardMonthly"},
            "entitlement": {"stringValue": "premiumGeneration"},
            "allowance": {
                "mapValue": {
                    "fields": {
                        "remainingExplanationGenerations": {"integerValue": "82"},
                        "remainingImageGenerations": {"integerValue": "27"}
                    }
                }
            }
        }
    });
    let record = parse_subscription_document(&payload).expect("document parses");
    assert_eq!(record.state, "active");
    assert_eq!(record.plan, "standardMonthly");
    assert_eq!(record.entitlement, "premiumGeneration");
    assert_eq!(record.allowance.remaining_explanation_generations, 82);
    assert_eq!(record.allowance.remaining_image_generations, 27);
}

#[test]
fn defaults_allowance_counters_when_absent() {
    let payload = json!({
        "fields": {
            "state": {"stringValue": "pendingSync"},
            "plan": {"stringValue": "free"},
            "entitlement": {"stringValue": "freeBasic"},
            "allowance": {
                "mapValue": {
                    "fields": {}
                }
            }
        }
    });
    let record = parse_subscription_document(&payload).expect("document parses");
    assert_eq!(record.allowance.remaining_explanation_generations, 0);
    assert_eq!(record.allowance.remaining_image_generations, 0);
}

#[test]
fn returns_none_when_allowance_map_is_absent() {
    let payload = json!({
        "fields": {
            "state": {"stringValue": "active"},
            "plan": {"stringValue": "standardMonthly"},
            "entitlement": {"stringValue": "premiumGeneration"}
        }
    });
    assert!(parse_subscription_document(&payload).is_none());
}
