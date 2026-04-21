import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/domain/subscription/plan.dart';

void main() {
  group('PlanCode.tier', () {
    test('free maps to free tier', () {
      expect(PlanCode.free.tier, equals(PlanTier.free));
    });

    test('standard-monthly maps to premium tier', () {
      expect(PlanCode.standardMonthly.tier, equals(PlanTier.premium));
    });

    test('pro-monthly maps to premium tier', () {
      expect(PlanCode.proMonthly.tier, equals(PlanTier.premium));
    });

    test('all plan codes resolve to a tier', () {
      for (final plan in PlanCode.values) {
        expect(plan.tier, isNotNull);
      }
    });
  });
}
