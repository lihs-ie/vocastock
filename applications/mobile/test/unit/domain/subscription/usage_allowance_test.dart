import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/domain/subscription/usage_allowance.dart';

void main() {
  group('UsageAllowance', () {
    test('is value-equal on both remainders', () {
      const a = UsageAllowance(
        remainingExplanationGenerations: 10,
        remainingImageGenerations: 3,
      );
      const b = UsageAllowance(
        remainingExplanationGenerations: 10,
        remainingImageGenerations: 3,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('differs when either remainder differs', () {
      const baseline = UsageAllowance(
        remainingExplanationGenerations: 10,
        remainingImageGenerations: 3,
      );
      const fewerExplanations = UsageAllowance(
        remainingExplanationGenerations: 9,
        remainingImageGenerations: 3,
      );
      const fewerImages = UsageAllowance(
        remainingExplanationGenerations: 10,
        remainingImageGenerations: 2,
      );
      expect(baseline, isNot(equals(fewerExplanations)));
      expect(baseline, isNot(equals(fewerImages)));
    });

    test('availability flags reflect positive remainders', () {
      const allowed = UsageAllowance(
        remainingExplanationGenerations: 5,
        remainingImageGenerations: 1,
      );
      expect(allowed.canGenerateExplanation, isTrue);
      expect(allowed.canGenerateImage, isTrue);
    });

    test('availability flags fall to false at zero', () {
      const depleted = UsageAllowance(
        remainingExplanationGenerations: 0,
        remainingImageGenerations: 0,
      );
      expect(depleted.canGenerateExplanation, isFalse);
      expect(depleted.canGenerateImage, isFalse);
    });

    test('toString surfaces both remainders', () {
      const allowance = UsageAllowance(
        remainingExplanationGenerations: 7,
        remainingImageGenerations: 2,
      );
      expect(
        allowance.toString(),
        equals('UsageAllowance(explanation=7, image=2)'),
      );
    });
  });
}
