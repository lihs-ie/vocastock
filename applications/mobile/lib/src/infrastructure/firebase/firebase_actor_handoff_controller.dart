import 'dart:async';

import '../../application/auth/actor_handoff_reader.dart';
import '../../application/auth/actor_resolver.dart';
import '../../application/auth/backend_token_verifier.dart';
import '../../application/auth/login_command.dart';
import '../../application/auth/logout_command.dart';
import '../../domain/auth/actor_handoff_status.dart';
import '../../domain/common/user_facing_message.dart';
import 'firebase_auth_service.dart';

/// Orchestrates the 3-stage actor handoff (spec 008):
///
/// 1. `providerSignIn` — delegates to [FirebaseAuthService]
/// 2. `backendTokenVerify` — delegates to [BackendTokenVerifier]
/// 3. `actorResolve` — delegates to [ActorResolver]
///
/// Each stage is awaited before the next begins. Auth state observation
/// (`authStateChanges`) is NOT used to drive handoff completion — only
/// explicit stage results advance the state machine.
class FirebaseActorHandoffController
    implements ActorHandoffReader, LoginCommand, LogoutCommand {
  FirebaseActorHandoffController({
    required FirebaseAuthService authService,
    required BackendTokenVerifier tokenVerifier,
    required ActorResolver actorResolver,
  })  : _authService = authService,
        _tokenVerifier = tokenVerifier,
        _actorResolver = actorResolver;

  final FirebaseAuthService _authService;
  final BackendTokenVerifier _tokenVerifier;
  final ActorResolver _actorResolver;

  final StreamController<ActorHandoffStatus> _controller =
      StreamController<ActorHandoffStatus>.broadcast();
  ActorHandoffStatus _status = const ActorHandoffNotStarted();

  @override
  ActorHandoffStatus get current => _status;

  @override
  Stream<ActorHandoffStatus> watch() => _controller.stream;

  @override
  Future<void> signIn(AuthProvider provider) async {
    try {
      _emit(const ActorHandoffInProgress(ActorHandoffStage.providerSignIn));
      await _authService.signIn(provider);

      _emit(
        const ActorHandoffInProgress(ActorHandoffStage.backendTokenVerify),
      );
      final verified = await _tokenVerifier.verifyCurrentToken();
      if (!verified) {
        _emit(
          const ActorHandoffFailed(
            UserFacingMessage(
              key: 'auth.token-verification-failed',
              text: 'バックエンドのトークン検証に失敗しました',
            ),
          ),
        );
        return;
      }

      _emit(const ActorHandoffInProgress(ActorHandoffStage.actorResolve));
      final actor = await _actorResolver.resolveActor();
      _emit(ActorHandoffCompleted(actor));
    } on Exception catch (error) {
      _emit(
        ActorHandoffFailed(
          UserFacingMessage(
            key: 'auth.sign-in-failed',
            text: error.toString(),
          ),
        ),
      );
    }
  }

  @override
  Future<void> signOut() async {
    await _authService.signOut();
    _emit(const ActorHandoffNotStarted());
  }

  Future<void> dispose() async {
    await _controller.close();
  }

  void _emit(ActorHandoffStatus status) {
    _status = status;
    _controller.add(status);
  }
}
