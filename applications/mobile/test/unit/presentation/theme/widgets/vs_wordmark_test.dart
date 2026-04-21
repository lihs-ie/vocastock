import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/presentation/theme/widgets/vs_wordmark.dart';

void main() {
  testWidgets('VsWordmark composes vocastock with accent dot', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: VsWordmark())),
    );
    expect(find.byType(RichText), findsWidgets);
    final rich = tester.widget<RichText>(find.byType(RichText).first);
    final text = rich.text.toPlainText();
    expect(text.contains('vocastock'), isTrue);
    expect(text.contains('·'), isTrue);
  });
}
