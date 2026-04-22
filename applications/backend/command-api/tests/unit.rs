#[path = "support/unit.rs"]
mod support;

#[path = "unit/register_command_api/command/acceptance.rs"]
mod command_acceptance;
#[path = "unit/register_command_api/command/mod.rs"]
mod command_mod;
#[path = "unit/register_command_api/command/request.rs"]
mod command_request;
#[path = "unit/register_command_api/command/response.rs"]
mod command_response;
#[path = "unit/register_command_api/runtime/command_store.rs"]
mod command_store;
#[path = "unit/register_command_api/runtime/dispatch_port.rs"]
mod dispatch_port;
#[path = "unit/register_command_api/http/endpoint.rs"]
mod http_endpoint;
#[path = "unit/register_command_api/http/mod.rs"]
mod http_mod;
#[path = "unit/register_command_api/mod.rs"]
mod register_command_api;
#[path = "unit/register_command_api/runtime/mod.rs"]
mod runtime_mod;
#[path = "unit/register_command_api/runtime/server_loop.rs"]
mod server_loop;
#[path = "unit/register_command_api/runtime/service_contract.rs"]
mod service_contract;
#[path = "unit/shared_auth.rs"]
mod shared_auth;
#[path = "unit/shared_runtime.rs"]
mod shared_runtime;
#[path = "unit/register_command_api/runtime/stub_token_verifier.rs"]
mod stub_token_verifier;

#[path = "unit/register_command_api/runtime/firestore_command_store.rs"]
mod firestore_command_store_tests;
#[path = "unit/register_command_api/runtime/firestore_mutation_command_store.rs"]
mod firestore_mutation_command_store_tests;
#[path = "unit/register_command_api/command/mutation_acceptance.rs"]
mod mutation_acceptance;
#[path = "unit/register_command_api/command/mutation_request.rs"]
mod mutation_request;
#[path = "unit/register_command_api/runtime/pubsub_dispatch_port.rs"]
mod pubsub_dispatch_port_tests;
