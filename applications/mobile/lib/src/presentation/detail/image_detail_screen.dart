import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_bindings.dart';
import '../../domain/identifier/identifier.dart';
import '../theme/vs_tokens.dart';
import '../theme/widgets/vs_skeleton.dart';

/// Spec 013 canonical `ImageDetail` screen.
///
/// `allowsCompletedPayload = true`: renders only the completed current image.
/// Network fetching is deferred to a later phase; for now the screen renders
/// the asset reference string and description as a stable surface that can be
/// asserted in widget tests without pulling a real asset.
class ImageDetailScreen extends ConsumerWidget {
  const ImageDetailScreen({required this.identifier, super.key});

  final VisualImageIdentifier identifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(imageDetailFutureProvider(identifier));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: VsTokens.paper,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context.pop(),
        ),
        title: const Text('画像'),
      ),
      body: detailAsync.when(
        data: (detail) {
          if (detail == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) context.pop();
            });
            return const SizedBox.shrink();
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            children: <Widget>[
              Container(
                key: const Key('image-detail.asset'),
                height: 260,
                decoration: BoxDecoration(
                  color: VsTokens.paperDeep,
                  borderRadius: BorderRadius.circular(VsTokens.radiusMd),
                  border: Border.all(color: VsTokens.inkHair),
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    detail.assetReference,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: VsTokens.mono,
                      fontSize: 11,
                      color: VsTokens.inkSoft,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                detail.description,
                key: const Key('image-detail.description'),
                style: theme.textTheme.bodyLarge,
              ),
            ],
          );
        },
        loading: () => const Padding(
          key: Key('image-detail.loading'),
          padding: EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              VsSkeleton(height: 240),
              SizedBox(height: 16),
              VsSkeleton(),
              SizedBox(height: 6),
              VsSkeleton(width: 200),
            ],
          ),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              'エラー: $error',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: VsTokens.err,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
