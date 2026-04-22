import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/presentation/theme/widgets/vs_snack_bar.dart';

void main() {
  group('VsSnackBar.show', () {
    testWidgets('renders a floating SnackBar with iOS platform margin',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => VsSnackBar.show(
                  context,
                  message: 'hello',
                  key: const Key('vs.snack-bar.test'),
                ),
                child: const Text('show'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('show'));
      await tester.pump();
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.behavior, SnackBarBehavior.floating);
      expect(snackBar.key, const Key('vs.snack-bar.test'));
      expect(snackBar.margin, const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 110,
      ));
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('uses Android bottom margin (100) on Android',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => VsSnackBar.show(
                  context,
                  message: 'world',
                ),
                child: const Text('show'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('show'));
      await tester.pump();
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.margin, const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 100,
      ));
    });

    testWidgets('honours the provided duration',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => VsSnackBar.show(
                  context,
                  message: 'quick',
                  duration: const Duration(milliseconds: 700),
                ),
                child: const Text('show'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('show'));
      await tester.pump();
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.duration, const Duration(milliseconds: 700));
    });
  });
}
