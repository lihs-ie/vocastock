import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/presentation/theme/platform_insets.dart';

Widget _harness({
  required TargetPlatform platform,
  required double bottomPadding,
  required Widget Function(BuildContext context) builder,
}) {
  return MaterialApp(
    theme: ThemeData(platform: platform),
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          padding: EdgeInsets.only(bottom: bottomPadding),
        ),
        child: Builder(builder: builder),
      ),
    ),
  );
}

void main() {
  group('PlatformInsets.isIOS', () {
    testWidgets('returns true on iOS', (WidgetTester tester) async {
      late bool result;
      await tester.pumpWidget(
        _harness(
          platform: TargetPlatform.iOS,
          bottomPadding: 0,
          builder: (context) {
            result = PlatformInsets.isIOS(context);
            return const SizedBox.shrink();
          },
        ),
      );
      expect(result, isTrue);
    });

    testWidgets('returns false on Android', (WidgetTester tester) async {
      late bool result;
      await tester.pumpWidget(
        _harness(
          platform: TargetPlatform.android,
          bottomPadding: 0,
          builder: (context) {
            result = PlatformInsets.isIOS(context);
            return const SizedBox.shrink();
          },
        ),
      );
      expect(result, isFalse);
    });
  });

  group('PlatformInsets.tabBarBottomPadding', () {
    testWidgets('iOS floor is 34 when SafeArea is zero',
        (WidgetTester tester) async {
      late double value;
      await tester.pumpWidget(
        _harness(
          platform: TargetPlatform.iOS,
          bottomPadding: 0,
          builder: (context) {
            value = PlatformInsets.tabBarBottomPadding(context);
            return const SizedBox.shrink();
          },
        ),
      );
      expect(value, 34.0);
    });

    testWidgets('Android floor is 24 when SafeArea is zero',
        (WidgetTester tester) async {
      late double value;
      await tester.pumpWidget(
        _harness(
          platform: TargetPlatform.android,
          bottomPadding: 0,
          builder: (context) {
            value = PlatformInsets.tabBarBottomPadding(context);
            return const SizedBox.shrink();
          },
        ),
      );
      expect(value, 24.0);
    });

    testWidgets('uses MediaQuery padding when larger than platform floor',
        (WidgetTester tester) async {
      late double value;
      await tester.pumpWidget(
        _harness(
          platform: TargetPlatform.iOS,
          bottomPadding: 48,
          builder: (context) {
            value = PlatformInsets.tabBarBottomPadding(context);
            return const SizedBox.shrink();
          },
        ),
      );
      expect(value, 48.0);
    });
  });

  group('PlatformInsets.floatingBottomOffset', () {
    testWidgets('iOS returns 110', (WidgetTester tester) async {
      late double value;
      await tester.pumpWidget(
        _harness(
          platform: TargetPlatform.iOS,
          bottomPadding: 0,
          builder: (context) {
            value = PlatformInsets.floatingBottomOffset(context);
            return const SizedBox.shrink();
          },
        ),
      );
      expect(value, 110.0);
    });

    testWidgets('Android returns 100', (WidgetTester tester) async {
      late double value;
      await tester.pumpWidget(
        _harness(
          platform: TargetPlatform.android,
          bottomPadding: 0,
          builder: (context) {
            value = PlatformInsets.floatingBottomOffset(context);
            return const SizedBox.shrink();
          },
        ),
      );
      expect(value, 100.0);
    });
  });
}
