use std::net::TcpListener;

use shared_runtime::{
    firebase_dependencies_healthy, firebase_dependency_report, firebase_dependency_statuses,
};

use crate::support::env_lock;

#[test]
fn shared_runtime_reports_reachable_configured_dependency() {
    let _guard = env_lock();
    let listener = TcpListener::bind(("127.0.0.1", 0)).expect("listener should bind");
    let address = listener
        .local_addr()
        .expect("listener address should resolve");

    unsafe {
        std::env::set_var("FIRESTORE_EMULATOR_HOST", address.to_string());
        std::env::remove_var("STORAGE_EMULATOR_HOST");
        std::env::remove_var("FIREBASE_AUTH_EMULATOR_HOST");
        std::env::remove_var("PUBSUB_EMULATOR_HOST");
    }

    let statuses = firebase_dependency_statuses();
    let report = firebase_dependency_report();

    assert!(firebase_dependencies_healthy());
    assert_eq!(statuses[0].dependency_name, "firestore");
    assert!(statuses[0].reachable);
    assert!(report.contains("firestore="));
    assert!(report.contains("reachable via"));

    unsafe {
        std::env::remove_var("FIRESTORE_EMULATOR_HOST");
    }
}

#[test]
fn shared_runtime_reports_unreachable_dependency() {
    let _guard = env_lock();
    let listener = TcpListener::bind(("127.0.0.1", 0)).expect("listener should bind");
    let address = listener
        .local_addr()
        .expect("listener address should resolve");
    drop(listener);

    unsafe {
        std::env::set_var("FIRESTORE_EMULATOR_HOST", address.to_string());
        std::env::remove_var("STORAGE_EMULATOR_HOST");
        std::env::remove_var("FIREBASE_AUTH_EMULATOR_HOST");
        std::env::remove_var("PUBSUB_EMULATOR_HOST");
    }

    let statuses = firebase_dependency_statuses();
    let report = firebase_dependency_report();

    assert!(!firebase_dependencies_healthy());
    assert!(!statuses[0].reachable);
    assert!(report.contains("connect failed"));

    unsafe {
        std::env::remove_var("FIRESTORE_EMULATOR_HOST");
    }
}

#[test]
fn shared_runtime_reports_address_resolution_failure() {
    let _guard = env_lock();
    unsafe {
        std::env::set_var("FIRESTORE_EMULATOR_HOST", "invalid.invalid:18080");
        std::env::remove_var("STORAGE_EMULATOR_HOST");
        std::env::remove_var("FIREBASE_AUTH_EMULATOR_HOST");
        std::env::remove_var("PUBSUB_EMULATOR_HOST");
    }

    let statuses = firebase_dependency_statuses();
    let report = firebase_dependency_report();

    assert!(!firebase_dependencies_healthy());
    assert!(!statuses[0].reachable);
    assert!(report.contains("address resolution failed"));

    unsafe {
        std::env::remove_var("FIRESTORE_EMULATOR_HOST");
    }
}
