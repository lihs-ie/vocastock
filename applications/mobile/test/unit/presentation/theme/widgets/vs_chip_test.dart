import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/presentation/theme/vs_tokens.dart';
import 'package:vocastock_mobile/src/presentation/theme/widgets/vs_chip.dart';

void main() {
  group('VsChip', () {
    Widget harness(Widget child) => MaterialApp(home: Scaffold(body: child));

    testWidgets('renders the provided label', (WidgetTester tester) async {
      await tester.pumpWidget(harness(const VsChip(label: '頻出')));
      expect(find.text('頻出'), findsOneWidget);
    });

    testWidgets('accent tone paints accent container colors',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        harness(const VsChip(label: '完了', tone: VsChipTone.accent)),
      );
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, VsTokens.accentSoft);
    });

    testWidgets('dark tone paints ink container colors',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        harness(const VsChip(label: 'ALL', tone: VsChipTone.dark)),
      );
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, VsTokens.ink);
    });

    testWidgets('outlined mode draws transparent fill with colored border',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        harness(
          const VsChip(
            label: '学習中',
            outlined: true,
            color: VsTokens.profLearning,
          ),
        ),
      );
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, Colors.transparent);
      expect(decoration.border, isA<Border>());
    });

    testWidgets('icon slot renders provided widget',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        harness(
          const VsChip(
            label: 'PREMIUM',
            icon: Icon(Icons.emoji_events),
            tone: VsChipTone.accent,
          ),
        ),
      );
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    });
  });
}
