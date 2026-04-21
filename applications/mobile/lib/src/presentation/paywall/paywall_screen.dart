import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../app_bindings.dart';
import '../../application/envelope/command_response_envelope.dart';
import '../../domain/identifier/identifier.dart';
import '../../domain/subscription/plan.dart';
import '../router/router.dart';
import '../theme/vs_tokens.dart';
import '../theme/widgets/vs_chip.dart';

/// Spec 013 canonical `Paywall` screen (full-screen route group).
///
/// Visual reference: `screens.jsx` `VSPaywall`. Hero has a
/// `PREMIUM GENERATION` crown chip, a Mincho 28 two-line headline
/// ("多義の深さに、画像を添えて。") with accent highlight on 画像, and a muted
/// tagline. The plan list exposes Free / Standard / Pro cards with
/// selectable state; the selected plan drives the upgrade CTA copy.
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  static const Uuid _uuidGenerator = Uuid();
  PlanCode _selected = PlanCode.proMonthly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentPlan = ref
            .watch(subscriptionStatusStreamProvider)
            .value
            ?.plan ??
        PlanCode.free;

    return Scaffold(
      backgroundColor: VsTokens.paper,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
            const _PaywallHeader(),
            const SizedBox(height: 24),
            _PlanCard(
              key: const Key('paywall.plan.free'),
              plan: PlanCode.free,
              label: 'Free',
              price: '¥0',
              sub: '基本',
              quota: '10 語 / 月',
              features: const <String>[
                '基本的な解説',
                '画像生成なし',
                '月 10 語まで',
              ],
              isCurrent: currentPlan == PlanCode.free,
              isSelected: _selected == PlanCode.free,
              onTap: () => setState(() => _selected = PlanCode.free),
            ),
            const SizedBox(height: 8),
            _PlanCard(
              key: const Key('paywall.plan.standard'),
              plan: PlanCode.standardMonthly,
              label: 'Standard',
              price: '¥580',
              sub: '月額',
              quota: '100 語 / 月',
              features: const <String>[
                'AI解説 完全版',
                '画像生成: 月 30 枚',
                '月 100 語まで',
              ],
              isCurrent: currentPlan == PlanCode.standardMonthly,
              isSelected: _selected == PlanCode.standardMonthly,
              onTap: () =>
                  setState(() => _selected = PlanCode.standardMonthly),
            ),
            const SizedBox(height: 8),
            _PlanCard(
              key: const Key('paywall.plan.pro'),
              plan: PlanCode.proMonthly,
              label: 'Pro',
              price: '¥1,280',
              sub: '月額',
              quota: '無制限',
              features: const <String>[
                'AI解説 完全版',
                '画像生成: 無制限',
                '登録数 無制限',
                '優先キュー',
              ],
              isCurrent: currentPlan == PlanCode.proMonthly,
              isSelected: _selected == PlanCode.proMonthly,
              onTap: () => setState(() => _selected = PlanCode.proMonthly),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _selected == PlanCode.free || _selected == currentPlan
                  ? null
                  : () => unawaited(_purchase(_selected)),
              style: ElevatedButton.styleFrom(
                backgroundColor: VsTokens.accent,
                foregroundColor: VsTokens.paper,
                disabledBackgroundColor: VsTokens.paperDeep,
                disabledForegroundColor: VsTokens.inkMute,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(VsTokens.radiusMd)),
                ),
                textStyle: const TextStyle(
                  fontFamily: VsTokens.sans,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              icon: const Icon(Icons.bolt, size: 16),
              label: Text('${_planLabel(_selected)} にアップグレード'),
            ),
            const SizedBox(height: 12),
            Text(
              'purchase state: initiated → submitted → verifying → verified\n'
              'verified になるまで premium 機能は解放されません。',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                height: 1.5,
                color: VsTokens.inkMute,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                key: const Key('paywall.status-link'),
                onPressed: () => context.go(AppRoutes.subscriptionStatus),
                child: const Text('サブスクリプション状態を確認'),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  Future<void> _purchase(PlanCode plan) async {
    final command = ref.read(requestPurchaseCommandProvider);
    final response = await command.purchase(
      plan: plan,
      idempotencyKey: IdempotencyKey(_uuidGenerator.v4()),
    );
    if (!mounted) return;
    final (message, key) = switch (response) {
      CommandResponseAccepted() => (
          '${_planLabel(plan)} にアップグレードしました。',
          const Key('paywall.purchase.accepted'),
        ),
      CommandResponseRejected(:final message) => (
          'アップグレードできませんでした: ${message.text}',
          const Key('paywall.purchase.rejected'),
        ),
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        key: key,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        content: Text(message),
      ),
    );
  }
}

