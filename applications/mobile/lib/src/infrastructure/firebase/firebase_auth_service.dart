import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_auth/firebase_auth.dart' as fb show FirebaseAuth, User;
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/auth/actor_handoff_status.dart';

/// Encapsulates Firebase Auth + provider-specific credential acquisition.
///
/// This service owns the sign-in / sign-out lifecycle and exposes the
/// raw `authStateChanges` stream. It does NOT interpret auth state as
/// actor references — that mapping is the responsibility of
/// `FirebaseActorHandoffController`.
///
/// - `AuthProvider.basic` → email + password (`signInWithEmailAndPassword`)
/// - `AuthProvider.google` → real Google OAuth via `google_sign_in`
///
/// Against the Firebase Auth emulator, Google credentials are
/// auto-accepted without contacting Google servers.
class FirebaseAuthService {
  FirebaseAuthService({fb.FirebaseAuth? auth})
      : _auth = auth ?? fb.FirebaseAuth.instance;

  static const String demoEmail = 'demo@vocastock.test';
  static const String demoPassword = 'demo1234';

  final fb.FirebaseAuth _auth;

  fb.User? get currentUser => _auth.currentUser;

  Stream<fb.User?> authStateChanges() => _auth.authStateChanges();

  Future<void> signIn(AuthProvider provider) async {
    switch (provider) {
      case AuthProvider.basic:
        await _signInWithEmailPassword();
      case AuthProvider.google:
        await _signInWithGoogle();
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  Future<void> _signInWithEmailPassword() async {
    await _auth.signInWithEmailAndPassword(
      email: demoEmail,
      password: demoPassword,
    );
  }

  Future<void> _signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _auth.signInWithCredential(credential);
  }
}
