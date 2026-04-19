use query_api::{ROOT_MESSAGE, SERVICE_NAME, VOCABULARY_CATALOG_PATH};

#[test]
fn service_contract_constants_match_expected_values() {
    assert_eq!(SERVICE_NAME, "query-api");
    assert_eq!(VOCABULARY_CATALOG_PATH, "/vocabulary-catalog");
    assert_eq!(
        ROOT_MESSAGE,
        "query-api returns completed summaries or status-only catalog items"
    );
}
