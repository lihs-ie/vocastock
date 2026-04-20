#[path = "support/unit.rs"]
mod support;

#[path = "unit/query_catalog_read/catalog/model.rs"]
mod catalog_model;
#[path = "unit/query_catalog_read/catalog/read.rs"]
mod catalog_read;
#[path = "unit/query_catalog_read/catalog/source.rs"]
mod catalog_source;
#[path = "unit/query_catalog_read/http/endpoint.rs"]
mod http_endpoint;
#[path = "unit/query_catalog_read/mod.rs"]
mod query_catalog_read;
#[path = "unit/query_catalog_read/runtime/service_contract.rs"]
mod service_contract;
#[path = "unit/query_catalog_read/runtime/stub_token_verifier.rs"]
mod stub_token_verifier;
