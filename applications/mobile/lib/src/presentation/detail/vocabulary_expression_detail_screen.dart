import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../app_bindings.dart';
import '../../application/command/generation_commands.dart';
import '../../application/envelope/command_response_envelope.dart';
import '../../domain/identifier/identifier.dart';
import '../../domain/status/explanation_generation_status.dart';
import '../../domain/status/image_generation_status.dart';
import '../../domain/subscription/entitlement.dart';
import '../../domain/subscription/plan.dart';
import '../../domain/vocabulary/vocabulary_expression_entry.dart';
import '../router/router.dart';

/// Spec 013 canonical `VocabularyExpressionDetail` screen.
///
/// `allowsCompletedPayload = false`: the screen only aggregates generation
/// status and exposes CTAs into the completed-only detail screens. Explanation
/// body and image payload are NEVER rendered here.
class VocabularyExpressionDetailScreen extends ConsumerWidget {
  const VocabularyExpressionDetailScreen({
    required this.identifier,
    super.key,
  });

  final VocabularyExpressionIdentifier identifier;

  static const Uuid _uuidGenerator = Uuid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryAsync =
        ref.watch(vocabularyExpressionDetailStreamProvider(identifier));
    final entry = entryAsync.value;

    return Scaffold(
      appBar: AppBar(title: const Text('単語の詳細')),
      body: entry == null
          ? const Center(
              child: CircularProgressIndicator(
                key: Key('detail.loading'),
              ),
            )
          : _buildStatusBody(context, ref, entry),
    );
  }

  Widget _buildStatusBody(
    BuildContext context,
    WidgetRef ref,
    VocabularyExpressionEntry entry,
  ) {
    final explanationStatusLabel = _explanationLabel(entry.explanationStatus);
    final imageStatusLabel = _imageLabel(entry.imageStatus);
    final canRequestImage =
        entry.hasCompletedExplanation && !entry.hasCompletedImage;
    final explanationFailed =
        entry.explanationStatus == ExplanationGenerationStatus.failedFinal ||
            entry.explanationStatus == ExplanationGenerationStatus.deadLettered;
    final imageFailed =
        entry.imageStatus == ImageGenerationStatus.failedFinal ||
            entry.imageStatus == ImageGenerationStatus.deadLettered;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            entry.text,
            key: const Key('detail.text'),
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 24),
          ListTile(
            key: const Key('detail.explanation-status'),
            title: const Text('解説'),
            subtitle: Text(explanationStatusLabel),
          ),
          if (entry.hasCompletedExplanation)
            ElevatedButton(
              key: const Key('detail.open-explanation'),
              onPressed: () => context.go(
                '${AppRoutes.explanationPrefix}/${entry.currentExplanation!.value}',
              ),
              child: const Text('解説を見る'),
            ),
          if (explanationFailed)
            OutlinedButton(
              key: const Key('detail.retry-explanation'),
              onPressed: () => unawaited(
                _retry(ref, GenerationTargetKind.explanation),
              ),
              child: const Text('解説生成を再試行'),
            ),
          const SizedBox(height: 24),
          ListTile(
            key: const Key('detail.image-status'),
            title: const Text('画像'),
            subtitle: Text(imageStatusLabel),
          ),
          if (entry.hasCompletedImage)
            ElevatedButton(
              key: const Key('detail.open-image'),
              onPressed: () => context.go(
                '${AppRoutes.imagePrefix}/${entry.currentImage!.value}',
              ),
              child: const Text('画像を見る'),
            ),
          if (canRequestImage)
            ElevatedButton(
              key: const Key('detail.request-image'),
              onPressed: () => unawaited(_requestImage(context, ref)),
              child: const Text('画像を生成する'),
            ),
          if (imageFailed)
            OutlinedButton(
              key: const Key('detail.retry-image'),
              onPressed: () =>
                  unawaited(_retry(ref, GenerationTargetKind.image)),
              child: const Text('画像生成を再試行'),
            ),
        ],
      ),
    );
  }

  Future<void> _requestImage(BuildContext context, WidgetRef ref) async {
    final gate = ref.read(subscriptionFeatureGateProvider);
    final status = ref.read(subscriptionStatusStreamProvider).value;
    if (status != null) {
      final decision = gate.evaluate(
        feature: FeatureKey.imageGeneration,
        state: status.state,
        plan: status.plan.tier,
      );
      // Deny routes to Restricted (handled by the router redirect on revoked
      // state); Limited is delegated to usage allowance resolution, and when
      // the allowance is depleted we open the Paywall.
      if (decision is FeatureGateLimited &&
          !status.allowance.canGenerateImage) {
        if (!context.mounted) return;
        context.go(AppRoutes.paywall);
        return;
      }
    }
    final command = ref.read(requestImageGenerationCommandProvider);
    await command.requestImage(
      vocabularyExpression: identifier,
      idempotencyKey: IdempotencyKey(_uuidGenerator.v4()),
    );
  }

  Future<void> _retry(
    WidgetRef ref,
    GenerationTargetKind target,
  ) async {
    final command = ref.read(retryGenerationCommandProvider);
    final response = await command.retry(
      vocabularyExpression: identifier,
      target: target,
      idempotencyKey: IdempotencyKey(_uuidGenerator.v4()),
    );
    // The UI observes new status through the reader stream; the response
    // envelope itself is not used to derive completed state (spec 013
    // command binding rule).
    if (response is CommandResponseRejected) {
      // Silent for now; Phase 7 will surface a SnackBar using the envelope
      // user-facing message.
    }
  }

  String _explanationLabel(ExplanationGenerationStatus status) {
    return switch (status) {
      ExplanationGenerationStatus.pending => '解説を準備しています',
      ExplanationGenerationStatus.running => '解説を生成しています',
      ExplanationGenerationStatus.retryScheduled => '再試行を待機しています',
      ExplanationGenerationStatus.timedOut => 'タイムアウトしました',
      ExplanationGenerationStatus.succeeded => '完了しました',
      ExplanationGenerationStatus.failedFinal => '生成できませんでした',
      ExplanationGenerationStatus.deadLettered => '生成できませんでした',
    };
  }

  String _imageLabel(ImageGenerationStatus status) {
    return switch (status) {
      ImageGenerationStatus.pending => '画像を準備しています',
      ImageGenerationStatus.running => '画像を生成しています',
      ImageGenerationStatus.retryScheduled => '再試行を待機しています',
      ImageGenerationStatus.timedOut => 'タイムアウトしました',
      ImageGenerationStatus.succeeded => '完了しました',
      ImageGenerationStatus.failedFinal => '生成できませんでした',
      ImageGenerationStatus.deadLettered => '生成できませんでした',
    };
  }
}
