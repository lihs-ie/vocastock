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
import '../theme/widgets/vs_illustration_panel.dart';
import '../theme/widgets/vs_section_label.dart';
import '../theme/widgets/vs_spinner.dart';
import '../theme/widgets/vs_wordmark.dart';

/// Spec 013 canonical `VocabularyExpressionDetail` screen.
///
/// Visual reference: `screens.jsx` `VSDetail` status-only subset (spec 013
/// `allowsCompletedPayload = false`). Explanation body / image payload are
/// never rendered here; the screen aggregates generation status and routes
/// into the completed-only detail screens via CTAs.
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
      body: SafeArea(
        child: entry == null
            ? const Center(
                child: VsSpinner(key: Key('detail.loading'), size: 20),
              )
            : _DetailBody(
                entry: entry,
                onOpenExplanation: () => context.go(
                  '${AppRoutes.explanationPrefix}/'
                  '${entry.currentExplanation!.value}',
                ),
                onOpenImage: () => context.go(
                  '${AppRoutes.imagePrefix}/${entry.currentImage!.value}',
                ),
                onRequestImage: () => unawaited(_requestImage(context, ref)),
                onRetryExplanation: () => unawaited(
                  _retry(ref, GenerationTargetKind.explanation),
                ),
                onRetryImage: () =>
                    unawaited(_retry(ref, GenerationTargetKind.image)),
                onBack: () => context.go(AppRoutes.catalog),
              ),
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

  Future<void> _retry(WidgetRef ref, GenerationTargetKind target) async {
    final command = ref.read(retryGenerationCommandProvider);
    final response = await command.retry(
      vocabularyExpression: identifier,
      target: target,
      idempotencyKey: IdempotencyKey(_uuidGenerator.v4()),
    );
    if (response is CommandResponseRejected) {
      // Silent for now; Phase 7 will surface a SnackBar using the envelope
      // user-facing message.
    }
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.entry,
    required this.onOpenExplanation,
    required this.onOpenImage,
    required this.onRequestImage,
    required this.onRetryExplanation,
    required this.onRetryImage,
    required this.onBack,
  });

  final VocabularyExpressionEntry entry;
  final VoidCallback onOpenExplanation;
  final VoidCallback onOpenImage;
  final VoidCallback onRequestImage;
  final VoidCallback onRetryExplanation;
  final VoidCallback onRetryImage;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _DetailHeader(onBack: onBack),
        const Divider(thickness: 0.5, height: 0.5),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
              _VocabularyMeta(entry: entry),
              const SizedBox(height: 24),
              _ImagePanelSection(
                entry: entry,
                onOpenImage: onOpenImage,
                onRequestImage: onRequestImage,
                onRetryImage: onRetryImage,
              ),
              const SizedBox(height: 28),
              _StatusRow(
                keyValue: 'detail.explanation-status',
                title: '解説',
                label: _explanationLabel(entry.explanationStatus),
                tone: _explanationChipTone(entry.explanationStatus),
              ),
              const SizedBox(height: 12),
              if (entry.hasCompletedExplanation)
                ElevatedButton(
                  key: const Key('detail.open-explanation'),
                  onPressed: onOpenExplanation,
                  child: const Text('解説を読む'),
                ),
              if (_isExplanationFailed(entry.explanationStatus))
                OutlinedButton(
                  key: const Key('detail.retry-explanation'),
                  onPressed: onRetryExplanation,
                  child: const Text('解説生成を再試行'),
                ),
              const SizedBox(height: 28),
              _StatusRow(
                keyValue: 'detail.image-status',
                title: '画像',
                label: _imageLabel(entry.imageStatus),
                tone: _imageChipTone(entry.imageStatus),
              ),
              const SizedBox(height: 28),
              const Divider(thickness: 0.5, height: 0.5),
              const SizedBox(height: 20),
              const VsSectionLabel('習熟度 · LearningState'),
              const SizedBox(height: 10),
              _ProficiencyRow(theme: theme),
            ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.chevron_left, size: 18),
            label: const Text('単語帳'),
            style: TextButton.styleFrom(
              foregroundColor: VsTokens.inkSoft,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              textStyle: const TextStyle(
                fontFamily: VsTokens.sans,
                fontSize: 14,
              ),
            ),
          ),
          const VsWordmark(size: 13),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.star_border,
              size: 18,
              color: VsTokens.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}

class _VocabularyMeta extends StatelessWidget {
  const _VocabularyMeta({required this.entry});
  final VocabularyExpressionEntry entry;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Flexible(
          child: Text(
            entry.text,
            key: const Key('detail.text'),
            style: const TextStyle(
              fontFamily: VsTokens.serif,
              fontSize: 44,
              fontWeight: FontWeight.w600,
              letterSpacing: -1,
              height: 1.05,
              color: VsTokens.ink,
            ),
          ),
        ),
      ],
    );
  }
}

class _ImagePanelSection extends StatelessWidget {
  const _ImagePanelSection({
    required this.entry,
    required this.onOpenImage,
    required this.onRequestImage,
    required this.onRetryImage,
  });

  final VocabularyExpressionEntry entry;
  final VoidCallback onOpenImage;
  final VoidCallback onRequestImage;
  final VoidCallback onRetryImage;

