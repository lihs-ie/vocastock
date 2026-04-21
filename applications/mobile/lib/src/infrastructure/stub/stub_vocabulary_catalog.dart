import 'dart:async';

import '../../application/command/register_vocabulary_expression_command.dart';
import '../../application/envelope/command_error.dart';
import '../../application/envelope/command_response_envelope.dart';
import '../../application/reader/vocabulary_catalog_reader.dart';
import '../../domain/common/user_facing_message.dart';
import '../../domain/identifier/identifier.dart';
import '../../domain/status/explanation_generation_status.dart';
import '../../domain/status/image_generation_status.dart';
import '../../domain/status/registration_status.dart';
import '../../domain/vocabulary/vocabulary_expression_entry.dart';

/// In-memory catalog adapter used while the GraphQL gateway is still being
/// rolled out.
///
/// Implements both the reader and the registration command so tests can
/// inject a single instance via `ProviderScope(overrides: ...)` and observe
/// the same state from both sides.
class StubVocabularyCatalog
    implements VocabularyCatalogReader, RegisterVocabularyExpressionCommand {
  StubVocabularyCatalog({
    VocabularyExpressionIdentifier Function(int counter)? identifierFactory,
  }) : _identifierFactory = identifierFactory ?? _defaultIdentifierFactory;

  final VocabularyExpressionIdentifier Function(int counter)
      _identifierFactory;

  final List<VocabularyExpressionEntry> _entries = [];
  final StreamController<VocabularyCatalog> _controller =
      StreamController<VocabularyCatalog>.broadcast();
  int _counter = 0;

  @override
  VocabularyCatalog get current => VocabularyCatalog(_entries);

  @override
  Future<VocabularyCatalog> read() async => current;

  @override
  Stream<VocabularyCatalog> watch() => _controller.stream;

  @override
  Future<CommandResponseEnvelope> execute({
    required String text,
    required IdempotencyKey idempotencyKey,
  }) async {
    final normalized = text.trim();
    if (normalized.isEmpty) {
      return const CommandResponseRejected(
        message: UserFacingMessage(
          key: 'registration.validation-failed',
          text: '入力を確認してください',
        ),
        category: CommandErrorCategory.validationFailed,
      );
    }

    final existing = current.findByText(normalized);
    if (existing != null) {
      return const CommandResponseAccepted(
        message: UserFacingMessage(
          key: 'registration.reused',
          text: 'すでに登録済みです',
        ),
        outcome: AcceptanceOutcome.reusedExisting,
      );
    }

    final entry = VocabularyExpressionEntry(
      identifier: _identifierFactory(_counter++),
      text: normalized,
      registrationStatus: RegistrationStatus.active,
      explanationStatus: ExplanationGenerationStatus.pending,
      imageStatus: ImageGenerationStatus.pending,
    );
    _entries.add(entry);
    _controller.add(current);

    return const CommandResponseAccepted(
      message: UserFacingMessage(
        key: 'registration.accepted',
        text: '登録しました',
      ),
      outcome: AcceptanceOutcome.accepted,
    );
  }

  Future<void> dispose() async {
    await _controller.close();
  }

  static VocabularyExpressionIdentifier _defaultIdentifierFactory(int counter) {
    return VocabularyExpressionIdentifier(
      'stub-vocab-${counter.toString().padLeft(4, '0')}',
    );
  }
}
