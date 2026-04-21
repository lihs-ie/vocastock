import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/presentation/theme/widgets/vs_spinner.dart';

void main() {
  testWidgets('VsSpinner renders a sized CircularProgressIndicator',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: VsSpinner(size: 24))),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final box = tester.widget<SizedBox>(
      find.ancestor(
        of: find.byType(CircularProgressIndicator),
        matching: find.byType(SizedBox),
      ),
    );
    expect(box.width, 24);
    expect(box.height, 24);
  });
}
