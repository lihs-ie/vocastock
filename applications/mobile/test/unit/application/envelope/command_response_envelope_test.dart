import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/application/envelope/command_error.dart';
import 'package:vocastock_mobile/src/application/envelope/command_response_envelope.dart';
import 'package:vocastock_mobile/src/domain/common/user_facing_message.dart';

void main() {
  String describe(CommandResponseEnvelope envelope) {
    return switch (envelope) {
      CommandResponseAccepted(:final outcome) => 'accepted:${outcome.name}',
      CommandResponseRejected(:final category) => 'rejected:${category.name}',
    };
  }

  test('accepted response exposes the acceptance outcome', () {
    const accepted = CommandResponseAccepted(
      message: UserFacingMessage(key: 'k', text: 't'),
      outcome: AcceptanceOutcome.accepted,
    );
    expect(describe(accepted), equals('accepted:accepted'));
  });

  test('accepted response can also represent reused-existing', () {
    const reused = CommandResponseAccepted(
      message: UserFacingMessage(key: 'k', text: 't'),
      outcome: AcceptanceOutcome.reusedExisting,
    );
    expect(describe(reused), equals('accepted:reusedExisting'));
  });

  test('rejected response carries a command error category', () {
    const rejected = CommandResponseRejected(
      message: UserFacingMessage(key: 'validation', text: 'invalid input'),
      category: CommandErrorCategory.validationFailed,
    );
    expect(describe(rejected), equals('rejected:validationFailed'));
  });

  test('rejected category is inspectable for routing', () {
    const authFailed = CommandResponseRejected(
      message: UserFacingMessage(key: 'auth', text: 'sign in'),
      category: CommandErrorCategory.downstreamAuthFailed,
    );
    expect(authFailed.category.requiresReauth, isTrue);
  });

  test('envelopes preserve their user-facing message', () {
    const envelope = CommandResponseAccepted(
      message: UserFacingMessage(key: 'registration.accepted', text: 'ok'),
      outcome: AcceptanceOutcome.accepted,
    );
    expect(envelope.message.key, equals('registration.accepted'));
  });
}
