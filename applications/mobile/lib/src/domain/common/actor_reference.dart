import 'package:meta/meta.dart';

import '../identifier/identifier.dart';

/// Backend-verified actor handoff payload (spec 008, spec 011).
///
/// The client only receives fully resolved references. Raw Firebase ID
/// tokens / refresh tokens / provider credentials must not be stored in app
/// state.
@immutable
class ActorReference {
  const ActorReference({
    required this.actor,
    required this.session,
    required this.authAccount,
    required this.sessionState,
  });

  final ActorReferenceIdentifier actor;
  final SessionIdentifier session;
  final AuthAccountIdentifier authAccount;
  final SessionState sessionState;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActorReference &&
          other.actor == actor &&
          other.session == session &&
          other.authAccount == authAccount &&
          other.sessionState == sessionState);

  @override
  int get hashCode => Object.hash(actor, session, authAccount, sessionState);
}

/// Backend-asserted session liveness (spec 008).
enum SessionState {
  active,
  reauthRequired,
}
