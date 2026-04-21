import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/presentation/theme/vs_tokens.dart';
import 'package:vocastock_mobile/src/presentation/theme/widgets/vs_icon_circle.dart';

void main() {
  testWidgets('VsIconCircle renders icon and invokes onTap',
      (WidgetTester tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: VsIconCircle(
              icon: Icons.search,
              onTap: () => taps++,
            ),
          ),
        ),
      ),
    );
    expect(find.byIcon(Icons.search), findsOneWidget);
    final icon = tester.widget<Icon>(find.byIcon(Icons.search));
    expect(icon.color, VsTokens.inkSoft);
    await tester.tap(find.byType(VsIconCircle));
    expect(taps, 1);
  });
}
