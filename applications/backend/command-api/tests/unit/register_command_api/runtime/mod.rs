use command_api::{DispatchPlan, InMemoryCommandStore, InMemoryDispatchPort, STATUS_HANDLE_PREFIX};

#[test]
fn runtime_module_exports_store_dispatch_and_constants() {
    let store = InMemoryCommandStore::default();
    let dispatcher = InMemoryDispatchPort::default();
    let plan = DispatchPlan::not_requested();

    assert!(store.registration_for("actor:learner", "coffee").is_none());
    assert!(dispatcher.recorded_requests().is_empty());
    assert_eq!(STATUS_HANDLE_PREFIX, "status");
    assert!(!plan.dispatch_required);
}
