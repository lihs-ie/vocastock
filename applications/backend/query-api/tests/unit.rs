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

#[path = "unit/query_catalog_read/vocabulary_expression_detail/firestore_source.rs"]
mod vocabulary_expression_detail_firestore_source;
#[path = "unit/query_catalog_read/vocabulary_expression_detail/model.rs"]
mod vocabulary_expression_detail_model;
#[path = "unit/query_catalog_read/vocabulary_expression_detail/read.rs"]
mod vocabulary_expression_detail_read;
#[path = "unit/query_catalog_read/vocabulary_expression_detail/source.rs"]
mod vocabulary_expression_detail_source;

#[path = "unit/query_catalog_read/explanation_detail/firestore_source.rs"]
mod explanation_detail_firestore_source;
#[path = "unit/query_catalog_read/explanation_detail/model.rs"]
mod explanation_detail_model;
#[path = "unit/query_catalog_read/explanation_detail/read.rs"]
mod explanation_detail_read;
#[path = "unit/query_catalog_read/explanation_detail/source.rs"]
mod explanation_detail_source;

#[path = "unit/query_catalog_read/image_detail/firestore_source.rs"]
mod image_detail_firestore_source;
#[path = "unit/query_catalog_read/image_detail/model.rs"]
mod image_detail_model;
#[path = "unit/query_catalog_read/image_detail/read.rs"]
mod image_detail_read;
#[path = "unit/query_catalog_read/image_detail/source.rs"]
mod image_detail_source;

#[path = "unit/query_catalog_read/subscription_status/firestore_source.rs"]
mod subscription_status_firestore_source;
#[path = "unit/query_catalog_read/subscription_status/model.rs"]
mod subscription_status_model;
#[path = "unit/query_catalog_read/subscription_status/read.rs"]
mod subscription_status_read;
#[path = "unit/query_catalog_read/subscription_status/source.rs"]
mod subscription_status_source;

#[path = "unit/query_catalog_read/actor_handoff_status/model.rs"]
mod actor_handoff_status_model;
#[path = "unit/query_catalog_read/actor_handoff_status/read.rs"]
mod actor_handoff_status_read;
