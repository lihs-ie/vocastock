import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/domain/common/actor_reference.dart';
import 'package:vocastock_mobile/src/domain/identifier/identifier.dart';

void main() {
  group('ActorReference', () {
    test('is value-equal when all references match', () {
      final a = ActorReference(
        actor: ActorReferenceIdentifier('actor-1'),
        session: SessionIdentifier('session-1'),
        authAccount: AuthAccountIdentifier('account-1'),
        sessionState: SessionState.active,
      );
      final b = ActorReference(
        actor: ActorReferenceIdentifier('actor-1'),
        session: SessionIdentifier('session-1'),
        authAccount: AuthAccountIdentifier('account-1'),
        sessionState: SessionState.active,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('differs when session state differs', () {
      final active = ActorReference(
        actor: ActorReferenceIdentifier('actor-1'),
        session: SessionIdentifier('session-1'),
        authAccount: AuthAccountIdentifier('account-1'),
        sessionState: SessionState.active,
      );
      final reauth = ActorReference(
        actor: ActorReferenceIdentifier('actor-1'),
        session: SessionIdentifier('session-1'),
        authAccount: AuthAccountIdentifier('account-1'),
        sessionState: SessionState.reauthRequired,
      );
      expect(active, isNot(equals(reauth)));
    });
  });
}
