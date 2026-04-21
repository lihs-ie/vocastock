import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/presentation/theme/widgets/vs_skeleton.dart';

void main() {
  testWidgets('VsSkeleton animates a linear gradient shimmer', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 120,
            height: 12,
            child: VsSkeleton(width: 120),
          ),
        ),
      ),
    );
    expect(find.byType(VsSkeleton), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 200));
    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(VsSkeleton),
        matching: find.byType(Container),
      ),
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.gradient, isA<LinearGradient>());
  });
}
