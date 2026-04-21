import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runs the Welcome → Sign-in submit flow so tests that want to reach the
/// authenticated AppShell can write a single call.
Future<void> loginViaEmail(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('login.provider.basic')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('login.signin.submit')));
  await tester.pumpAndSettle();
}
