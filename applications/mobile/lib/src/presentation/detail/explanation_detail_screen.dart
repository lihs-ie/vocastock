import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_bindings.dart';
import '../../domain/identifier/identifier.dart';
import '../theme/vs_tokens.dart';
import '../theme/widgets/vs_skeleton.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: VsTokens.paper,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context.pop(),
        ),
        title: const Text('解説'),
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
              Text(
                detail.body,
                key: const Key('explanation-detail.body'),
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                '例文',
                style: theme.textTheme.labelMedium,
              ),
              const SizedBox(height: 10),
              for (final sentence in detail.exampleSentences)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    sentence,
                    key: const Key('explanation-detail.example'),
                    style: const TextStyle(
                      fontFamily: VsTokens.serif,
                      fontSize: 15,
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                      color: VsTokens.ink,
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Padding(
          key: Key('explanation-detail.loading'),
          padding: EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              VsSkeleton(height: 20),
              SizedBox(height: 12),
              VsSkeleton(),
              SizedBox(height: 6),
              VsSkeleton(),
              SizedBox(height: 6),
              VsSkeleton(width: 240),
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
