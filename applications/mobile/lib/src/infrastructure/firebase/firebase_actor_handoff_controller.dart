import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_auth/firebase_auth.dart' as fb show FirebaseAuth;

import '../../application/auth/actor_handoff_reader.dart';
import '../../application/auth/login_command.dart';
import '../../application/auth/logout_command.dart';
import '../../domain/auth/actor_handoff_status.dart';
import '../../domain/common/actor_reference.dart';
import '../../domain/common/user_facing_message.dart';
import '../../domain/identifier/identifier.dart';

/// Firebase-backed implementation of the auth handoff contract.
///
/// `signIn(AuthProvider.basic)` → `demo@vocastock.test`,
/// `signIn(AuthProvider.google)` → `free@vocastock.test`. Both accounts
/// are provisioned by `firebase/seed/seed.mjs` against the local Auth
/// emulator. Real OAuth wiring is out of scope for the emulator preview —
/// the intent is that any downstream integration test can exercise the
/// same end-to-end path without a browser-based OAuth dance.
class FirebaseActorHandoffController
    implements ActorHandoffReader, LoginCommand, LogoutCommand {
  FirebaseActorHandoffController({fb.FirebaseAuth? auth})
      : _auth = auth ?? fb.FirebaseAuth.instance {
    _authSubscription =
        _auth.authStateChanges().listen(_reflectAuthState);
    _reflectAuthState(_auth.currentUser);
  }

  static const String demoEmail = 'demo@vocastock.test';
  static const String demoPassword = 'demo1234';
  static const String freeEmail = 'free@vocastock.test';
  static const String freePassword = 'free1234';

  final fb.FirebaseAuth _auth;
  late final StreamSubscription<User?> _authSubscription;
  final StreamController<ActorHandoffStatus> _controller =
      StreamController<ActorHandoffStatus>.broadcast();
  ActorHandoffStatus _status = const ActorHandoffNotStarted();

  @override
  ActorHandoffStatus get current => _status;

  @override
  Stream<ActorHandoffStatus> watch() => _controller.stream;

  @override
  Future<void> signIn(AuthProvider provider) async {
    final (email, password) = switch (provider) {
      AuthProvider.basic => (demoEmail, demoPassword),
      AuthProvider.google => (freeEmail, freePassword),
    };
    for (final stage in ActorHandoffStage.values) {
      _emit(ActorHandoffInProgress(stage));
      await Future<void>.delayed(const Duration(milliseconds: 40));
    }
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      _emit(
        ActorHandoffFailed(
          UserFacingMessage(
            key: 'auth.firebase-${error.code}',
            text: error.message ?? 'サインインに失敗しました',
          ),
        ),
      );
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> dispose() async {
    await _authSubscription.cancel();
    await _controller.close();
  }

  void _reflectAuthState(User? user) {
    if (user == null) {
      if (_status is ActorHandoffCompleted) {
        _emit(const ActorHandoffNotStarted());
      }
      return;
    }
    final actor = ActorReference(
      actor: ActorReferenceIdentifier(user.uid),
      session: SessionIdentifier(
        'session-${user.uid}-${DateTime.now().millisecondsSinceEpoch}',
      ),
      authAccount: AuthAccountIdentifier(user.uid),
      sessionState: SessionState.active,
    );
    _emit(ActorHandoffCompleted(actor));
  }

  void _emit(ActorHandoffStatus status) {
    _status = status;
    _controller.add(status);
  }
}
