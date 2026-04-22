use crate::support::InMemoryDispatchPort;
use command_api::{DispatchOutcome, DispatchRequest};

#[test]
fn dispatch_port_records_requests_and_accepts_normal_work() {
    let dispatcher = InMemoryDispatchPort::default();

    let plan = dispatcher.dispatch(DispatchRequest::new(
        "actor:learner",
        "req-accepted",
        "coffee",
        "vocabulary:coffee",
        false,
    ));

    assert!(plan.dispatch_required);
    assert_eq!(plan.dispatch_outcome, DispatchOutcome::Accepted);
    assert_eq!(dispatcher.recorded_requests().len(), 1);
}

#[test]
fn dispatch_port_fails_for_marker_keys() {
    let dispatcher = InMemoryDispatchPort::default();

    let plan = dispatcher.dispatch(DispatchRequest::new(
        "actor:learner",
        "dispatch-fail-001",
        "coffee",
        "vocabulary:coffee",
        true,
    ));

    assert!(plan.dispatch_required);
    assert_eq!(plan.dispatch_outcome, DispatchOutcome::Failed);
    assert!(dispatcher.recorded_requests()[0].restart_requested);
}
