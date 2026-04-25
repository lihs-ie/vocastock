import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/domain/identifier/identifier.dart';
import 'package:vocastock_mobile/src/domain/visual/visual_image_detail.dart';

CompletedImageDetail _detail({
  String assetReference = 'ref',
  String description = 'desc',
  VisualImageIdentifier? previousImage,
}) {
  return CompletedImageDetail(
    identifier: VisualImageIdentifier('i'),
    explanation: ExplanationIdentifier('e'),
    assetReference: assetReference,
    description: description,
    previousImage: previousImage,
  );
}

void main() {
  group('CompletedImageDetail', () {
    test('is value-equal when all fields match', () {
      expect(_detail(), equals(_detail()));
    });

    test('differs on asset reference', () {
      expect(_detail(), isNot(equals(_detail(assetReference: 'other'))));
    });

    test('differs on description', () {
      expect(_detail(), isNot(equals(_detail(description: 'other'))));
    });

    test('previousImage defaults to null on first generation', () {
      expect(_detail().previousImage, isNull);
    });

    test('differs on previousImage', () {
      expect(
        _detail(),
        isNot(equals(_detail(previousImage: VisualImageIdentifier('p')))),
      );
    });

    test('value-equal when previousImage matches', () {
      final identifier = VisualImageIdentifier('p');
      expect(
        _detail(previousImage: identifier),
        equals(_detail(previousImage: VisualImageIdentifier('p'))),
      );
    });
  });
}
