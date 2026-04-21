import 'package:meta/meta.dart';

/// IPA pronunciation pair, mirroring data.jsx's `{ weak, strong }` shape.
@immutable
class Pronunciation {
  const Pronunciation({required this.weak, required this.strong});

  final String weak;
  final String strong;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pronunciation &&
          other.weak == weak &&
          other.strong == strong);

  @override
  int get hashCode => Object.hash(weak, strong);
}
