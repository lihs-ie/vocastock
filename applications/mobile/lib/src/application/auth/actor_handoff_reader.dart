import '../../domain/auth/actor_handoff_status.dart';

/// Reads the current handoff state for `Login` / `SessionResolving` screens
/// (spec 013 screen-source-binding-contract).
abstract class ActorHandoffReader {
  ActorHandoffStatus get current;
  Stream<ActorHandoffStatus> watch();
}
