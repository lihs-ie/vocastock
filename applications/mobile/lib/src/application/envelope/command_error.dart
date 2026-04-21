/// Canonical command error categories (spec 011 api-command-io-design) plus
/// the GraphQL gateway envelope categories (spec 020).
///
/// The UI renders errors only through `UserFacingMessage`; this enum is used
/// by the application layer to decide retryability and routing.
enum CommandErrorCategory {
  // spec 011 command intake categories
  validationFailed,
  ownershipMismatch,
  targetMissing,
  targetNotReady,
  idempotencyConflict,
  dispatchFailed,
  internalFailure,

  // spec 020 graphql gateway categories
  unsupportedOperation,
  ambiguousOperation,
  downstreamUnavailable,
  downstreamInvalidResponse,
  downstreamAuthFailed,
}

extension CommandErrorCategoryExtension on CommandErrorCategory {
  /// Whether the UI may offer a retry CTA without re-authenticating.
  bool get isRetryable {
    return switch (this) {
      CommandErrorCategory.dispatchFailed ||
      CommandErrorCategory.targetNotReady ||
      CommandErrorCategory.downstreamUnavailable =>
        true,
      _ => false,
    };
  }

  /// Whether the UI must route the user through the auth flow again.
  bool get requiresReauth {
    return this == CommandErrorCategory.downstreamAuthFailed;
  }
}
