/// Verifies the current Firebase ID token against the backend.
///
/// The implementation sends the token to the GraphQL gateway (or
/// directly to query-api) and confirms the backend accepts it. This
/// is stage 2 (`backendTokenVerify`) of the 3-stage actor handoff
/// defined in spec 008.
abstract class BackendTokenVerifier {
  Future<bool> verifyCurrentToken();
}
