import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/presentation/theme/widgets/vs_input_field.dart';

void main() {
  testWidgets('VsInputField reports onChanged and updates controller',
      (WidgetTester tester) async {
    final controller = TextEditingController();
    String? latest;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: VsInputField(
              controller: controller,
              hint: 'serendipity',
              onChanged: (value) => latest = value,
            ),
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(VsInputField), 'meticulous');
    expect(controller.text, 'meticulous');
    expect(latest, 'meticulous');
  });
}
