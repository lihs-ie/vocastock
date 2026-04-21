import 'package:flutter/material.dart';

/// Placeholder for the `VocabularyExpressionDetail` screen (Phase 3 lands
/// here after registration; Phase 4 replaces with the real status
/// aggregation screen).
class VocabularyExpressionDetailPlaceholder extends StatelessWidget {
  const VocabularyExpressionDetailPlaceholder({required this.identifier, super.key});

  final String identifier;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('単語の詳細')),
      body: Center(
        child: Text(
          'identifier = $identifier',
          key: const Key('vocabulary-detail.identifier'),
        ),
      ),
    );
  }
}
