import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/main.dart' as app_entry;
import 'package:vocastock_mobile/src/app.dart';

void main() {
  group('bootstrap smoke', () {
    testWidgets('VocastockApp mounts MaterialApp.router', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: VocastockApp()));
      await tester.pump();
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    test('main entry symbol is callable', () {
      expect(app_entry.main, isA<Function>());
    });
  });
}
