import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/presentation/theme/widgets/vs_brand_mark.dart';

void main() {
  testWidgets('VsBrandMark renders with the requested size',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: VsBrandMark(size: 48)),
      ),
    );
    final box = tester.getSize(find.byType(VsBrandMark));
    expect(box.width, 48);
    expect(box.height, 48);
    expect(find.byType(CustomPaint), findsWidgets);
  });
}
