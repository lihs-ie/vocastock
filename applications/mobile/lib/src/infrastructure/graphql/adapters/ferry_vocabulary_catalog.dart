import 'dart:async';

import 'package:ferry/ferry.dart';

import '../../../application/command/generation_commands.dart';
import '../../../application/command/register_vocabulary_expression_command.dart';
import '../../../application/envelope/command_error.dart';
import '../../../application/envelope/command_response_envelope.dart';
import '../../../application/reader/vocabulary_catalog_reader.dart';
import '../../../application/reader/vocabulary_expression_detail_reader.dart';
import '../../../domain/common/user_facing_message.dart';
import '../../../domain/identifier/identifier.dart';
import '../../../domain/status/explanation_generation_status.dart';
import '../../../domain/status/image_generation_status.dart';
import '../../../domain/status/registration_status.dart';
import '../../../domain/vocabulary/vocabulary_expression_entry.dart';
import '../__generated__/schema.schema.gql.dart' as schema;
import '../operations/__generated__/commands.data.gql.dart';
import '../operations/__generated__/commands.req.gql.dart';
import '../operations/__generated__/commands.var.gql.dart';
import '../operations/__generated__/vocabulary_catalog.data.gql.dart';
import '../operations/__generated__/vocabulary_catalog.req.gql.dart';
import '../operations/__generated__/vocabulary_catalog.var.gql.dart';
import 'ferry_envelope_mappers.dart';

