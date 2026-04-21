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
import '../theme/widgets/vs_section_label.dart';
import '../theme/widgets/vs_spinner.dart';
import '../theme/widgets/vs_wordmark.dart';

/// Spec 013 canonical `SubscriptionStatus` screen.
///
/// Visual reference: `screens.jsx` `VSSettings` row pattern. The four
/// concepts (state, plan, entitlement, allowance) remain in separate
/// sections per constitution §VI; each is framed by a `VsSectionLabel` and
/// rendered as a paperSoft row with an icon box. The recovery section
/// exposes the restore CTA as an accent ElevatedButton.
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: VsTokens.paper,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const VsWordmark(size: 13),
                        const SizedBox(height: 10),
                        Text(
                          'サブスクリプション',
                          style: theme.textTheme.displaySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'プラン・権利・残量を一覧で確認します。',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: VsTokens.inkMute,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    key: const Key('subscription-status.logout'),
                    icon: const Icon(Icons.logout, size: 20),
                    color: VsTokens.inkSoft,
                    onPressed: () async {
                      await ref.read(logoutCommandProvider).signOut();
                      if (!context.mounted) return;
                      context.go(AppRoutes.login);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: <Widget>[
                  const VsSectionLabel('アカウント'),
                  const SizedBox(height: 8),
                  _SectionCard(
                    rows: <_SectionRow>[
                      _SectionRow(
                        keyValue: 'subscription-status.state',
                        icon: Icons.shield_outlined,
                        label: '状態',
                        value: _stateLabel(view.state),
                        tone: _stateTone(view.state),
                      ),
                      _SectionRow(
                        keyValue: 'subscription-status.plan',
                        icon: Icons.emoji_events_outlined,
                        label: 'プラン',
                        value: _planLabel(view.plan),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const VsSectionLabel('利用可能な機能'),
                  const SizedBox(height: 8),
                  _SectionCard(
                    rows: <_SectionRow>[
                      _SectionRow(
                        keyValue: 'subscription-status.entitlement',
                        icon: Icons.auto_awesome,
                        label: '権利',
                        value: _entitlementLabel(view.entitlement),
                      ),
                      _SectionRow(
                        keyValue: 'subscription-status.allowance',
                        icon: Icons.bolt_outlined,
                        label: '今月の残量',
                        value:
                            '解説 ${view.allowance.remainingExplanationGenerations} / '
                            '画像 ${view.allowance.remainingImageGenerations}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const VsSectionLabel('購入履歴を復元'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    key: const Key('subscription-status.restore'),
                    onPressed: () {
                      final command =
                          ref.read(requestRestorePurchaseCommandProvider);
                      unawaited(
                        command.restore(
                          idempotencyKey:
                              IdempotencyKey(_uuidGenerator.v4()),
                        ),
                      );
                    },
                    child: const Text('復元する'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionRow {
  const _SectionRow({
    required this.keyValue,
    required this.icon,
    required this.label,
    required this.value,
    this.tone,
  });

  final String keyValue;
  final IconData icon;
  final String label;
  final String value;
  final VsChipTone? tone;
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.rows});
  final List<_SectionRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: VsTokens.paperSoft,
        border: Border.all(color: VsTokens.inkHair),
        borderRadius: BorderRadius.circular(VsTokens.radiusMd),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          for (var index = 0; index < rows.length; index++)
            _SectionRowWidget(
              row: rows[index],
              isLast: index == rows.length - 1,
            ),
        ],
      ),
    );
  }
}

class _SectionRowWidget extends StatelessWidget {
  const _SectionRowWidget({required this.row, required this.isLast});

  final _SectionRow row;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: Key(row.keyValue),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.transparent : VsTokens.inkHair,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: VsTokens.paperDeep,
              borderRadius: BorderRadius.circular(VsTokens.radiusSm),
            ),
            alignment: Alignment.center,
            child: Icon(row.icon, size: 15, color: VsTokens.inkSoft),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  row.label,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 1),
                Text(
                  row.value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _valueColor(row.tone),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _valueColor(VsChipTone? tone) {
  if (tone == null) return VsTokens.inkMute;
  return switch (tone) {
    VsChipTone.ok => VsTokens.ok,
    VsChipTone.warn => VsTokens.warn,
    VsChipTone.accent => VsTokens.accentDeep,
    VsChipTone.err => VsTokens.err,
    VsChipTone.neutral || VsChipTone.dark => VsTokens.inkMute,
  };
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
