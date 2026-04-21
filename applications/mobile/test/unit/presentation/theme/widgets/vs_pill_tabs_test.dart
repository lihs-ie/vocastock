import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/presentation/theme/widgets/vs_pill_tabs.dart';

enum _Filter { all, running }

void main() {
  testWidgets('VsPillTabs renders each tab label and count',
      (WidgetTester tester) async {
    var current = _Filter.all;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return MaterialApp(
            home: Scaffold(
              body: VsPillTabs<_Filter>(
                selected: current,
                onChanged: (value) => setState(() => current = value),
                tabs: const <VsPillTab<_Filter>>[
                  VsPillTab<_Filter>(
                    value: _Filter.all,
                    label: 'すべて',
                    count: 7,
                  ),
                  VsPillTab<_Filter>(
                    value: _Filter.running,
                    label: '生成中',
                    count: 2,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    expect(find.text('すべて'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('生成中'), findsOneWidget);

    await tester.tap(find.text('生成中'));
    await tester.pumpAndSettle();
    // Selected is now running; verify by re-locating text is still present.
    expect(find.text('生成中'), findsOneWidget);
  });
}
