import 'package:firebase_auth/firebase_auth.dart';

import '../graphql/graphql_client.dart';

/// Reads the current Firebase Auth user's ID token so the GraphQL HTTP
/// link can attach `Authorization: Bearer <id-token>` to every request.
///
/// Returns `null` when the user is signed out. Tokens refresh
/// automatically — `getIdToken(true)` forces a refresh only if the cached
/// token is expired or about to expire.
class FirebaseAuthTokenSupplier implements AuthTokenSupplier {
  FirebaseAuthTokenSupplier({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  Future<String?> currentToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return user.getIdToken();
  }
}
