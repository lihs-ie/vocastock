import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/presentation/theme/widgets/vs_otp_field.dart';

void main() {
  testWidgets('VsOtpField fires onCompleted when six digits are filled',
      (WidgetTester tester) async {
    String? completed;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: VsOtpField(onCompleted: (code) => completed = code),
          ),
        ),
      ),
    );
    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(6));

    for (var i = 0; i < 6; i++) {
      await tester.enterText(fields.at(i), '${i + 1}');
    }
    expect(completed, '123456');
  });
}
