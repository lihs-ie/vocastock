use command_api::{
    AcceptanceOutcome, AcceptedCommandFields, AcceptedCommandResult, CommandFailure, StateSummary,
    TargetReference,
};

#[test]
fn accepted_result_replay_only_flips_idempotency_flag() {
    let accepted = AcceptedCommandResult::new(
        AcceptanceOutcome::Accepted,
        AcceptedCommandFields {
            target: TargetReference {
                vocabulary_expression: "vocabulary:coffee".to_owned(),
            },
            state: StateSummary {
                registration: "registered".to_owned(),
                explanation: "queued".to_owned(),
            },
            status_handle: "status:actor:learner:vocabulary:coffee".to_owned(),
            message: "accepted".to_owned(),
            replayed_by_idempotency: false,
            duplicate_reuse: None,
        },
    );

    let replayed = accepted.replay();

    assert!(!accepted.replayed_by_idempotency);
    assert!(replayed.replayed_by_idempotency);
    assert_eq!(replayed.acceptance, "accepted");
    assert_eq!(replayed.target.vocabulary_expression, "vocabulary:coffee");
}

#[test]
fn accepted_result_serialization_omits_duplicate_reuse_when_absent() {
    let accepted = AcceptedCommandResult::new(
        AcceptanceOutcome::ReusedExisting,
        AcceptedCommandFields {
            target: TargetReference {
                vocabulary_expression: "vocabulary:coffee".to_owned(),
            },
            state: StateSummary {
                registration: "registered".to_owned(),
                explanation: "queued".to_owned(),
            },
            status_handle: "status:actor:learner:vocabulary:coffee".to_owned(),
            message: "reused".to_owned(),
            replayed_by_idempotency: false,
            duplicate_reuse: None,
        },
    );

    let serialized = serde_json::to_string(&accepted).expect("result should serialize");

    assert!(serialized.contains("\"acceptance\":\"reused-existing\""));
    assert!(serialized.contains("\"statusHandle\""));
    assert!(!serialized.contains("duplicateReuse"));
}

#[test]
fn command_failure_http_statuses_match_contract() {
    let cases = [
        (
            CommandFailure::auth("missing-token", "missing", false),
            "401 Unauthorized",
        ),
        (
            CommandFailure::auth("invalid-token", "invalid", false),
            "401 Unauthorized",
        ),
        (
            CommandFailure::auth("reauth-required", "reauth", true),
            "403 Forbidden",
        ),
        (CommandFailure::ownership_mismatch(), "403 Forbidden"),
        (
            CommandFailure::validation_failed("validation"),
            "400 Bad Request",
        ),
        (CommandFailure::idempotency_conflict(), "409 Conflict"),
        (CommandFailure::dispatch_failed(), "503 Service Unavailable"),
        (
            CommandFailure::internal_failure("internal"),
            "500 Internal Server Error",
        ),
    ];

    for (failure, expected_status) in cases {
        assert_eq!(failure.http_status(), expected_status);
    }
}
