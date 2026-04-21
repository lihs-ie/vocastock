import '../../domain/identifier/identifier.dart';
import '../../domain/subscription/plan.dart';
import '../envelope/command_response_envelope.dart';

/// Starts a new subscription purchase flow for the selected plan.
abstract class RequestPurchaseCommand {
  Future<CommandResponseEnvelope> purchase({
    required PlanCode plan,
    required IdempotencyKey idempotencyKey,
  });
}

/// Attempts to restore a previously successful purchase (spec 013 restore
/// flow).
abstract class RequestRestorePurchaseCommand {
  Future<CommandResponseEnvelope> restore({
    required IdempotencyKey idempotencyKey,
  });
}
