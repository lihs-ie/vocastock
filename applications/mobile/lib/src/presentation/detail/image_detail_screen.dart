import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_bindings.dart';
import '../../domain/identifier/identifier.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('画像')),
      body: detailAsync.when(
        data: (detail) {
          if (detail == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) context.pop();
            });
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  key: const Key('image-detail.asset'),
                  height: 240,
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: Text(
                    detail.assetReference,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  detail.description,
                  key: const Key('image-detail.description'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            key: Key('image-detail.loading'),
          ),
        ),
        error: (error, _) => Center(
          child: Text('エラー: $error'),
        ),
      ),
    );
  }
}
