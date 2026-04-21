import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../app_bindings.dart';
import '../../domain/identifier/identifier.dart';
import '../../domain/subscription/plan.dart';
import '../router/router.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('プレミアムを利用する')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '生成数を増やすには、プランを購入してください',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          _PlanCard(
            key: const Key('paywall.plan.standard'),
            plan: PlanCode.standardMonthly,
            title: 'スタンダード (月額)',
            description: '解説 100 / 画像 30',
            onPurchase: () => unawaited(
              _purchase(ref, PlanCode.standardMonthly),
            ),
          ),
          const SizedBox(height: 16),
          _PlanCard(
            key: const Key('paywall.plan.pro'),
            plan: PlanCode.proMonthly,
            title: 'プロ (月額)',
            description: '解説 300 / 画像 100',
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
    required this.plan,
    required this.title,
    required this.description,
    required this.onPurchase,
    super.key,
  });

  final PlanCode plan;
  final String title;
  final String description;
  final VoidCallback onPurchase;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onPurchase,
              child: const Text('このプランを購入'),
            ),
          ],
        ),
      ),
    );
  }
}
