import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/presentation/theme/widgets/vs_illustration_panel.dart';

void main() {
  testWidgets('VsIllustrationPanel renders label at requested height',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            child: VsIllustrationPanel(label: '走る', seed: 2, height: 120),
          ),
        ),
      ),
    );
    expect(find.text('走る'), findsOneWidget);
    final panel = tester.getSize(find.byType(VsIllustrationPanel));
    expect(panel.height, 120);
  });
}
