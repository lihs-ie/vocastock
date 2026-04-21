import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/presentation/theme/widgets/vs_stage_step.dart';

void main() {
  testWidgets('VsStageStep renders check icon when done',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: VsStageStep(
            state: VsStageState.done,
            label: '正規化',
          ),
        ),
      ),
    );
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.text('正規化'), findsOneWidget);
  });

  testWidgets('VsStageStep renders sub only when active',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: VsStageStep(
            state: VsStageState.active,
            label: '例文生成',
            sub: 'Sense ごとに例文を構成',
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Sense ごとに例文を構成'), findsOneWidget);
  });
}
