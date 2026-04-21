import '../../domain/identifier/identifier.dart';
import '../envelope/command_response_envelope.dart';

/// Requests asynchronous explanation generation for the given vocabulary
/// expression (spec 012 explanation workflow).
abstract class RequestExplanationGenerationCommand {
  Future<CommandResponseEnvelope> requestExplanation({
    required VocabularyExpressionIdentifier vocabularyExpression,
    required IdempotencyKey idempotencyKey,
  });
}

/// Requests asynchronous image generation (spec 012 image workflow).
/// Requires a completed explanation; if not yet available the command intake
/// rejects with `targetNotReady`.
abstract class RequestImageGenerationCommand {
  Future<CommandResponseEnvelope> requestImage({
    required VocabularyExpressionIdentifier vocabularyExpression,
    required IdempotencyKey idempotencyKey,
  });
}

/// Restarts a failed generation (either explanation or image). The target
/// kind is chosen by the caller.
enum GenerationTargetKind {
  explanation,
  image,
}

abstract class RetryGenerationCommand {
  Future<CommandResponseEnvelope> retry({
    required VocabularyExpressionIdentifier vocabularyExpression,
    required GenerationTargetKind target,
    required IdempotencyKey idempotencyKey,
  });
}
