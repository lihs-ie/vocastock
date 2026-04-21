import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/domain/subscription/entitlement.dart';

void main() {
  group('FeatureGateDecision', () {
    test('allow instances are mutually equal', () {
      expect(const FeatureGateAllow(), equals(const FeatureGateAllow()));
    });

    test('limited instances are mutually equal', () {
      expect(const FeatureGateLimited(), equals(const FeatureGateLimited()));
    });

    test('deny is value-equal on reason', () {
      expect(
        const FeatureGateDeny(FeatureGateDenyReason.revokedAccess),
        equals(const FeatureGateDeny(FeatureGateDenyReason.revokedAccess)),
      );
    });

    test('deny differs from allow and limited', () {
      expect(
        const FeatureGateDeny(FeatureGateDenyReason.revokedAccess),
        isNot(equals(const FeatureGateAllow())),
      );
      expect(
        const FeatureGateDeny(FeatureGateDenyReason.revokedAccess),
        isNot(equals(const FeatureGateLimited())),
      );
    });
  });

  test('FeatureKey enumerates spec 014 canonical keys', () {
    expect(FeatureKey.values.length, equals(7));
    expect(FeatureKey.values, contains(FeatureKey.catalogViewing));
    expect(FeatureKey.values, contains(FeatureKey.restoreAccess));
  });

  test('EntitlementBundle enumerates spec 014 bundles', () {
    expect(EntitlementBundle.values.length, equals(2));
    expect(EntitlementBundle.values, contains(EntitlementBundle.freeBasic));
    expect(
      EntitlementBundle.values,
      contains(EntitlementBundle.premiumGeneration),
    );
  });
}
