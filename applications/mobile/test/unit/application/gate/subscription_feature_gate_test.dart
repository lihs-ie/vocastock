// Exhaustive feature × state × tier coverage for spec 014
// feature-gate-matrix-contract.md.

import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/application/gate/subscription_feature_gate.dart';
import 'package:vocastock_mobile/src/domain/status/subscription_state.dart';
import 'package:vocastock_mobile/src/domain/subscription/entitlement.dart';
import 'package:vocastock_mobile/src/domain/subscription/plan.dart';

void main() {
  const gate = SubscriptionFeatureGate();

  FeatureGateDecision evaluateAt({
    required FeatureKey feature,
    required SubscriptionState state,
    required PlanTier plan,
  }) {
    return gate.evaluate(feature: feature, state: state, plan: plan);
  }

  group('revoked state', () {
    // revoked column: only subscription-status-access and restore-access allowed.
    const state = SubscriptionState.revoked;
    for (final plan in PlanTier.values) {
      test('revoked + $plan denies catalog-viewing', () {
        expect(
          evaluateAt(
            feature: FeatureKey.catalogViewing,
            state: state,
            plan: plan,
          ),
          isA<FeatureGateDeny>(),
        );
      });
      test('revoked + $plan denies vocabulary-registration', () {
        expect(
          evaluateAt(
            feature: FeatureKey.vocabularyRegistration,
            state: state,
            plan: plan,
          ),
          isA<FeatureGateDeny>(),
        );
      });
      test('revoked + $plan denies explanation-generation', () {
        expect(
          evaluateAt(
            feature: FeatureKey.explanationGeneration,
            state: state,
            plan: plan,
          ),
          isA<FeatureGateDeny>(),
        );
      });
      test('revoked + $plan denies image-generation', () {
        expect(
          evaluateAt(
            feature: FeatureKey.imageGeneration,
            state: state,
            plan: plan,
          ),
          isA<FeatureGateDeny>(),
        );
      });
      test('revoked + $plan denies completed-result-viewing', () {
        expect(
          evaluateAt(
            feature: FeatureKey.completedResultViewing,
            state: state,
            plan: plan,
          ),
          isA<FeatureGateDeny>(),
        );
      });
      test('revoked + $plan allows subscription-status-access', () {
        expect(
          evaluateAt(
            feature: FeatureKey.subscriptionStatusAccess,
            state: state,
            plan: plan,
          ),
          isA<FeatureGateAllow>(),
        );
      });
      test('revoked + $plan allows restore-access', () {
        expect(
          evaluateAt(
            feature: FeatureKey.restoreAccess,
            state: state,
            plan: plan,
          ),
          isA<FeatureGateAllow>(),
        );
      });
    }
  });

  group('free column (free plan, active state)', () {
    const state = SubscriptionState.active;
    const plan = PlanTier.free;
    test('allows catalog-viewing', () {
      expect(
        evaluateAt(
          feature: FeatureKey.catalogViewing,
          state: state,
          plan: plan,
        ),
        isA<FeatureGateAllow>(),
      );
    });
    test('allows vocabulary-registration', () {
      expect(
        evaluateAt(
          feature: FeatureKey.vocabularyRegistration,
          state: state,
          plan: plan,
        ),
        isA<FeatureGateAllow>(),
      );
    });
    test('limits explanation-generation', () {
      expect(
        evaluateAt(
          feature: FeatureKey.explanationGeneration,
          state: state,
          plan: plan,
        ),
        isA<FeatureGateLimited>(),
      );
    });
    test('limits image-generation', () {
      expect(
        evaluateAt(
          feature: FeatureKey.imageGeneration,
          state: state,
          plan: plan,
        ),
        isA<FeatureGateLimited>(),
      );
    });
    test('allows completed-result-viewing', () {
      expect(
        evaluateAt(
          feature: FeatureKey.completedResultViewing,
          state: state,
          plan: plan,
        ),
        isA<FeatureGateAllow>(),
      );
    });
    test('allows subscription-status-access', () {
      expect(
        evaluateAt(
          feature: FeatureKey.subscriptionStatusAccess,
          state: state,
          plan: plan,
        ),
        isA<FeatureGateAllow>(),
      );
    });
    test('allows restore-access', () {
      expect(
        evaluateAt(
          feature: FeatureKey.restoreAccess,
          state: state,
          plan: plan,
        ),
        isA<FeatureGateAllow>(),
      );
    });
  });

  group('paid active column (premium plan, active state)', () {
    const state = SubscriptionState.active;
    const plan = PlanTier.premium;
    test('allows catalog-viewing', () {
      expect(
        evaluateAt(
          feature: FeatureKey.catalogViewing,
          state: state,
          plan: plan,
        ),
        isA<FeatureGateAllow>(),
      );
    });
    test('allows vocabulary-registration', () {
      expect(
        evaluateAt(
          feature: FeatureKey.vocabularyRegistration,
          state: state,
          plan: plan,
        ),
        isA<FeatureGateAllow>(),
      );
    });
    test('allows explanation-generation', () {
      expect(
        evaluateAt(
          feature: FeatureKey.explanationGeneration,
          state: state,
          plan: plan,
        ),
        isA<FeatureGateAllow>(),
      );
    });
    test('allows image-generation', () {
      expect(
        evaluateAt(
          feature: FeatureKey.imageGeneration,
          state: state,
          plan: plan,
        ),
        isA<FeatureGateAllow>(),
      );
    });
    test('allows completed-result-viewing', () {
      expect(
        evaluateAt(
          feature: FeatureKey.completedResultViewing,
          state: state,
          plan: plan,
        ),
        isA<FeatureGateAllow>(),
      );
    });
    test('allows subscription-status-access', () {
      expect(
        evaluateAt(
          feature: FeatureKey.subscriptionStatusAccess,
          state: state,
          plan: plan,
        ),
        isA<FeatureGateAllow>(),
      );
    });
    test('allows restore-access', () {
      expect(
        evaluateAt(
          feature: FeatureKey.restoreAccess,
          state: state,
          plan: plan,
        ),
        isA<FeatureGateAllow>(),
      );
    });
  });

  group('paid grace column (grace state, any paid plan)', () {
    const state = SubscriptionState.grace;
    const plan = PlanTier.premium;
    test('allows catalog-viewing', () {
      expect(
        evaluateAt(
          feature: FeatureKey.catalogViewing,
          state: state,
          plan: plan,
        ),
        isA<FeatureGateAllow>(),
      );
    });
    test('allows vocabulary-registration', () {
      expect(
        evaluateAt(
          feature: FeatureKey.vocabularyRegistration,
          state: state,
          plan: plan,
        ),
        isA<FeatureGateAllow>(),
      );
    });
    test('allows explanation-generation (paid entitlement preserved)', () {
      expect(
        evaluateAt(
          feature: FeatureKey.explanationGeneration,
          state: state,
          plan: plan,
        ),
        isA<FeatureGateAllow>(),
      );
    });
    test('allows image-generation (paid entitlement preserved)', () {
      expect(
        evaluateAt(
          feature: FeatureKey.imageGeneration,
          state: state,
          plan: plan,
        ),
        isA<FeatureGateAllow>(),
      );
    });
    test('allows completed-result-viewing', () {
      expect(
        evaluateAt(
          feature: FeatureKey.completedResultViewing,
          state: state,
          plan: plan,
        ),
        isA<FeatureGateAllow>(),
      );
    });
    test('allows subscription-status-access', () {
      expect(
        evaluateAt(
          feature: FeatureKey.subscriptionStatusAccess,
          state: state,
          plan: plan,
        ),
        isA<FeatureGateAllow>(),
      );
    });
    test('allows restore-access', () {
      expect(
        evaluateAt(
          feature: FeatureKey.restoreAccess,
          state: state,
          plan: plan,
        ),
        isA<FeatureGateAllow>(),
      );
    });
  });

  group('pending-sync column', () {
    const state = SubscriptionState.pendingSync;
    // pending-sync must not unlock paid generation regardless of recorded plan.
    for (final plan in PlanTier.values) {
      test('pending-sync + $plan allows catalog-viewing', () {
        expect(
          evaluateAt(
            feature: FeatureKey.catalogViewing,
            state: state,
            plan: plan,
          ),
          isA<FeatureGateAllow>(),
        );
      });
      test('pending-sync + $plan allows vocabulary-registration', () {
        expect(
          evaluateAt(
            feature: FeatureKey.vocabularyRegistration,
            state: state,
            plan: plan,
          ),
          isA<FeatureGateAllow>(),
        );
      });
      test('pending-sync + $plan limits explanation-generation', () {
        expect(
          evaluateAt(
            feature: FeatureKey.explanationGeneration,
            state: state,
            plan: plan,
          ),
          isA<FeatureGateLimited>(),
        );
      });
      test('pending-sync + $plan limits image-generation', () {
        expect(
          evaluateAt(
            feature: FeatureKey.imageGeneration,
            state: state,
            plan: plan,
          ),
          isA<FeatureGateLimited>(),
        );
      });
      test('pending-sync + $plan allows completed-result-viewing', () {
        expect(
          evaluateAt(
            feature: FeatureKey.completedResultViewing,
            state: state,
            plan: plan,
          ),
          isA<FeatureGateAllow>(),
        );
      });
      test('pending-sync + $plan allows subscription-status-access', () {
        expect(
          evaluateAt(
            feature: FeatureKey.subscriptionStatusAccess,
            state: state,
            plan: plan,
          ),
          isA<FeatureGateAllow>(),
        );
      });
      test('pending-sync + $plan allows restore-access', () {
        expect(
          evaluateAt(
            feature: FeatureKey.restoreAccess,
            state: state,
            plan: plan,
          ),
          isA<FeatureGateAllow>(),
        );
      });
    }
  });

  group('expired column', () {
    const state = SubscriptionState.expired;
    for (final plan in PlanTier.values) {
      test('expired + $plan allows catalog-viewing', () {
        expect(
          evaluateAt(
            feature: FeatureKey.catalogViewing,
            state: state,
            plan: plan,
          ),
          isA<FeatureGateAllow>(),
        );
      });
      test('expired + $plan allows vocabulary-registration', () {
        expect(
          evaluateAt(
            feature: FeatureKey.vocabularyRegistration,
            state: state,
            plan: plan,
          ),
          isA<FeatureGateAllow>(),
        );
      });
      test('expired + $plan limits explanation-generation', () {
        expect(
          evaluateAt(
            feature: FeatureKey.explanationGeneration,
            state: state,
            plan: plan,
          ),
          isA<FeatureGateLimited>(),
        );
      });
      test('expired + $plan limits image-generation', () {
        expect(
          evaluateAt(
            feature: FeatureKey.imageGeneration,
            state: state,
            plan: plan,
          ),
          isA<FeatureGateLimited>(),
        );
      });
      test('expired + $plan allows completed-result-viewing', () {
        expect(
          evaluateAt(
            feature: FeatureKey.completedResultViewing,
            state: state,
            plan: plan,
          ),
          isA<FeatureGateAllow>(),
        );
      });
      test('expired + $plan allows subscription-status-access', () {
        expect(
          evaluateAt(
            feature: FeatureKey.subscriptionStatusAccess,
            state: state,
            plan: plan,
          ),
          isA<FeatureGateAllow>(),
        );
      });
      test('expired + $plan allows restore-access', () {
        expect(
          evaluateAt(
            feature: FeatureKey.restoreAccess,
            state: state,
            plan: plan,
          ),
          isA<FeatureGateAllow>(),
        );
      });
    }
  });

  group('invariants', () {
    test(
      'revoked reason is tagged as revokedAccess',
      () {
        final decision = evaluateAt(
          feature: FeatureKey.catalogViewing,
          state: SubscriptionState.revoked,
          plan: PlanTier.premium,
        );
        expect(
          decision,
          equals(
            const FeatureGateDeny(FeatureGateDenyReason.revokedAccess),
          ),
        );
      },
    );
  });
}
