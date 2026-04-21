import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/presentation/theme/widgets/vs_settings_row.dart';

void main() {
  testWidgets(
      'VsSettingsRow renders label / sub and triggers onTap',
      (WidgetTester tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VsSettingsRow(
            icon: Icons.settings,
            label: 'プロフィール',
            sub: '田中 健太',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );
    expect(find.text('プロフィール'), findsOneWidget);
    expect(find.text('田中 健太'), findsOneWidget);
    await tester.tap(find.byType(VsSettingsRow));
    expect(tapped, isTrue);
  });
}
