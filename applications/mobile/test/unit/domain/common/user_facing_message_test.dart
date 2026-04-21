import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/domain/common/user_facing_message.dart';

void main() {
  group('UserFacingMessage', () {
    test('is value-equal on key and text', () {
      const a = UserFacingMessage(
        key: 'registration.accepted',
        text: 'Registered',
      );
      const b = UserFacingMessage(
        key: 'registration.accepted',
        text: 'Registered',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString hides rendered text but keeps the key', () {
      const message = UserFacingMessage(
        key: 'auth.reauth-required',
        text: 'Please sign in again',
      );
      expect(message.toString(), equals('UserFacingMessage(auth.reauth-required)'));
    });
  });
}
