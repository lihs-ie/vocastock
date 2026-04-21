/// Clears the current actor reference and resets handoff state.
///
/// The implementation signs out of the provider, invalidates the backend
/// session, and emits `ActorHandoffNotStarted`.
abstract class LogoutCommand {
  Future<void> signOut();
}
