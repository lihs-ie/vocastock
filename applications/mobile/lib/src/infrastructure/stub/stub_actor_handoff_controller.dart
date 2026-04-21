import 'dart:async';

import '../../application/auth/actor_handoff_reader.dart';
import '../../application/auth/login_command.dart';
import '../../application/auth/logout_command.dart';
import '../../domain/auth/actor_handoff_status.dart';
import '../../domain/common/actor_reference.dart';
import '../../domain/common/user_facing_message.dart';
import '../../domain/identifier/identifier.dart';

/// In-memory stub used while backend auth endpoints are still being wired up.
///
/// Drives the handoff through all three stages asynchronously so widget and
/// feature tests can observe intermediate states. Set [failAt] to inject a
/// deterministic failure for the corresponding stage.
class StubActorHandoffController
    implements ActorHandoffReader, LoginCommand, LogoutCommand {
  StubActorHandoffController({
    ActorReference? completedActor,
    this.failAt,
  }) : _completedActor = completedActor ?? _defaultActor();

  final ActorHandoffStage? failAt;
  final ActorReference _completedActor;

  final StreamController<ActorHandoffStatus> _controller =
      StreamController<ActorHandoffStatus>.broadcast();
  ActorHandoffStatus _status = const ActorHandoffNotStarted();
  int _generation = 0;

  @override
  ActorHandoffStatus get current => _status;

  @override
  Stream<ActorHandoffStatus> watch() => _controller.stream;

  @override
  Future<void> signIn(AuthProvider provider) async {
    final generation = ++_generation;
    for (final stage in ActorHandoffStage.values) {
      if (generation != _generation) return;
      _emit(ActorHandoffInProgress(stage));
      if (failAt == stage) {
        _emit(
          const ActorHandoffFailed(
            UserFacingMessage(
              key: 'auth.handoff-failed',
              text: 'サインインに失敗しました',
            ),
          ),
        );
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    if (generation != _generation) return;
    _emit(ActorHandoffCompleted(_completedActor));
  }

  @override
  Future<void> signOut() async {
    _generation++;
    _emit(const ActorHandoffNotStarted());
  }

  void _emit(ActorHandoffStatus status) {
    _status = status;
    _controller.add(status);
  }

  Future<void> dispose() async {
    await _controller.close();
  }

  static ActorReference _defaultActor() {
    return ActorReference(
      actor: ActorReferenceIdentifier('stub-actor'),
      session: SessionIdentifier('stub-session'),
      authAccount: AuthAccountIdentifier('stub-account'),
      sessionState: SessionState.active,
    );
  }
}
