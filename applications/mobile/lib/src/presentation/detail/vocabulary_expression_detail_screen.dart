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
import '../theme/vs_tokens.dart';
import '../theme/widgets/vs_chip.dart';
import '../theme/widgets/vs_spinner.dart';

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
      backgroundColor: VsTokens.paper,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context.go(AppRoutes.catalog),
        ),
        title: const Text('単語の詳細'),
      ),
      body: entry == null
          ? const Center(
              child: VsSpinner(
                key: Key('detail.loading'),
                size: 20,
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
    final theme = Theme.of(context);
    final canRequestImage =
        entry.hasCompletedExplanation && !entry.hasCompletedImage;
    final explanationFailed = _isExplanationFailed(entry.explanationStatus);
    final imageFailed = _isImageFailed(entry.imageStatus);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      children: <Widget>[
        Text(
          entry.text,
          key: const Key('detail.text'),
          style: theme.textTheme.displayMedium,
        ),
        const SizedBox(height: 32),
        _StatusSection(
          keyValue: 'detail.explanation-status',
          title: '解説',
          label: _explanationLabel(entry.explanationStatus),
          tone: _explanationChipTone(entry.explanationStatus),
        ),
        const SizedBox(height: 12),
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
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Divider(),
        ),
        _StatusSection(
          keyValue: 'detail.image-status',
          title: '画像',
          label: _imageLabel(entry.imageStatus),
          tone: _imageChipTone(entry.imageStatus),
        ),
        const SizedBox(height: 12),
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

  bool _isExplanationFailed(ExplanationGenerationStatus status) {
    return status == ExplanationGenerationStatus.failedFinal ||
        status == ExplanationGenerationStatus.deadLettered;
  }

  bool _isImageFailed(ImageGenerationStatus status) {
    return status == ImageGenerationStatus.failedFinal ||
        status == ImageGenerationStatus.deadLettered;
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

  VsChipTone _explanationChipTone(ExplanationGenerationStatus status) {
    return switch (status) {
      ExplanationGenerationStatus.succeeded => VsChipTone.ok,
      ExplanationGenerationStatus.pending ||
      ExplanationGenerationStatus.running ||
      ExplanationGenerationStatus.retryScheduled =>
        VsChipTone.accent,
      ExplanationGenerationStatus.timedOut ||
      ExplanationGenerationStatus.failedFinal ||
      ExplanationGenerationStatus.deadLettered =>
        VsChipTone.err,
    };
  }

  VsChipTone _imageChipTone(ImageGenerationStatus status) {
    return switch (status) {
      ImageGenerationStatus.succeeded => VsChipTone.ok,
      ImageGenerationStatus.pending ||
      ImageGenerationStatus.running ||
      ImageGenerationStatus.retryScheduled =>
        VsChipTone.accent,
      ImageGenerationStatus.timedOut ||
      ImageGenerationStatus.failedFinal ||
      ImageGenerationStatus.deadLettered =>
        VsChipTone.err,
    };
  }
}

class _StatusSection extends StatelessWidget {
  const _StatusSection({
    required this.keyValue,
    required this.title,
    required this.label,
    required this.tone,
  });

  final String keyValue;
  final String title;
  final String label;
  final VsChipTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      key: Key(keyValue),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(title, style: theme.textTheme.headlineSmall),
            const SizedBox(width: 10),
            VsChip(label: label, tone: tone),
          ],
        ),
      ],
    );
  }
}
