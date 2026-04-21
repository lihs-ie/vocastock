import '../../domain/subscription/subscription_status_view.dart';

/// Reads the learner's subscription status aggregation for the
/// `SubscriptionStatus` screen (spec 013 screen-source-binding-contract).
abstract class SubscriptionStatusReader {
  SubscriptionStatusView get current;
  Stream<SubscriptionStatusView> watch();
}
