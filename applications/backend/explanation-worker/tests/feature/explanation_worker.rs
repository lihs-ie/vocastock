use crate::support::{assert_field, FeatureRuntime};

#[test]
fn starts_as_a_long_running_consumer() {
    let mut runtime = FeatureRuntime::start();
    runtime.start_stable_worker();
    runtime.wait_for_stable_worker();

    let logs = runtime.worker_logs();
    assert!(
        logs.contains("entered stable-run mode"),
        "expected stable-run log, actual logs:\n{logs}"
    );
    assert!(
        logs.contains("awaiting queue/subscription work"),
        "expected polling log, actual logs:\n{logs}"
    );
}

#[test]
fn validates_success_retryable_and_terminal_paths() {
    let runtime = FeatureRuntime::start();

    let success = runtime.run_validation("success");
    assert_field(&success, "final_state", "succeeded");
    assert_field(&success, "visibility", "completed-current");
    assert_field(&success, "completed_saved", "true");
    assert_field(&success, "handoff_completed", "true");

    let retryable = runtime.run_validation("retryable-failure");
    assert_field(&retryable, "final_state", "retry-scheduled-1");
    assert_field(&retryable, "visibility", "status-only");
    assert_field(&retryable, "failure_code", "retryable-failure");
    assert_field(&retryable, "current_retained", "true");

    let terminal = runtime.run_validation("terminal-failure");
    assert_field(&terminal, "final_state", "failed-final");
    assert_field(&terminal, "visibility", "status-only");
    assert_field(&terminal, "failure_code", "malformed-payload");
    assert_field(&terminal, "current_retained", "true");
}

#[test]
fn maps_invalid_target_duplicate_and_dead_letter_cases() {
    let runtime = FeatureRuntime::start();

    let invalid_target = runtime.run_validation("invalid-target");
    assert_field(&invalid_target, "final_state", "failed-final");
    assert_field(&invalid_target, "failure_code", "invalid-target");
    assert_field(&invalid_target, "completed_saved", "false");

    let ownership_mismatch = runtime.run_validation("ownership-mismatch");
    assert_field(&ownership_mismatch, "final_state", "dead-lettered");
    assert_field(&ownership_mismatch, "failure_code", "ownership-mismatch");
    assert_field(&ownership_mismatch, "current_retained", "true");

    let duplicate_running = runtime.run_validation("duplicate-running");
    assert_field(&duplicate_running, "final_state", "running");
    assert_field(&duplicate_running, "duplicate", "inflight-noop");

    let duplicate_succeeded = runtime.run_validation("duplicate-succeeded");
    assert_field(&duplicate_succeeded, "final_state", "succeeded");
    assert_field(&duplicate_succeeded, "duplicate", "reuse-completed");
}
