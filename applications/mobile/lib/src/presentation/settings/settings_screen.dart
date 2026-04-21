import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_bindings.dart';
import '../../domain/subscription/plan.dart';
import '../detail/detail_layout_preference.dart';
import '../router/router.dart';
import '../theme/vs_tokens.dart';
import '../theme/widgets/vs_section_label.dart';
import '../theme/widgets/vs_settings_row.dart';
import '../theme/widgets/vs_wordmark.dart';

/// Full Settings screen mirroring `screens.jsx` `VSSettings`.
///
/// Replaces `/subscription` as the fourth AppShell branch. Rows group
/// account, generation preferences, and app configuration; the account
/// section links into `/subscription` while the generation section owns
/// the `detailLayoutProvider` picker.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final layout = ref.watch(detailLayoutProvider);
    final subscription = ref.watch(subscriptionStatusStreamProvider).value;

    return Scaffold(
      backgroundColor: VsTokens.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const VsWordmark(size: 13),
                  const SizedBox(height: 8),
                  Text('設定', style: theme.textTheme.displaySmall),
                ],
              ),
            ),
            _SectionGroup(
              title: 'アカウント',
              child: Column(
                children: <Widget>[
                  VsSettingsRow(
                    key: const Key('settings.row.profile'),
                    icon: Icons.favorite_border,
                    label: 'プロフィール',
                    sub: '学習者',
                    onTap: () => _showUnsupported(context, 'プロフィール'),
                  ),
                  VsSettingsRow(
                    key: const Key('settings.row.subscription'),
                    icon: Icons.emoji_events_outlined,
                    label: 'サブスクリプション',
                    sub: _subscriptionSubtitle(subscription?.plan),
                    onTap: () => context.go(AppRoutes.subscriptionStatus),
                    isLast: true,
                  ),
                ],
              ),
            ),
            _SectionGroup(
              title: '生成設定',
              child: Column(
                children: <Widget>[
                  VsSettingsRow(
                    key: const Key('settings.row.detail-layout'),
                    icon: Icons.auto_awesome,
                    label: 'AI解説のレイアウト',
                    sub: layout.label,
                    onTap: () => _pickDetailLayout(context, ref, layout),
                  ),
                  VsSettingsRow(
                    key: const Key('settings.row.image-style'),
                    icon: Icons.image_outlined,
                    label: '画像スタイル',
                    sub: 'イラストレーション',
                    onTap: () => _showUnsupported(context, '画像スタイル'),
                  ),
                  VsSettingsRow(
                    key: const Key('settings.row.notifications'),
                    icon: Icons.bolt_outlined,
                    label: '生成通知',
                    sub: '完了時にプッシュ',
                    onTap: () => _showUnsupported(context, '生成通知'),
                    isLast: true,
                  ),
                ],
              ),
            ),
            _SectionGroup(
              title: 'アプリ',
              child: Column(
                children: <Widget>[
                  VsSettingsRow(
                    key: const Key('settings.row.export'),
                    icon: Icons.menu_book_outlined,
                    label: 'データエクスポート',
                    onTap: () => _showUnsupported(context, 'データエクスポート'),
                  ),
                  VsSettingsRow(
                    key: const Key('settings.row.locale'),
                    icon: Icons.settings_outlined,
                    label: '言語・表記',
                    sub: '日本語',
                    onTap: () => _showUnsupported(context, '言語・表記'),
                    isLast: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _subscriptionSubtitle(PlanCode? plan) {
    switch (plan) {
      case PlanCode.free:
      case null:
        return 'Free プラン';
      case PlanCode.standardMonthly:
        return 'Standard (月額)';
      case PlanCode.proMonthly:
        return 'Pro (月額)';
    }
  }

  void _showUnsupported(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name は未対応です')),
    );
  }

  Future<void> _pickDetailLayout(
    BuildContext context,
    WidgetRef ref,
    DetailLayout current,
  ) async {
    final selected = await showModalBottomSheet<DetailLayout>(
      context: context,
      backgroundColor: VsTokens.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(VsTokens.radiusLg),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const VsSectionLabel('AI解説のレイアウト'),
                const SizedBox(height: 12),
                for (final option in DetailLayout.values)
                  ListTile(
                    key: Key('settings.layout.${option.name}'),
                    title: Text(option.label),
                    trailing: current == option
                        ? const Icon(Icons.check, color: VsTokens.accent)
                        : null,
                    onTap: () => Navigator.of(context).pop(option),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (selected != null) {
      ref.read(detailLayoutProvider.notifier).set(selected);
    }
  }
}

class _SectionGroup extends StatelessWidget {
  const _SectionGroup({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: VsSectionLabel(title),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: VsTokens.paperSoft,
              border: Border.all(color: VsTokens.inkHair),
              borderRadius: BorderRadius.circular(VsTokens.radiusMd),
            ),
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
        ],
      ),
    );
  }
}
