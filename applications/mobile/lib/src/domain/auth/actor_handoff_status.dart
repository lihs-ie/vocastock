import 'package:meta/meta.dart';

import '../common/actor_reference.dart';
import '../common/user_facing_message.dart';

/// Three-stage actor handoff lifecycle defined by spec 008 auth-session-design.
///
/// `providerSignIn` → `backendTokenVerify` → `actorResolve`. Each stage must
/// complete before the next is entered; provider sign-in alone does not
/// authorize `AppShell` navigation (spec 013 navigation-topology-contract).
enum ActorHandoffStage {
  providerSignIn,
  backendTokenVerify,
  actorResolve,
}

/// Authentication provider offered to the user on the Login screen.
/// Basic (email + secret) and Google are the initial targets per spec 008;
/// Apple ID / LINE are conditional follow-on candidates.
enum AuthProvider {
  basic,
  google,
}

/// Sealed family describing the current handoff state.
///
/// The UI reads this through the `ActorHandoffReader` and chooses between
/// `Login`, `SessionResolving`, and `AppShell` purely from this value. Raw
/// Firebase ID tokens / refresh tokens / provider credentials are never
/// exposed via this family (spec 008 session-handoff-contract).
@immutable
sealed class ActorHandoffStatus {
  const ActorHandoffStatus();
}

@immutable
final class ActorHandoffNotStarted extends ActorHandoffStatus {
  const ActorHandoffNotStarted();
}

@immutable
final class ActorHandoffInProgress extends ActorHandoffStatus {
  const ActorHandoffInProgress(this.stage);
  final ActorHandoffStage stage;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActorHandoffInProgress && other.stage == stage);

  @override
  int get hashCode => stage.hashCode;
}

@immutable
final class ActorHandoffCompleted extends ActorHandoffStatus {
  const ActorHandoffCompleted(this.actor);
  final ActorReference actor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActorHandoffCompleted && other.actor == actor);

  @override
  int get hashCode => actor.hashCode;
}

@immutable
final class ActorHandoffFailed extends ActorHandoffStatus {
  const ActorHandoffFailed(this.message);
  final UserFacingMessage message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActorHandoffFailed && other.message == message);

  @override
  int get hashCode => message.hashCode;
}
