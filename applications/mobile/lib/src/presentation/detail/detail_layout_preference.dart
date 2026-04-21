import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Visual layout preference for the Explanation detail screen, mirroring
/// the three variants from `screens.jsx` (`VSDetailTab`, `VSDetailPage`,
/// `VSDetailCards`). Persisted only in-memory; a future settings-store
/// integration can swap this for a hydrated notifier.
enum DetailLayout { tab, page, cards }

extension DetailLayoutLabel on DetailLayout {
  String get label {
    return switch (this) {
      DetailLayout.tab => 'タブ',
      DetailLayout.page => 'ページ',
      DetailLayout.cards => 'カード',
    };
  }
}

class DetailLayoutNotifier extends Notifier<DetailLayout> {
  @override
  DetailLayout build() => DetailLayout.tab;

  // Expose a method, not a setter, so the call site reads naturally
  // (`ref.read(provider.notifier).set(value)`) in places where an explicit
  // verb is clearer than an assignment.
  // ignore: use_setters_to_change_properties
  void set(DetailLayout layout) => state = layout;
}

final detailLayoutProvider =
    NotifierProvider<DetailLayoutNotifier, DetailLayout>(
  DetailLayoutNotifier.new,
);
