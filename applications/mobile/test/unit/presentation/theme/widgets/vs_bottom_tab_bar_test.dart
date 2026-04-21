import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/presentation/theme/widgets/vs_bottom_tab_bar.dart';

void main() {
  testWidgets('VsBottomTabBar renders the four main tabs and marks the '
      'current index as active', (WidgetTester tester) async {
    var lastTapped = -1;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: VsBottomTabBar(
            currentIndex: 1,
            onTap: (index) => lastTapped = index,
          ),
          body: const SizedBox.shrink(),
        ),
      ),
    );
    expect(find.text('単語帳'), findsOneWidget);
    expect(find.text('習熟'), findsOneWidget);
    expect(find.text('プラン'), findsOneWidget);
    expect(find.text('設定'), findsOneWidget);

    await tester.tap(find.text('プラン'));
    expect(lastTapped, 2);
  });
}
