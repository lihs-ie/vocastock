import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/application/envelope/command_error.dart';

void main() {
  group('CommandErrorCategory retryability', () {
    test('dispatch-failed is retryable', () {
      expect(CommandErrorCategory.dispatchFailed.isRetryable, isTrue);
    });

    test('target-not-ready is retryable', () {
      expect(CommandErrorCategory.targetNotReady.isRetryable, isTrue);
    });

    test('downstream-unavailable is retryable', () {
      expect(CommandErrorCategory.downstreamUnavailable.isRetryable, isTrue);
    });

    test('validation-failed is not retryable', () {
      expect(CommandErrorCategory.validationFailed.isRetryable, isFalse);
    });

    test('ownership-mismatch is not retryable', () {
      expect(CommandErrorCategory.ownershipMismatch.isRetryable, isFalse);
    });

    test('target-missing is not retryable', () {
      expect(CommandErrorCategory.targetMissing.isRetryable, isFalse);
    });

    test('idempotency-conflict is not retryable', () {
      expect(CommandErrorCategory.idempotencyConflict.isRetryable, isFalse);
    });

    test('internal-failure is not retryable', () {
      expect(CommandErrorCategory.internalFailure.isRetryable, isFalse);
    });

    test('unsupported-operation is not retryable', () {
      expect(CommandErrorCategory.unsupportedOperation.isRetryable, isFalse);
    });

    test('ambiguous-operation is not retryable', () {
      expect(CommandErrorCategory.ambiguousOperation.isRetryable, isFalse);
    });

    test('downstream-invalid-response is not retryable', () {
      expect(
        CommandErrorCategory.downstreamInvalidResponse.isRetryable,
        isFalse,
      );
    });

    test('downstream-auth-failed is not retryable', () {
      expect(CommandErrorCategory.downstreamAuthFailed.isRetryable, isFalse);
    });
  });

  group('CommandErrorCategory reauth routing', () {
    test('downstream-auth-failed requires reauth', () {
      expect(
        CommandErrorCategory.downstreamAuthFailed.requiresReauth,
        isTrue,
      );
    });

    test('all other categories do not require reauth', () {
      for (final category in CommandErrorCategory.values) {
        if (category == CommandErrorCategory.downstreamAuthFailed) {
          continue;
        }
        expect(
          category.requiresReauth,
          isFalse,
          reason: '$category should not trigger reauth',
        );
      }
    });
  });
}
