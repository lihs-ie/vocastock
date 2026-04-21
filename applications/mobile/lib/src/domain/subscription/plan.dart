/// Canonical plan code from spec 014 product-catalog-contract.
enum PlanCode {
  free,
  standardMonthly,
  proMonthly,
}

/// Plan tier that determines which quota profile and entitlement bundle apply.
enum PlanTier {
  free,
  premium,
}

extension PlanCodeExtension on PlanCode {
  PlanTier get tier {
    return switch (this) {
      PlanCode.free => PlanTier.free,
      PlanCode.standardMonthly => PlanTier.premium,
      PlanCode.proMonthly => PlanTier.premium,
    };
  }
}
