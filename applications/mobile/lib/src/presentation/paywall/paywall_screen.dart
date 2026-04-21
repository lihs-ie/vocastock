import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../app_bindings.dart';
import '../../domain/identifier/identifier.dart';
import '../../domain/subscription/plan.dart';
import '../router/router.dart';
import '../theme/vs_tokens.dart';
import '../theme/widgets/vs_chip.dart';
import '../theme/widgets/vs_screen_scaffold.dart';

/// Spec 013 canonical `Paywall` screen (full-screen route group).
///
/// Lists paid plan options from spec 014 product catalog. Does NOT display
/// completed payload; purchase state progresses through the underlying
/// stub. Offers a link to the canonical `SubscriptionStatus` screen so the
/// learner can review state in detail.
class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  static const Uuid _uuidGenerator = Uuid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return VsScreenScaffold(
      eyebrow: 'SUBSCRIPTION',
      title: 'プランを選ぶ',
      caption: '生成可能数を増やし、より深く多義を掘り下げる。',
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              '月額プランはいつでも解約できます。',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: VsTokens.inkMute,
              ),
            ),
            const SizedBox(height: 24),
            _PlanCard(
              key: const Key('paywall.plan.standard'),
              title: 'スタンダード',
              priceLine: '¥ 480 / 月',
              features: const <String>['解説 100 / 月', '画像 30 / 月'],
              accentTag: 'STANDARD',
              onPurchase: () => unawaited(
                _purchase(ref, PlanCode.standardMonthly),
              ),
            ),
            const SizedBox(height: 14),
            _PlanCard(
              key: const Key('paywall.plan.pro'),
              title: 'プロ',
              priceLine: '¥ 1,280 / 月',
              features: const <String>['解説 300 / 月', '画像 100 / 月'],
              accentTag: 'PRO',
              recommended: true,
              onPurchase: () => unawaited(_purchase(ref, PlanCode.proMonthly)),
            ),
            const SizedBox(height: 24),
            TextButton(
              key: const Key('paywall.status-link'),
              onPressed: () => context.go(AppRoutes.subscriptionStatus),
              child: const Text('サブスクリプション状態を確認'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _purchase(WidgetRef ref, PlanCode plan) async {
    final command = ref.read(requestPurchaseCommandProvider);
    await command.purchase(
      plan: plan,
      idempotencyKey: IdempotencyKey(_uuidGenerator.v4()),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.priceLine,
    required this.features,
    required this.accentTag,
    required this.onPurchase,
    this.recommended = false,
    super.key,
  });

  final String title;
  final String priceLine;
  final List<String> features;
  final String accentTag;
  final bool recommended;
  final VoidCallback onPurchase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: VsTokens.paperSoft,
        borderRadius: BorderRadius.circular(VsTokens.radiusLg),
        border: Border.all(
          color: recommended ? VsTokens.accent : VsTokens.inkHair,
          width: recommended ? 1.2 : 0.5,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              VsChip(
                label: accentTag,
                tone: recommended ? VsChipTone.accent : VsChipTone.neutral,
              ),
              if (recommended) ...<Widget>[
                const SizedBox(width: 6),
                const VsChip(label: 'おすすめ', tone: VsChipTone.dark),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(title, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(
            priceLine,
            style: const TextStyle(
              fontFamily: VsTokens.mono,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: VsTokens.ink,
            ),
          ),
          const SizedBox(height: 14),
          for (final feature in features)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.check,
                    size: 14,
                    color: VsTokens.accent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    feature,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onPurchase,
            child: const Text('このプランを購入'),
          ),
        ],
      ),
    );
  }
}
