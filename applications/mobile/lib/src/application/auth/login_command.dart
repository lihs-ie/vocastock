import '../../domain/auth/actor_handoff_status.dart';

/// Starts the 3-stage actor handoff for the given provider.
///
/// The command body is intentionally narrow: provider selection is the only
/// piece of input from the UI. Tokens and session secrets remain inside the
/// infrastructure adapter.
abstract class LoginCommand {
  Future<void> signIn(AuthProvider provider);
}
