import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_bindings.dart';
import '../../domain/identifier/identifier.dart';
import '../theme/vs_tokens.dart';
import '../theme/widgets/vs_illustration_panel.dart';
import '../theme/widgets/vs_skeleton.dart';

/// Spec 013 canonical `ImageDetail` screen.
///
/// Visual reference: `screens.jsx` `DetailImagePanel` enlarged. A
/// full-width illustration panel fills the upper portion of the screen;
/// description and asset reference follow underneath. Null payloads pop
/// back without flashing (`allowsCompletedPayload = true`).
class ImageDetailScreen extends ConsumerWidget {
  const ImageDetailScreen({required this.identifier, super.key});

  final VisualImageIdentifier identifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(imageDetailFutureProvider(identifier));
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final panelHeight = size.height * 0.55;

    return Scaffold(
      backgroundColor: VsTokens.paper,
      body: SafeArea(
        child: detailAsync.when(
          data: (detail) {
            if (detail == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) context.pop();
              });
              return const SizedBox.shrink();
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left),
                    color: VsTokens.inkSoft,
                    onPressed: () => context.pop(),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  key: const Key('image-detail.asset'),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(VsTokens.radiusLg),
                    border: Border.all(color: VsTokens.inkHair),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: VsIllustrationPanel(
                    seed: identifier.value.length,
                    label: '視覚イメージ',
                    height: panelHeight,
                    borderRadius: VsTokens.radiusLg,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    detail.description,
                    key: const Key('image-detail.description'),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.7,
                      color: VsTokens.ink,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    detail.assetReference,
                    style: const TextStyle(
                      fontFamily: VsTokens.mono,
                      fontSize: 10,
                      letterSpacing: 0.3,
                      color: VsTokens.inkMute,
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const _LoadingBody(),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: VsTokens.accentSoft,
                  borderRadius: BorderRadius.circular(VsTokens.radiusMd),
                ),
                child: Text(
                  'エラーが発生しました: $error',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: VsTokens.err,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const Key('image-detail.loading'),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      children: const <Widget>[
        VsSkeleton(height: 280, radius: VsTokens.radiusLg),
        SizedBox(height: 20),
        VsSkeleton(),
        SizedBox(height: 6),
        VsSkeleton(width: 200),
      ],
    );
  }
}
