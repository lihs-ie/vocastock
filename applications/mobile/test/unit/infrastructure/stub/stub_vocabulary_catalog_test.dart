import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/application/envelope/command_error.dart';
import 'package:vocastock_mobile/src/application/envelope/command_response_envelope.dart';
import 'package:vocastock_mobile/src/domain/identifier/identifier.dart';
import 'package:vocastock_mobile/src/infrastructure/stub/stub_vocabulary_catalog.dart';

void main() {
  group('StubVocabularyCatalog', () {
    test('starts empty', () {
      final catalog = StubVocabularyCatalog();
      expect(catalog.current.isEmpty, isTrue);
    });

    test('accepts a new registration', () async {
      final catalog = StubVocabularyCatalog();
      final response = await catalog.register(
        text: 'serendipity',
        idempotencyKey: IdempotencyKey('idem-1'),
      );
      expect(
        response,
        isA<CommandResponseAccepted>().having(
          (value) => value.outcome,
          'outcome',
          AcceptanceOutcome.accepted,
        ),
      );
      expect(catalog.current.entries.length, equals(1));
      expect(catalog.current.entries.first.text, equals('serendipity'));
      await catalog.dispose();
    });

    test('returns reusedExisting for duplicate text', () async {
      final catalog = StubVocabularyCatalog();
      await catalog.register(
        text: 'serendipity',
        idempotencyKey: IdempotencyKey('idem-1'),
      );
      final duplicate = await catalog.register(
        text: 'serendipity',
        idempotencyKey: IdempotencyKey('idem-2'),
      );
      expect(
        duplicate,
        isA<CommandResponseAccepted>().having(
          (value) => value.outcome,
          'outcome',
          AcceptanceOutcome.reusedExisting,
        ),
      );
      expect(catalog.current.entries.length, equals(1));
      await catalog.dispose();
    });

    test('rejects empty text with validationFailed', () async {
      final catalog = StubVocabularyCatalog();
      final response = await catalog.register(
        text: '   ',
        idempotencyKey: IdempotencyKey('idem-1'),
      );
      expect(
        response,
        isA<CommandResponseRejected>().having(
          (value) => value.category,
          'category',
          CommandErrorCategory.validationFailed,
        ),
      );
      expect(catalog.current.isEmpty, isTrue);
      await catalog.dispose();
    });

    test('watch stream emits on new registration', () async {
      final catalog = StubVocabularyCatalog();
      final events = <int>[];
      final sub = catalog.watch().listen(
            (snapshot) => events.add(snapshot.entries.length),
          );
      await catalog.register(
        text: 'serendipity',
        idempotencyKey: IdempotencyKey('idem-1'),
      );
      // Drain pending stream events.
      await Future<void>.delayed(Duration.zero);
      expect(events, contains(1));
      await sub.cancel();
      await catalog.dispose();
    });
  });
}