/// Ferry-backed implementation of the catalog reader / detail reader /
/// registration and generation commands.
///
/// All writes flow through `applications/backend/graphql-gateway`; the
/// gateway relays to `command-api` (mutations) and `query-api` (reads),
/// which in turn persist to / read from Firestore in live-adapter mode.
class FerryVocabularyCatalog
    implements
        VocabularyCatalogReader,
        VocabularyExpressionDetailReader,
        RegisterVocabularyExpressionCommand,
        RequestExplanationGenerationCommand,
        RequestImageGenerationCommand,
        RetryGenerationCommand {
  FerryVocabularyCatalog({required Client client})
      : _client = client,
        _current = VocabularyCatalog(const <VocabularyExpressionEntry>[]);

  final Client _client;
  VocabularyCatalog _current;

  StreamSubscription<OperationResponse<GVocabularyCatalogQueryData,
          GVocabularyCatalogQueryVars>>? _subscription;
  final StreamController<VocabularyCatalog> _controller =
      StreamController<VocabularyCatalog>.broadcast(
    onListen: _onListen,
    onCancel: _onCancel,
  );

  // Lazy subscription management so we only hold the network request while
  // a consumer is listening.
  static FerryVocabularyCatalog? _activeInstance;
  static void _onListen() {
    _activeInstance?._start();
  }

  static void _onCancel() {
    _activeInstance?._stop();
  }

  @override
  VocabularyCatalog get current => _current;

  @override
  Future<VocabularyCatalog> read() async {
    final request = GVocabularyCatalogQueryReq(
      (b) => b..fetchPolicy = FetchPolicy.NetworkOnly,
    );
    final response = await _client.request(request).first;
    final data = response.data;
    if (data == null) {
      final error = response.linkException ?? response.graphqlErrors?.first;
      throw StateError('vocabularyCatalog failed: $error');
    }
    return _current = _toCatalog(data);
  }

  @override
  Stream<VocabularyCatalog> watch() {
    _activeInstance = this;
    return _controller.stream;
  }

  @override
  Future<VocabularyExpressionEntry?> readDetail(
    VocabularyExpressionIdentifier identifier,
  ) async {
    final request = GVocabularyExpressionDetailQueryReq(
      (b) => b
        ..vars.identifier = identifier.value
        ..fetchPolicy = FetchPolicy.NetworkOnly,
    );
    final response = await _client.request(request).first;
    final data = response.data?.vocabularyExpressionDetail;
    if (data == null) return null;
    return VocabularyExpressionEntry(
      identifier: VocabularyExpressionIdentifier(data.identifier),
      text: data.text,
      registrationStatus: _registrationStatus(data.registrationStatus),
      explanationStatus: _explanationStatus(data.explanationStatus),
      imageStatus: _imageStatus(data.imageStatus),
      currentExplanation: data.currentExplanation != null
          ? ExplanationIdentifier(data.currentExplanation!)
          : null,
      currentImage: data.currentImage != null
          ? VisualImageIdentifier(data.currentImage!)
          : null,
    );
  }

  @override
  Stream<VocabularyExpressionEntry?> watchDetail(
    VocabularyExpressionIdentifier identifier,
  ) async* {
    yield await readDetail(identifier);
  }

  @override
  Future<CommandResponseEnvelope> register({
    required String text,
    required IdempotencyKey idempotencyKey,
  }) async {
    final request = GRegisterVocabularyExpressionMutationReq(
      (b) => b
        ..vars.input.text = text
        ..vars.input.idempotencyKey = idempotencyKey.value,
    );
    final response = await _client.request(request).first;
    return FerryEnvelopeMappers.fromResponse(
      response.data?.registerVocabularyExpression,
      response.linkException,
      response.graphqlErrors,
    );
  }

  @override
  Future<CommandResponseEnvelope> requestExplanation({
    required VocabularyExpressionIdentifier vocabularyExpression,
    required IdempotencyKey idempotencyKey,
  }) async {
    final request = GRequestExplanationGenerationMutationReq(
      (b) => b
        ..vars.input.vocabularyExpression = vocabularyExpression.value
        ..vars.input.idempotencyKey = idempotencyKey.value,
    );
    final response = await _client.request(request).first;
    return FerryEnvelopeMappers.fromResponse(
      response.data?.requestExplanationGeneration,
      response.linkException,
      response.graphqlErrors,
    );
  }

  @override
  Future<CommandResponseEnvelope> requestImage({
    required VocabularyExpressionIdentifier vocabularyExpression,
    required IdempotencyKey idempotencyKey,
  }) async {
    final request = GRequestImageGenerationMutationReq(
      (b) => b
        ..vars.input.vocabularyExpression = vocabularyExpression.value
        ..vars.input.idempotencyKey = idempotencyKey.value,
    );
    final response = await _client.request(request).first;
    return FerryEnvelopeMappers.fromResponse(
      response.data?.requestImageGeneration,
      response.linkException,
      response.graphqlErrors,
    );
  }

  @override
  Future<CommandResponseEnvelope> retry({
    required VocabularyExpressionIdentifier vocabularyExpression,
    required GenerationTargetKind target,
    required IdempotencyKey idempotencyKey,
  }) async {
    final request = GRetryGenerationMutationReq(
      (b) => b
        ..vars.input.vocabularyExpression = vocabularyExpression.value
        ..vars.input.target = target == GenerationTargetKind.explanation
            ? schema.GGenerationTargetKind.EXPLANATION
            : schema.GGenerationTargetKind.IMAGE
        ..vars.input.idempotencyKey = idempotencyKey.value,
    );
    final response = await _client.request(request).first;
    return FerryEnvelopeMappers.fromResponse(
      response.data?.retryGeneration,
      response.linkException,
      response.graphqlErrors,
    );
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller.close();
  }

  void _start() {
    unawaited(_subscription?.cancel());
    final request = GVocabularyCatalogQueryReq();
    _subscription = _client.request(request).listen((response) {
      final data = response.data;
      if (data == null) return;
      _current = _toCatalog(data);
      _controller.add(_current);
    });
  }

  void _stop() {
    unawaited(_subscription?.cancel());
    _subscription = null;
  }

  VocabularyCatalog _toCatalog(GVocabularyCatalogQueryData data) {
    final entries = data.vocabularyCatalog.entries
        .map((entry) => VocabularyExpressionEntry(
              identifier: VocabularyExpressionIdentifier(entry.identifier),
              text: entry.text,
              registrationStatus:
                  _registrationStatus(entry.registrationStatus),
              explanationStatus:
                  _explanationStatus(entry.explanationStatus),
              imageStatus: _imageStatus(entry.imageStatus),
              currentExplanation: entry.currentExplanation != null
                  ? ExplanationIdentifier(entry.currentExplanation!)
                  : null,
              currentImage: entry.currentImage != null
                  ? VisualImageIdentifier(entry.currentImage!)
                  : null,
            ))
        .toList(growable: false);
    return VocabularyCatalog(entries);
  }

  RegistrationStatus _registrationStatus(schema.GRegistrationStatus value) {
    return switch (value) {
      schema.GRegistrationStatus.ACTIVE => RegistrationStatus.active,
      schema.GRegistrationStatus.ARCHIVED => RegistrationStatus.archived,
      _ => RegistrationStatus.active,
    };
  }

  ExplanationGenerationStatus _explanationStatus(
    schema.GExplanationGenerationStatus value,
  ) {
    return switch (value) {
      schema.GExplanationGenerationStatus.PENDING =>
        ExplanationGenerationStatus.pending,
      schema.GExplanationGenerationStatus.RUNNING =>
        ExplanationGenerationStatus.running,
      schema.GExplanationGenerationStatus.RETRY_SCHEDULED =>
        ExplanationGenerationStatus.retryScheduled,
      schema.GExplanationGenerationStatus.TIMED_OUT =>
        ExplanationGenerationStatus.timedOut,
      schema.GExplanationGenerationStatus.SUCCEEDED =>
        ExplanationGenerationStatus.succeeded,
      schema.GExplanationGenerationStatus.FAILED_FINAL =>
        ExplanationGenerationStatus.failedFinal,
      schema.GExplanationGenerationStatus.DEAD_LETTERED =>
        ExplanationGenerationStatus.deadLettered,
      _ => ExplanationGenerationStatus.pending,
    };
  }

  ImageGenerationStatus _imageStatus(schema.GImageGenerationStatus value) {
    return switch (value) {
      schema.GImageGenerationStatus.PENDING => ImageGenerationStatus.pending,
      schema.GImageGenerationStatus.RUNNING => ImageGenerationStatus.running,
      schema.GImageGenerationStatus.RETRY_SCHEDULED =>
        ImageGenerationStatus.retryScheduled,
      schema.GImageGenerationStatus.TIMED_OUT =>
        ImageGenerationStatus.timedOut,
      schema.GImageGenerationStatus.SUCCEEDED =>
        ImageGenerationStatus.succeeded,
      schema.GImageGenerationStatus.FAILED_FINAL =>
        ImageGenerationStatus.failedFinal,
      schema.GImageGenerationStatus.DEAD_LETTERED =>
        ImageGenerationStatus.deadLettered,
      _ => ImageGenerationStatus.pending,
    };
  }
}

// Keep unused import warnings quiet for the command mappers when the
// analyzer inlines the imports above.
// ignore_for_file: unused_import
