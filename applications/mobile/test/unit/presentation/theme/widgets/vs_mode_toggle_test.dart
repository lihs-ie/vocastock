import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/presentation/theme/widgets/vs_mode_toggle.dart';

enum _Mode { signIn, signUp }

void main() {
  testWidgets('VsModeToggle renders both options and emits onChanged',
      (WidgetTester tester) async {
    var current = _Mode.signIn;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) => MaterialApp(
          home: Scaffold(
            body: VsModeToggle<_Mode>(
              selected: current,
              onChanged: (value) => setState(() => current = value),
              options: const <VsModeOption<_Mode>>[
                VsModeOption<_Mode>(value: _Mode.signIn, label: 'ログイン'),
                VsModeOption<_Mode>(value: _Mode.signUp, label: '新規登録'),
              ],
            ),
          ),
        ),
      ),
    );
    expect(find.text('ログイン'), findsOneWidget);
    expect(find.text('新規登録'), findsOneWidget);

    await tester.tap(find.text('新規登録'));
    await tester.pumpAndSettle();
    expect(current, _Mode.signUp);
  });
}
