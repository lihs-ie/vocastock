import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../app_bindings.dart';
import '../../domain/identifier/identifier.dart';
import '../../domain/status/subscription_state.dart';
import '../../domain/subscription/entitlement.dart';
import '../../domain/subscription/plan.dart';
import '../router/router.dart';
import '../theme/vs_tokens.dart';
import '../theme/widgets/vs_chip.dart';
import '../theme/widgets/vs_screen_scaffold.dart';
import '../theme/widgets/vs_spinner.dart';

/// Spec 013 canonical `SubscriptionStatus` screen.
///
/// Renders the four concepts in separate sections per constitution §VI:
///   - subscription state
///   - plan code
///   - entitlement bundle
///   - usage allowance
/// plus a recovery section with restore CTA.
class SubscriptionStatusScreen extends ConsumerWidget {
  const SubscriptionStatusScreen({super.key});

  static const Uuid _uuidGenerator = Uuid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(subscriptionStatusStreamProvider);
    final view = statusAsync.value;
    if (view == null) {
      return const Scaffold(
        backgroundColor: VsTokens.paper,
        body: Center(child: VsSpinner(size: 18)),
      );
    }

    return VsScreenScaffold(
      eyebrow: 'SUBSCRIPTION',
      title: 'サブスクリプション',
      caption: 'プラン・権利・残量を一覧で確認します。',
      trailing: IconButton(
        key: const Key('subscription-status.logout'),
        icon: const Icon(Icons.logout),
        onPressed: () async {
          await ref.read(logoutCommandProvider).signOut();
          if (!context.mounted) return;
          context.go(AppRoutes.login);
        },
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: <Widget>[
          _SectionCard(
            keyValue: 'subscription-status.state',
            label: '状態',
            value: _stateLabel(view.state),
            tone: _stateTone(view.state),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            keyValue: 'subscription-status.plan',
            label: 'プラン',
            value: _planLabel(view.plan),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            keyValue: 'subscription-status.entitlement',
            label: '利用可能な機能',
            value: _entitlementLabel(view.entitlement),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            keyValue: 'subscription-status.allowance',
            label: '今月の残量',
            value:
                '解説 ${view.allowance.remainingExplanationGenerations} / '
                '画像 ${view.allowance.remainingImageGenerations}',
          ),
          const SizedBox(height: 24),
          Text(
            '購入履歴を復元',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            key: const Key('subscription-status.restore'),
            onPressed: () {
              final command = ref.read(requestRestorePurchaseCommandProvider);
              unawaited(
                command.restore(
                  idempotencyKey: IdempotencyKey(_uuidGenerator.v4()),
                ),
              );
            },
            child: const Text('復元する'),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.keyValue,
    required this.label,
    required this.value,
    this.tone,
  });

  final String keyValue;
  final String label;
  final String value;
  final VsChipTone? tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: Key(keyValue),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: VsTokens.paperSoft,
        borderRadius: BorderRadius.circular(VsTokens.radiusMd),
        border: Border.all(color: VsTokens.inkHair),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: theme.textTheme.labelMedium),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ),
          if (tone != null) VsChip(label: _chipLabel(), tone: tone!),
        ],
      ),
    );
  }

  String _chipLabel() {
    switch (tone!) {
      case VsChipTone.ok:
        return 'ACTIVE';
      case VsChipTone.accent:
        return 'SYNC';
      case VsChipTone.warn:
        return 'GRACE';
      case VsChipTone.err:
        return 'BLOCKED';
      case VsChipTone.neutral:
      case VsChipTone.dark:
        return value;
    }
  }
}

String _stateLabel(SubscriptionState state) => switch (state) {
      SubscriptionState.active => '有効',
      SubscriptionState.grace => '猶予期間',
      SubscriptionState.pendingSync => '同期中',
      SubscriptionState.expired => '期限切れ',
      SubscriptionState.revoked => '無効',
    };

VsChipTone _stateTone(SubscriptionState state) => switch (state) {
      SubscriptionState.active => VsChipTone.ok,
      SubscriptionState.grace => VsChipTone.warn,
      SubscriptionState.pendingSync => VsChipTone.accent,
      SubscriptionState.expired => VsChipTone.err,
      SubscriptionState.revoked => VsChipTone.err,
    };

String _planLabel(PlanCode plan) => switch (plan) {
      PlanCode.free => '無料',
      PlanCode.standardMonthly => 'スタンダード (月額)',
      PlanCode.proMonthly => 'プロ (月額)',
    };

String _entitlementLabel(EntitlementBundle bundle) => switch (bundle) {
      EntitlementBundle.freeBasic => '基本機能',
      EntitlementBundle.premiumGeneration => 'プレミアム生成機能',
    };
