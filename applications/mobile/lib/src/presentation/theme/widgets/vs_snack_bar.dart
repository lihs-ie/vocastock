import 'package:flutter/material.dart';

import '../platform_insets.dart';

/// Thin wrapper around `ScaffoldMessenger.showSnackBar` that applies the
/// project's floating SnackBar chrome (iOS 110 / Android 100 bottom
/// margin, matching `screens.jsx` VSToast).
///
/// Call sites pass a plain `message` string; the helper wires up the
/// floating behavior, duration, and platform-aware margin so individual
/// screens no longer duplicate the SnackBar construction.
class VsSnackBar {
  const VsSnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    Key? key,
    Duration duration = const Duration(seconds: 2),
  }) {
    final bottom = PlatformInsets.floatingBottomOffset(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      SnackBar(
        key: key,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: EdgeInsets.only(left: 16, right: 16, bottom: bottom),
        content: Text(message),
      ),
    );
  }
}
