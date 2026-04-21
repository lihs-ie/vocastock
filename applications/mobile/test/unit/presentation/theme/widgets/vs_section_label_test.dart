import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/presentation/theme/vs_tokens.dart';
import 'package:vocastock_mobile/src/presentation/theme/widgets/vs_section_label.dart';

void main() {
  testWidgets('VsSectionLabel uppercases and colors text as inkMute',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: VsSectionLabel('nuance')),
      ),
    );
    expect(find.text('NUANCE'), findsOneWidget);
    final text = tester.widget<Text>(find.byType(Text));
    expect(text.style?.color, VsTokens.inkMute);
    expect(text.style?.fontWeight, FontWeight.w500);
  });
}
