import 'package:flutter/material.dart';

/// Platform-aware spacing helpers mirroring the `platform` branches in
/// `screens.jsx` (VSTabBar / VSToast / VSHome FAB).
///
/// The design bundle hard-codes different safe-area and floating offsets
/// per platform; this utility collapses the same branches into a single
/// helper so widgets can stay layout-agnostic.
class PlatformInsets {
  const PlatformInsets._();

  /// `true` when the Flutter ambient platform is iOS.
  static bool isIOS(BuildContext context) =>
      Theme.of(context).platform == TargetPlatform.iOS;

  /// Bottom padding for `VsBottomTabBar`, mirroring `screens.jsx` L41
  /// (`platform === "ios" ? 34 : 24`). The platform floor is used when the
  /// OS reports a smaller safe area; a larger SafeArea (Dynamic Island,
  /// gesture-nav handles) is always honoured.
  static double tabBarBottomPadding(BuildContext context) {
    final mediaBottom = MediaQuery.of(context).padding.bottom;
    final floor = isIOS(context) ? 34.0 : 24.0;
    return mediaBottom > floor ? mediaBottom : floor;
  }

  /// Bottom offset for floating chrome (FAB, SnackBar), mirroring the
  /// `bottom: platform === "ios" ? 110 : 100` pattern in `VSToast` and
  /// `VSHome` (screens.jsx L78 / L156). The tab bar height (~60 dp) is
  /// already included so floating elements clear the chrome cleanly.
  static double floatingBottomOffset(BuildContext context) {
    return isIOS(context) ? 110.0 : 100.0;
  }
}