  @override
  Widget build(BuildContext context) {
    if (entry.hasCompletedImage) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(VsTokens.radiusMd),
            child: VsIllustrationPanel(
              seed: entry.identifier.value.length,
              label: entry.text,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            key: const Key('detail.open-image'),
            onPressed: onOpenImage,
            child: const Text('画像を拡大'),
          ),
        ],
      );
    }
    return _ImagePlaceholder(
      entry: entry,
      onRequestImage: onRequestImage,
      onRetryImage: onRetryImage,
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({
    required this.entry,
    required this.onRequestImage,
    required this.onRetryImage,
  });

  final VocabularyExpressionEntry entry;
  final VoidCallback onRequestImage;
  final VoidCallback onRetryImage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = entry.imageStatus;
    final isRunning = status == ImageGenerationStatus.running ||
        status == ImageGenerationStatus.retryScheduled;
    final isFailed = status == ImageGenerationStatus.failedFinal ||
        status == ImageGenerationStatus.deadLettered ||
        status == ImageGenerationStatus.timedOut;

    final Widget leading;
    if (isRunning) {
      leading = const VsSpinner(size: 18);
    } else if (isFailed) {
      leading = const Icon(Icons.close, size: 20, color: VsTokens.err);
    } else {
      leading = const Icon(
        Icons.image_outlined,
        size: 20,
        color: VsTokens.inkMute,
      );
    }

    final String title;
    final String description;
    if (isRunning) {
      title = '画像を生成中...';
      description = '中間結果は表示されません';
    } else if (isFailed) {
      title = '画像生成に失敗しました';
      description = '前回の画像がなければ空のまま';
    } else if (status == ImageGenerationStatus.pending) {
      title = '画像を準備中';
      description = '解説完了後に画像を依頼できます';
    } else {
      title = '視覚イメージを生成';
      description = '解説が完了すると画像生成を依頼できます';
    }

    final canRequest = entry.hasCompletedExplanation && !isRunning;
    final buttonKey = isFailed
        ? const Key('detail.retry-image')
        : const Key('detail.request-image');
    final buttonText = isFailed ? '再試行' : '生成';
    final buttonOnPressed =
        !canRequest && !isFailed ? null : (isFailed ? onRetryImage : onRequestImage);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VsTokens.paperSoft,
        border: Border.all(color: VsTokens.inkHair),
        borderRadius: BorderRadius.circular(VsTokens.radiusMd),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: VsTokens.paperDeep,
              borderRadius: BorderRadius.circular(VsTokens.radiusSm),
            ),
            alignment: Alignment.center,
            child: leading,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: VsTokens.inkMute,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (isRunning)
            const SizedBox.shrink()
          else
            TextButton.icon(
              key: buttonKey,
              onPressed: buttonOnPressed,
              icon: Icon(
                isFailed ? Icons.refresh : Icons.auto_awesome,
                size: 14,
              ),
              label: Text(buttonText),
              style: TextButton.styleFrom(
                backgroundColor: VsTokens.ink,
                foregroundColor: VsTokens.paper,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                ),
                textStyle: const TextStyle(
                  fontFamily: VsTokens.sans,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
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
    return Row(
      key: Key(keyValue),
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(width: 12),
        VsChip(label: label, tone: tone),
      ],
    );
  }
}

class _ProficiencyRow extends StatelessWidget {
  const _ProficiencyRow({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    const levels = <_ProficiencyLevel>[
      _ProficiencyLevel(label: '学習中', color: VsTokens.profLearning),
      _ProficiencyLevel(label: '習得', color: VsTokens.profLearned),
      _ProficiencyLevel(label: '定着', color: VsTokens.profInternalized),
      _ProficiencyLevel(label: '自在', color: VsTokens.profFluent),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          key: const Key('vocabulary-expression-detail.proficiency-row'),
          children: <Widget>[
            for (final level in levels) ...<Widget>[
              Expanded(
                child: Opacity(
                  opacity: 0.55,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: VsTokens.paperSoft,
                      border: Border.all(color: VsTokens.inkHair),
                      borderRadius:
                          BorderRadius.circular(VsTokens.radiusSm),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      level.label,
                      style: TextStyle(
                        fontFamily: VsTokens.sans,
                        fontSize: 11,
                        color: level.color,
                      ),
                    ),
                  ),
                ),
              ),
              if (level != levels.last) const SizedBox(width: 4),
            ],
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          '習熟度の更新はサーバー API の準備中です。',
          key: Key('vocabulary-expression-detail.proficiency-note'),
          style: TextStyle(
            fontFamily: VsTokens.sans,
            fontSize: 10,
            fontStyle: FontStyle.italic,
            color: VsTokens.inkMute,
          ),
        ),
      ],
    );
  }
}

@immutable
class _ProficiencyLevel {
  const _ProficiencyLevel({required this.label, required this.color});
  final String label;
  final Color color;
}

bool _isExplanationFailed(ExplanationGenerationStatus status) =>
    status == ExplanationGenerationStatus.failedFinal ||
    status == ExplanationGenerationStatus.deadLettered;

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
