/// Explanation generation lifecycle exposed to the UI.
///
/// UI treats any non-`succeeded` variant as status-only (spec 013
/// generation-result-visibility-contract). The extended runtime variants map
/// from workflow state (spec 012) so the UI can render retryable vs terminal
/// failure states without leaking internal workflow names to users.
enum ExplanationGenerationStatus {
  pending,
  running,
  retryScheduled,
  timedOut,
  succeeded,
  failedFinal,
  deadLettered,
}
