import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_bindings.dart';
import '../../domain/identifier/identifier.dart';

/// Spec 013 canonical `ExplanationDetail` screen.
///
/// `allowsCompletedPayload = true`: renders only completed payload returned
/// by the reader. A null response means the explanation is no longer
/// completed (stale read or regeneration in flight), in which case the
/// screen routes back without ever showing a provisional body.
class ExplanationDetailScreen extends ConsumerWidget {
  const ExplanationDetailScreen({required this.identifier, super.key});

  final ExplanationIdentifier identifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(explanationDetailFutureProvider(identifier));

    return Scaffold(
      appBar: AppBar(title: const Text('解説')),
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
                Text(
                  detail.body,
                  key: const Key('explanation-detail.body'),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                const Text(
                  '例文',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                for (final sentence in detail.exampleSentences)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '- $sentence',
                      key: const Key('explanation-detail.example'),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            key: Key('explanation-detail.loading'),
          ),
        ),
        error: (error, _) => Center(
          child: Text('エラー: $error'),
        ),
      ),
    );
  }
}