class _PaywallHeader extends StatelessWidget {
  const _PaywallHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: <Widget>[
        const VsChip(
          label: 'PREMIUM GENERATION',
          tone: VsChipTone.accent,
          icon: Icon(Icons.emoji_events),
        ),
        const SizedBox(height: 14),
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(
              fontFamily: VsTokens.serif,
              fontSize: 28,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.6,
              height: 1.2,
              color: VsTokens.ink,
            ),
            children: <InlineSpan>[
              TextSpan(text: '多義の深さに、\n'),
              TextSpan(
                text: '画像',
                style: TextStyle(color: VsTokens.accent),
              ),
              TextSpan(text: 'を添えて。'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'AIによる視覚イメージ生成で、英単語の意味が記憶に定着します。',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: VsTokens.inkSoft,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.label,
    required this.price,
    required this.sub,
    required this.quota,
    required this.features,
    required this.isCurrent,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final PlanCode plan;
  final String label;
  final String price;
  final String sub;
  final String quota;
  final List<String> features;
  final bool isCurrent;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = isSelected ? VsTokens.ink : VsTokens.paperSoft;
    final foreground = isSelected ? VsTokens.paper : VsTokens.ink;
    final borderColor = isSelected ? VsTokens.ink : VsTokens.inkHair;
    final mutedColor = isSelected ? VsTokens.paperDeep : VsTokens.inkMute;
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(VsTokens.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(VsTokens.radiusMd),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          decoration: BoxDecoration(
            border: Border.all(
              color: borderColor,
              width: isSelected ? 1 : 0.5,
            ),
            borderRadius: BorderRadius.circular(VsTokens.radiusMd),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: VsTokens.serif,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: foreground,
                    ),
                  ),
                  if (isCurrent) ...<Widget>[
                    const SizedBox(width: 8),
                    VsChip(
                      label: '現在のプラン',
                      tone: isSelected ? VsChipTone.dark : VsChipTone.accent,
                    ),
                  ],
                  const Spacer(),
                  Text(
                    price,
                    style: TextStyle(
                      fontFamily: VsTokens.serif,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: foreground,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    sub,
                    style: TextStyle(
                      fontFamily: VsTokens.sans,
                      fontSize: 10,
                      color: mutedColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'QUOTA · ${quota.toUpperCase()}',
                style: TextStyle(
                  fontFamily: VsTokens.mono,
                  fontSize: 10,
                  letterSpacing: 0.5,
                  color: mutedColor,
                ),
              ),
              const SizedBox(height: 12),
              for (final feature in features)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.check,
                        size: 12,
                        color: isSelected ? VsTokens.paper : VsTokens.ok,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontFamily: VsTokens.sans,
                            fontSize: 11,
                            color: isSelected
                                ? VsTokens.paper.withAlpha(230)
                                : VsTokens.ink.withAlpha(200),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String _planLabel(PlanCode plan) => switch (plan) {
      PlanCode.free => 'Free',
      PlanCode.standardMonthly => 'Standard',
      PlanCode.proMonthly => 'Pro',
    };
