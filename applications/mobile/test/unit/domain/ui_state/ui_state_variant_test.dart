import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/domain/common/user_facing_message.dart';
import 'package:vocastock_mobile/src/domain/ui_state/ui_state_variant.dart';

void main() {
  String label(UIStateVariant<String> state) {
    return switch (state) {
      UIStateLoading<String>() => 'loading',
      UIStateStatusOnly<String>(:final summary) => 'status:$summary',
      UIStateCompleted<String>(:final payload) => 'completed:$payload',
      UIStateRetryableFailure<String>(:final message) =>
        'retry:${message.key}',
      UIStateHardStop<String>(:final message) => 'hard:${message.key}',
    };
  }

  test('sealed family covers all 5 variants via exhaustive switch', () {
    expect(label(const UIStateLoading<String>()), equals('loading'));
    expect(label(const UIStateStatusOnly<String>('x')), equals('status:x'));
    expect(label(const UIStateCompleted<String>('y')), equals('completed:y'));
    expect(
      label(
        const UIStateRetryableFailure<String>(
          UserFacingMessage(key: 'e', text: 't'),
        ),
      ),
      equals('retry:e'),
    );
    expect(
      label(
        const UIStateHardStop<String>(
          UserFacingMessage(key: 'h', text: 't'),
        ),
      ),
      equals('hard:h'),
    );
  });
}
