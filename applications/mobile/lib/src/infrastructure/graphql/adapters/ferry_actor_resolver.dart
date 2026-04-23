import 'package:ferry/ferry.dart';

import '../../../application/auth/actor_resolver.dart';
import '../../../application/auth/backend_token_verifier.dart';
import '../../../domain/common/actor_reference.dart';
import '../../../domain/identifier/identifier.dart';
import '../__generated__/schema.schema.gql.dart' as schema;
import '../operations/__generated__/actor_handoff.req.gql.dart';

/// Implements both [BackendTokenVerifier] and [ActorResolver] via the
/// `actorHandoffStatus` GraphQL query.
///
/// A single query serves both roles:
/// - Token verification: a 200 response with non-null `actor` field
///   means the backend accepted the Firebase ID token.
/// - Actor resolution: the response body contains the backend-
///   authoritative `actor`, `session`, `authAccount`, `sessionState`.
class FerryActorHandoffAdapter
    implements BackendTokenVerifier, ActorResolver {
  FerryActorHandoffAdapter({required Client client}) : _client = client;

  final Client _client;

  @override
  Future<bool> verifyCurrentToken() async {
    try {
      final result = await _client
          .request(GActorHandoffStatusQueryReq())
          .first;
      final data = result.data;
      if (data == null) return false;
      return data.actorHandoffStatus.sessionState ==
          schema.GSessionStateCode.ACTIVE;
    } on Object {
      return false;
    }
  }

  @override
  Future<ActorReference> resolveActor() async {
    final result = await _client
        .request(GActorHandoffStatusQueryReq())
        .first;
    final data = result.data;
    if (data == null) {
      throw StateError('actorHandoffStatus returned no data');
    }
    final status = data.actorHandoffStatus;
    return ActorReference(
      actor: ActorReferenceIdentifier(status.actor ?? ''),
      session: SessionIdentifier(status.session ?? ''),
      authAccount: AuthAccountIdentifier(status.authAccount ?? ''),
      sessionState: status.sessionState == schema.GSessionStateCode.ACTIVE
          ? SessionState.active
          : SessionState.reauthRequired,
    );
  }
}
