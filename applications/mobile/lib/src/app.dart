import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/router/router.dart';
import 'presentation/theme/vocastock_theme.dart';
import 'presentation/theme/vs_tokens.dart';

/// Top-level Flutter widget.
///
/// Owns the [MaterialApp.router] configuration and the ambient system UI
/// overlay style so the status bar / navigation bar adopt the paper
/// background with dark foreground icons on both iOS and Android. All
/// wiring lives in the Riverpod providers declared under
/// `lib/src/app_bindings.dart` and the `routerProvider` in the
/// presentation layer.
class VocastockApp extends ConsumerWidget {
  const VocastockApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: VsTokens.paper,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: VsTokens.inkHair,
      ),
      child: MaterialApp.router(
        title: 'vocastock',
        theme: VocastockTheme.dictionaryLight(),
        routerConfig: router,
      ),
    );
  }
}
