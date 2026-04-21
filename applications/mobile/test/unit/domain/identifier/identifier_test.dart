import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/domain/identifier/identifier.dart';

void main() {
  group('Identifier base contract', () {
    test('exposes the raw value', () {
      final identifier = VocabularyExpressionIdentifier('01J00000000000000000000000');
      expect(identifier.value, equals('01J00000000000000000000000'));
    });

    test('rejects empty values', () {
      expect(
        () => VocabularyExpressionIdentifier(''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('equality is value-based within the same concrete type', () {
      final a = VocabularyExpressionIdentifier('alpha');
      final b = VocabularyExpressionIdentifier('alpha');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('different concrete types never compare equal even with same value',
        () {
      final vocabulary = VocabularyExpressionIdentifier('shared');
      final explanation = ExplanationIdentifier('shared');
      expect(vocabulary, isNot(equals(explanation)));
      expect(vocabulary.hashCode, isNot(equals(explanation.hashCode)));
    });

    test('toString embeds runtimeType and value', () {
      final identifier = SenseIdentifier('sense-1');
      expect(identifier.toString(), equals('SenseIdentifier(sense-1)'));
    });
  });

  group('all constitution-mandated identifier types are constructable', () {
    // This guards constitution §I. Any new identifier must be added here.
    final constructed = <Identifier>[
      LearnerIdentifier('learner'),
      VocabularyExpressionIdentifier('vocab'),
      ExplanationIdentifier('explanation'),
      SenseIdentifier('sense'),
      VisualImageIdentifier('image'),
      ActorReferenceIdentifier('actor'),
      SessionIdentifier('session'),
      AuthAccountIdentifier('account'),
      IdempotencyKey('key'),
      StoreProductIdentifier('product'),
    ];

    test('every identifier round-trips its value', () {
      for (final identifier in constructed) {
        expect(identifier.value, isNotEmpty);
      }
    });

    test('every identifier rejects empty values', () {
      expect(() => LearnerIdentifier(''), throwsA(isA<ArgumentError>()));
      expect(
        () => VocabularyExpressionIdentifier(''),
        throwsA(isA<ArgumentError>()),
      );
      expect(() => ExplanationIdentifier(''), throwsA(isA<ArgumentError>()));
      expect(() => SenseIdentifier(''), throwsA(isA<ArgumentError>()));
      expect(() => VisualImageIdentifier(''), throwsA(isA<ArgumentError>()));
      expect(
        () => ActorReferenceIdentifier(''),
        throwsA(isA<ArgumentError>()),
      );
      expect(() => SessionIdentifier(''), throwsA(isA<ArgumentError>()));
      expect(() => AuthAccountIdentifier(''), throwsA(isA<ArgumentError>()));
      expect(() => IdempotencyKey(''), throwsA(isA<ArgumentError>()));
      expect(() => StoreProductIdentifier(''), throwsA(isA<ArgumentError>()));
    });
  });
}
