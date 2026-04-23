import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_auth/firebase_auth.dart' as fb show FirebaseAuth;
import 'package:google_sign_in/google_sign_in.dart';

import '../../application/auth/actor_handoff_reader.dart';
import '../../application/auth/login_command.dart';
import '../../application/auth/logout_command.dart';
import '../../domain/auth/actor_handoff_status.dart';
import '../../domain/common/actor_reference.dart';
import '../../domain/common/user_facing_message.dart';
import '../../domain/identifier/identifier.dart';

/// Firebase-backed implementation of the auth handoff contract.
///
/// - `signIn(AuthProvider.basic)` signs in with email + password via
///   `signInWithEmailAndPassword`. Against the emulator the seeded
///   `demo@vocastock.test` / `demo1234` account is used; production
///   deploys should wire a proper registration / sign-in form.
/// - `signIn(AuthProvider.google)` triggers the real Google OAuth
///   consent screen via `google_sign_in`, exchanges the credential
///   through Firebase Auth, and resolves the actor. Against the
///   Auth emulator Firebase auto-accepts the credential without
///   contacting Google servers.
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
    for (final stage in ActorHandoffStage.values) {
      _emit(ActorHandoffInProgress(stage));
      await Future<void>.delayed(const Duration(milliseconds: 40));
    }
    try {
      switch (provider) {
        case AuthProvider.basic:
          await _signInWithEmailPassword();
        case AuthProvider.google:
          await _signInWithGoogle();
      }
    } on FirebaseAuthException catch (error) {
      _emit(
        ActorHandoffFailed(
          UserFacingMessage(
            key: 'auth.firebase-${error.code}',
            text: error.message ?? 'サインインに失敗しました',
          ),
        ),
      );
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

  Future<void> _signInWithEmailPassword() async {
    await _auth.signInWithEmailAndPassword(
      email: demoEmail,
      password: demoPassword,
    );
  }

  Future<void> _signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      _emit(const ActorHandoffNotStarted());
      return;
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _auth.signInWithCredential(credential);
  }

  @override
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
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
