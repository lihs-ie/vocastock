import 'package:flutter/material.dart';

/// Minimal placeholder for the `VocabularyCatalog` screen.
///
/// Phase 2 only proves that the router lands here after a successful actor
/// handoff. Phase 3 replaces this widget with the real catalog list bound to
/// `VocabularyCatalogReader`.
class VocabularyCatalogPlaceholder extends StatelessWidget {
  const VocabularyCatalogPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('語彙カタログ')),
      body: const Center(
        child: Text(
          '語彙がまだ登録されていません',
          key: Key('catalog.empty-placeholder'),
        ),
      ),
    );
  }
}
