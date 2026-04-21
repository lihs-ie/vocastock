import '../../domain/identifier/identifier.dart';
import '../envelope/command_response_envelope.dart';

/// Submits a new vocabulary expression (spec 011 api-command-io-design).
///
/// Duplicate reuse (`AcceptanceOutcome.reusedExisting`) is a legal success
/// path; callers should branch on the outcome to decide whether to display a
/// "registered" or "already in your catalog" message.
abstract class RegisterVocabularyExpressionCommand {
  Future<CommandResponseEnvelope> execute({
    required String text,
    required IdempotencyKey idempotencyKey,
  });
}
