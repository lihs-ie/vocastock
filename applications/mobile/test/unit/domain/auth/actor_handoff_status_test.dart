import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/domain/auth/actor_handoff_status.dart';
import 'package:vocastock_mobile/src/domain/common/actor_reference.dart';
import 'package:vocastock_mobile/src/domain/common/user_facing_message.dart';
import 'package:vocastock_mobile/src/domain/identifier/identifier.dart';

void main() {
  String describe(ActorHandoffStatus status) {
    return switch (status) {
      ActorHandoffNotStarted() => 'not-started',
      ActorHandoffInProgress(:final stage) => 'in-progress:${stage.name}',
      ActorHandoffCompleted(:final actor) => 'completed:${actor.actor.value}',
      ActorHandoffFailed(:final message) => 'failed:${message.key}',
    };
  }

  test('sealed family is exhaustively pattern-matchable', () {
    expect(describe(const ActorHandoffNotStarted()), equals('not-started'));
    expect(
      describe(
        const ActorHandoffInProgress(ActorHandoffStage.backendTokenVerify),
      ),
      equals('in-progress:backendTokenVerify'),
    );
    final actor = ActorReference(
      actor: ActorReferenceIdentifier('actor-ok'),
      session: SessionIdentifier('s'),
      authAccount: AuthAccountIdentifier('a'),
      sessionState: SessionState.active,
    );
    expect(
      describe(ActorHandoffCompleted(actor)),
      equals('completed:actor-ok'),
    );
    expect(
      describe(
        const ActorHandoffFailed(
          UserFacingMessage(key: 'auth.boom', text: 'ng'),
        ),
      ),
      equals('failed:auth.boom'),
    );
  });

  group('equality', () {
    test('in-progress equality is keyed on stage', () {
      expect(
        const ActorHandoffInProgress(ActorHandoffStage.providerSignIn),
        equals(
          const ActorHandoffInProgress(ActorHandoffStage.providerSignIn),
        ),
      );
      expect(
        const ActorHandoffInProgress(ActorHandoffStage.providerSignIn),
        isNot(
          equals(
            const ActorHandoffInProgress(ActorHandoffStage.backendTokenVerify),
          ),
        ),
      );
    });

    test('completed equality is keyed on actor reference', () {
      final reference = ActorReference(
        actor: ActorReferenceIdentifier('a'),
        session: SessionIdentifier('s'),
        authAccount: AuthAccountIdentifier('auth'),
        sessionState: SessionState.active,
      );
      expect(
        ActorHandoffCompleted(reference),
        equals(ActorHandoffCompleted(reference)),
      );
    });

    test('failed equality is keyed on message', () {
      expect(
        const ActorHandoffFailed(
          UserFacingMessage(key: 'x', text: 'y'),
        ),
        equals(
          const ActorHandoffFailed(
            UserFacingMessage(key: 'x', text: 'y'),
          ),
        ),
      );
    });
  });
}
