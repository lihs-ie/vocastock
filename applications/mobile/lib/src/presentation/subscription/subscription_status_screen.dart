import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../app_bindings.dart';
import '../../domain/identifier/identifier.dart';
import '../../domain/status/subscription_state.dart';
import '../../domain/subscription/entitlement.dart';
import '../../domain/subscription/plan.dart';
import '../../domain/subscription/subscription_status_view.dart';

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
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('サブスクリプション状態')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StateSection(view: view),
          const Divider(),
          _PlanSection(view: view),
          const Divider(),
          _EntitlementSection(view: view),
          const Divider(),
          _AllowanceSection(view: view),
          const Divider(),
          _RecoverySection(
            onRestore: () async {
              final command = ref.read(requestRestorePurchaseCommandProvider);
              unawaited(
                command.restore(
                  idempotencyKey: IdempotencyKey(_uuidGenerator.v4()),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StateSection extends StatelessWidget {
  const _StateSection({required this.view});
  final SubscriptionStatusView view;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: const Key('subscription-status.state'),
      title: const Text('状態'),
      subtitle: Text(_stateLabel(view.state)),
    );
  }

  String _stateLabel(SubscriptionState state) => switch (state) {
        SubscriptionState.active => '有効',
        SubscriptionState.grace => '猶予期間',
        SubscriptionState.pendingSync => '同期中',
        SubscriptionState.expired => '期限切れ',
        SubscriptionState.revoked => '無効',
      };
}

class _PlanSection extends StatelessWidget {
  const _PlanSection({required this.view});
  final SubscriptionStatusView view;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: const Key('subscription-status.plan'),
      title: const Text('プラン'),
      subtitle: Text(_planLabel(view.plan)),
    );
  }

  String _planLabel(PlanCode plan) => switch (plan) {
        PlanCode.free => '無料',
        PlanCode.standardMonthly => 'スタンダード (月額)',
        PlanCode.proMonthly => 'プロ (月額)',
      };
}

class _EntitlementSection extends StatelessWidget {
  const _EntitlementSection({required this.view});
  final SubscriptionStatusView view;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: const Key('subscription-status.entitlement'),
      title: const Text('利用可能な機能'),
      subtitle: Text(_entitlementLabel(view.entitlement)),
    );
  }

  String _entitlementLabel(EntitlementBundle bundle) => switch (bundle) {
        EntitlementBundle.freeBasic => '基本機能',
        EntitlementBundle.premiumGeneration => 'プレミアム生成機能',
      };
}

class _AllowanceSection extends StatelessWidget {
  const _AllowanceSection({required this.view});
  final SubscriptionStatusView view;

  @override
  Widget build(BuildContext context) {
    final allowance = view.allowance;
    return ListTile(
      key: const Key('subscription-status.allowance'),
      title: const Text('今月の残量'),
      subtitle: Text(
        '解説: ${allowance.remainingExplanationGenerations} / '
        '画像: ${allowance.remainingImageGenerations}',
      ),
    );
  }
}

class _RecoverySection extends StatelessWidget {
  const _RecoverySection({required this.onRestore});
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          const Text('購入履歴を復元'),
          const SizedBox(height: 8),
          ElevatedButton(
            key: const Key('subscription-status.restore'),
            onPressed: onRestore,
            child: const Text('復元する'),
          ),
        ],
      ),
    );
  }
}
