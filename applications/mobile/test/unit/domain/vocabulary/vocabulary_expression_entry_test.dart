import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/domain/identifier/identifier.dart';
import 'package:vocastock_mobile/src/domain/status/explanation_generation_status.dart';
import 'package:vocastock_mobile/src/domain/status/image_generation_status.dart';
import 'package:vocastock_mobile/src/domain/status/registration_status.dart';
import 'package:vocastock_mobile/src/domain/vocabulary/vocabulary_expression_entry.dart';

VocabularyExpressionEntry _entry({
  String text = 'serendipity',
  ExplanationGenerationStatus explanation =
      ExplanationGenerationStatus.pending,
  ImageGenerationStatus image = ImageGenerationStatus.pending,
  ExplanationIdentifier? currentExplanation,
  VisualImageIdentifier? currentImage,
}) {
  return VocabularyExpressionEntry(
    identifier: VocabularyExpressionIdentifier('vocab-1'),
    text: text,
    registrationStatus: RegistrationStatus.active,
    explanationStatus: explanation,
    imageStatus: image,
    currentExplanation: currentExplanation,
    currentImage: currentImage,
  );
}

void main() {
  group('VocabularyExpressionEntry', () {
    test('hasCompletedExplanation reflects currentExplanation presence', () {
      final withExplanation = _entry(
        currentExplanation: ExplanationIdentifier('exp-1'),
      );
      expect(withExplanation.hasCompletedExplanation, isTrue);
      expect(_entry().hasCompletedExplanation, isFalse);
    });

    test('hasCompletedImage reflects currentImage presence', () {
      final withImage = _entry(
        currentImage: VisualImageIdentifier('img-1'),
      );
      expect(withImage.hasCompletedImage, isTrue);
      expect(_entry().hasCompletedImage, isFalse);
    });

    test('equality is value based', () {
      expect(_entry(), equals(_entry()));
      expect(
        _entry().hashCode,
        equals(_entry().hashCode),
      );
    });

    test('differing current explanation breaks equality', () {
      expect(
        _entry(currentExplanation: ExplanationIdentifier('a')),
        isNot(equals(_entry(currentExplanation: ExplanationIdentifier('b')))),
      );
    });
  });

  group('VocabularyCatalog', () {
    test('is empty when no entries are present', () {
      expect(
        VocabularyCatalog(const <VocabularyExpressionEntry>[]).isEmpty,
        isTrue,
      );
    });

    test('findByText returns a matching entry', () {
      final catalog = VocabularyCatalog([_entry()]);
      expect(catalog.findByText('serendipity'), isNotNull);
      expect(catalog.findByText('missing'), isNull);
    });

    test('equality is keyed on entry list', () {
      expect(
        VocabularyCatalog([_entry()]),
        equals(VocabularyCatalog([_entry()])),
      );
    });

    test('entries are unmodifiable', () {
      final original = [_entry()];
      final catalog = VocabularyCatalog(original);
      original.clear();
      expect(catalog.entries.length, equals(1));
      expect(
        () => catalog.entries.add(_entry(text: 'another')),
        throwsUnsupportedError,
      );
    });
  });
}
