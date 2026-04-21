import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/presentation/theme/widgets/vs_progress.dart';

void main() {
  testWidgets('VsProgress fills proportionally to value', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(width: 100, child: VsProgress(value: 0.5)),
        ),
      ),
    );
    await tester.pump();
    final fraction =
        tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
    expect(fraction.widthFactor, 0.5);
  });

  testWidgets('VsProgress clamps values above 1', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(width: 100, child: VsProgress(value: 1.8)),
        ),
      ),
    );
    await tester.pump();
    final fraction =
        tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
    expect(fraction.widthFactor, 1.0);
  });
}
