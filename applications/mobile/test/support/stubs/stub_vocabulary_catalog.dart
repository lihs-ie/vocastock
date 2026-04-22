import 'dart:async';

import 'package:vocastock_mobile/src/application/command/generation_commands.dart';
import 'package:vocastock_mobile/src/application/command/register_vocabulary_expression_command.dart';
import 'package:vocastock_mobile/src/application/envelope/command_error.dart';
import 'package:vocastock_mobile/src/application/envelope/command_response_envelope.dart';
import 'package:vocastock_mobile/src/application/reader/vocabulary_catalog_reader.dart';
import 'package:vocastock_mobile/src/application/reader/vocabulary_expression_detail_reader.dart';
import 'package:vocastock_mobile/src/domain/common/user_facing_message.dart';
import 'package:vocastock_mobile/src/domain/identifier/identifier.dart';
import 'package:vocastock_mobile/src/domain/status/explanation_generation_status.dart';
import 'package:vocastock_mobile/src/domain/status/image_generation_status.dart';
import 'package:vocastock_mobile/src/domain/status/registration_status.dart';
import 'package:vocastock_mobile/src/domain/vocabulary/vocabulary_expression_entry.dart';

/// In-memory adapter that backs the catalog reader, detail reader, and all
/// registration / generation commands.
///
/// Having a single state owner across screens keeps the stub consistent:
/// status updates driven by a generation command are immediately visible
/// through both the catalog watch stream and the per-entry detail watch.
class StubVocabularyCatalog
    implements
        VocabularyCatalogReader,
        VocabularyExpressionDetailReader,
        RegisterVocabularyExpressionCommand,
        RequestExplanationGenerationCommand,
        RequestImageGenerationCommand,
        RetryGenerationCommand {
  StubVocabularyCatalog({
    VocabularyExpressionIdentifier Function(int counter)? identifierFactory,
    ExplanationIdentifier Function(VocabularyExpressionIdentifier)?
        explanationIdentifierFactory,
    VisualImageIdentifier Function(VocabularyExpressionIdentifier)?
        imageIdentifierFactory,
  })  : _identifierFactory = identifierFactory ?? _defaultIdentifierFactory,
        _explanationIdentifierFactory = explanationIdentifierFactory ??
            _defaultExplanationIdentifierFactory,
        _imageIdentifierFactory =
            imageIdentifierFactory ?? _defaultImageIdentifierFactory;

  final VocabularyExpressionIdentifier Function(int counter)
      _identifierFactory;
  final ExplanationIdentifier Function(VocabularyExpressionIdentifier)
      _explanationIdentifierFactory;
  final VisualImageIdentifier Function(VocabularyExpressionIdentifier)
      _imageIdentifierFactory;

  final List<VocabularyExpressionEntry> _entries = [];
  final StreamController<VocabularyCatalog> _catalogStream =
      StreamController<VocabularyCatalog>.broadcast();
  final StreamController<VocabularyExpressionEntry> _entryStream =
      StreamController<VocabularyExpressionEntry>.broadcast();
  int _counter = 0;

  @override
  VocabularyCatalog get current => VocabularyCatalog(_entries);

  @override
  Future<VocabularyCatalog> read() async => current;

  @override
  Stream<VocabularyCatalog> watch() => _catalogStream.stream;

  @override
  Future<VocabularyExpressionEntry?> readDetail(
    VocabularyExpressionIdentifier identifier,
  ) async {
    return _findEntry(identifier);
  }

  @override
  Stream<VocabularyExpressionEntry?> watchDetail(
    VocabularyExpressionIdentifier identifier,
  ) {
    return _entryStream.stream.where(
      (entry) => entry.identifier == identifier,
    );
  }

  @override
  Future<CommandResponseEnvelope> register({
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
    _emit(entry);

    return const CommandResponseAccepted(
      message: UserFacingMessage(
        key: 'registration.accepted',
        text: '登録しました',
      ),
      outcome: AcceptanceOutcome.accepted,
    );
  }

  @override
  Future<CommandResponseEnvelope> requestExplanation({
    required VocabularyExpressionIdentifier vocabularyExpression,
    required IdempotencyKey idempotencyKey,
  }) async {
    final entry = _findEntry(vocabularyExpression);
    if (entry == null) {
      return const CommandResponseRejected(
        message: UserFacingMessage(
          key: 'detail.not-found',
          text: '対象が見つかりませんでした',
        ),
        category: CommandErrorCategory.targetMissing,
      );
    }
    _replace(
      entry.copyWith(
        explanationStatus: ExplanationGenerationStatus.running,
      ),
    );
    _completeExplanation(vocabularyExpression);
    return const CommandResponseAccepted(
      message: UserFacingMessage(
        key: 'generation.explanation.accepted',
        text: '解説生成を受け付けました',
      ),
      outcome: AcceptanceOutcome.accepted,
    );
  }

  @override
  Future<CommandResponseEnvelope> requestImage({
    required VocabularyExpressionIdentifier vocabularyExpression,
    required IdempotencyKey idempotencyKey,
  }) async {
    final entry = _findEntry(vocabularyExpression);
    if (entry == null) {
      return const CommandResponseRejected(
        message: UserFacingMessage(
          key: 'detail.not-found',
          text: '対象が見つかりませんでした',
        ),
        category: CommandErrorCategory.targetMissing,
      );
    }
    if (entry.currentExplanation == null) {
      return const CommandResponseRejected(
        message: UserFacingMessage(
          key: 'generation.image.prerequisite',
          text: '先に解説生成を完了してください',
        ),
        category: CommandErrorCategory.targetNotReady,
      );
    }
    _replace(
      entry.copyWith(imageStatus: ImageGenerationStatus.running),
    );
    _completeImage(vocabularyExpression);
    return const CommandResponseAccepted(
      message: UserFacingMessage(
        key: 'generation.image.accepted',
        text: '画像生成を受け付けました',
      ),
      outcome: AcceptanceOutcome.accepted,
    );
  }

  @override
  Future<CommandResponseEnvelope> retry({
    required VocabularyExpressionIdentifier vocabularyExpression,
    required GenerationTargetKind target,
    required IdempotencyKey idempotencyKey,
  }) async {
    return switch (target) {
      GenerationTargetKind.explanation => requestExplanation(
          vocabularyExpression: vocabularyExpression,
          idempotencyKey: idempotencyKey,
        ),
      GenerationTargetKind.image => requestImage(
          vocabularyExpression: vocabularyExpression,
          idempotencyKey: idempotencyKey,
        ),
    };
  }

  /// Forces an image generation into the `failedFinal` state; used by
  /// feature tests to rehearse the retryable-failure UI variant without
  /// reaching into private fields.
  void markImageFailed(VocabularyExpressionIdentifier identifier) {
    final entry = _findEntry(identifier);
    if (entry == null) return;
    _replace(
      entry.copyWith(imageStatus: ImageGenerationStatus.failedFinal),
    );
  }

  /// Test-only helper: puts an explanation into the `failedFinal` state.
  void markExplanationFailed(VocabularyExpressionIdentifier identifier) {
    final entry = _findEntry(identifier);
    if (entry == null) return;
    _replace(
      entry.copyWith(
        explanationStatus: ExplanationGenerationStatus.failedFinal,
      ),
    );
  }

  void _completeExplanation(VocabularyExpressionIdentifier identifier) {
    final entry = _findEntry(identifier);
    if (entry == null) return;
    _replace(
      entry.copyWith(
        explanationStatus: ExplanationGenerationStatus.succeeded,
        currentExplanation: _explanationIdentifierFactory(identifier),
      ),
    );
  }

  void _completeImage(VocabularyExpressionIdentifier identifier) {
    final entry = _findEntry(identifier);
    if (entry == null) return;
    _replace(
      entry.copyWith(
        imageStatus: ImageGenerationStatus.succeeded,
        currentImage: _imageIdentifierFactory(identifier),
      ),
    );
  }

  VocabularyExpressionEntry? _findEntry(
    VocabularyExpressionIdentifier identifier,
  ) {
    for (final entry in _entries) {
      if (entry.identifier == identifier) return entry;
    }
    return null;
  }

  void _replace(VocabularyExpressionEntry updated) {
    final index = _entries.indexWhere(
      (entry) => entry.identifier == updated.identifier,
    );
    if (index == -1) return;
    _entries[index] = updated;
    _emit(updated);
  }

  void _emit(VocabularyExpressionEntry entry) {
    _catalogStream.add(current);
    _entryStream.add(entry);
  }

  Future<void> dispose() async {
    await _catalogStream.close();
    await _entryStream.close();
  }

  static VocabularyExpressionIdentifier _defaultIdentifierFactory(int counter) {
    return VocabularyExpressionIdentifier(
      'stub-vocab-${counter.toString().padLeft(4, '0')}',
    );
  }

  static ExplanationIdentifier _defaultExplanationIdentifierFactory(
    VocabularyExpressionIdentifier vocabulary,
  ) {
    return ExplanationIdentifier('stub-exp-for-${vocabulary.value}');
  }

  static VisualImageIdentifier _defaultImageIdentifierFactory(
    VocabularyExpressionIdentifier vocabulary,
  ) {
    return VisualImageIdentifier('stub-img-for-${vocabulary.value}');
  }
}

extension _EntryCopyWith on VocabularyExpressionEntry {
  VocabularyExpressionEntry copyWith({
    ExplanationGenerationStatus? explanationStatus,
    ImageGenerationStatus? imageStatus,
    ExplanationIdentifier? currentExplanation,
    VisualImageIdentifier? currentImage,
  }) {
    return VocabularyExpressionEntry(
      identifier: identifier,
      text: text,
      registrationStatus: registrationStatus,
      explanationStatus: explanationStatus ?? this.explanationStatus,
      imageStatus: imageStatus ?? this.imageStatus,
      currentExplanation: currentExplanation ?? this.currentExplanation,
      currentImage: currentImage ?? this.currentImage,
    );
  }
}
