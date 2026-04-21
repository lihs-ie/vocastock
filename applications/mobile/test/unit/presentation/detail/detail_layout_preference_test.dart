import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/presentation/detail/detail_layout_preference.dart';

void main() {
  test('detailLayoutProvider defaults to tab and mutates via set()', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(detailLayoutProvider), DetailLayout.tab);
    container.read(detailLayoutProvider.notifier).set(DetailLayout.cards);
    expect(container.read(detailLayoutProvider), DetailLayout.cards);
  });
}
