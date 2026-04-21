import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/domain/identifier/identifier.dart';
import 'package:vocastock_mobile/src/domain/visual/visual_image_detail.dart';

CompletedImageDetail _detail({
  String assetReference = 'ref',
  String description = 'desc',
}) {
  return CompletedImageDetail(
    identifier: VisualImageIdentifier('i'),
    explanation: ExplanationIdentifier('e'),
    assetReference: assetReference,
    description: description,
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
  });
}
