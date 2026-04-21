/// Image generation lifecycle exposed to the UI (spec 012 / 013).
///
/// Same separation rules as [ExplanationGenerationStatus]; tracked as an
/// independent concept because constitution §VI forbids conflating the two.
enum ImageGenerationStatus {
  pending,
  running,
  retryScheduled,
  timedOut,
  succeeded,
  failedFinal,
  deadLettered,
}
