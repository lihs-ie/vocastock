import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/presentation/theme/vs_tokens.dart';
import 'package:vocastock_mobile/src/presentation/theme/widgets/vs_chip.dart';

void main() {
  group('VsChip', () {
    Widget harness(Widget child) => MaterialApp(home: Scaffold(body: child));

    testWidgets('renders the provided label', (tester) async {
      await tester.pumpWidget(harness(const VsChip(label: '頻出')));
      expect(find.text('頻出'), findsOneWidget);
    });

    testWidgets('accent tone paints accent container colors', (tester) async {
      await tester.pumpWidget(
        harness(const VsChip(label: '完了', tone: VsChipTone.accent)),
      );
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, VsTokens.accentSoft);
    });

    testWidgets('dark tone paints ink container colors', (tester) async {
      await tester.pumpWidget(
        harness(const VsChip(label: 'ALL', tone: VsChipTone.dark)),
      );
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, VsTokens.ink);
    });
  });

  group('VsOutlinedChip', () {
    testWidgets('draws an outlined pill tinted by the given color',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VsOutlinedChip(
              label: '学習中',
              color: VsTokens.profLearning,
            ),
          ),
        ),
      );
      expect(find.text('学習中'), findsOneWidget);
    });
  });
}
