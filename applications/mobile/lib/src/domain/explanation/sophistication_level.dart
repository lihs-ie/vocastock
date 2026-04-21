/// How intellectually / vocabulary-wise sophisticated the expression is
/// (spec 005).
enum SophisticationLevel {
  veryBasic,
  basic,
  intermediate,
  advanced,
}

extension SophisticationLevelLabel on SophisticationLevel {
  /// Japanese short label used on Detail chips (matches `tokens.jsx`
  /// `SOPH_JA`).
  String get labelJa {
    return switch (this) {
      SophisticationLevel.veryBasic => '基礎',
      SophisticationLevel.basic => '初級',
      SophisticationLevel.intermediate => '中級',
      SophisticationLevel.advanced => '上級',
    };
  }
}
