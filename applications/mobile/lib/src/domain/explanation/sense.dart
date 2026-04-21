import 'package:meta/meta.dart';

/// Example sentence + meaning pair within a [Sense].
@immutable
class SenseExample {
  const SenseExample({
    required this.value,
    required this.meaning,
    this.pronunciation,
  });

  final String value;
  final String meaning;
  final String? pronunciation;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SenseExample &&
          other.value == value &&
          other.meaning == meaning &&
          other.pronunciation == pronunciation);

  @override
  int get hashCode => Object.hash(value, meaning, pronunciation);
}

/// Collocation entry (e.g. "run a business" → "事業を営む").
@immutable
class Collocation {
  const Collocation({required this.value, required this.meaning});

  final String value;
  final String meaning;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Collocation &&
          other.value == value &&
          other.meaning == meaning);

  @override
  int get hashCode => Object.hash(value, meaning);
}

/// A single semantic unit within an Explanation. Ownership is the
/// Explanation aggregate per spec 005.
@immutable
class Sense {
  const Sense({
    required this.identifier,
    required this.order,
    required this.label,
    required this.situation,
    required this.nuance,
    required this.examples,
    required this.collocations,
  });

  final String identifier;
  final int order;
  final String label;
  final String situation;
  final String nuance;
  final List<SenseExample> examples;
  final List<Collocation> collocations;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sense &&
          other.identifier == identifier &&
          other.order == order &&
          other.label == label &&
          other.situation == situation &&
          other.nuance == nuance &&
          _listEquals(other.examples, examples) &&
          _listEquals(other.collocations, collocations));

  @override
  int get hashCode => Object.hash(
        identifier,
        order,
        label,
        situation,
        nuance,
        Object.hashAll(examples),
        Object.hashAll(collocations),
      );

  static bool _listEquals(List<Object?> a, List<Object?> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
