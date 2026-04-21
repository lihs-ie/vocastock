import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/router/router.dart';
import 'presentation/theme/vocastock_theme.dart';

/// Top-level Flutter widget.
///
/// Owns only the [MaterialApp.router] configuration; all wiring lives in the
/// Riverpod providers declared under `lib/src/app_bindings.dart` and the
/// `routerProvider` in the presentation layer.
class VocastockApp extends ConsumerWidget {
  const VocastockApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'vocastock',
      theme: VocastockTheme.dictionaryLight(),
      routerConfig: router,
    );
  }
}
