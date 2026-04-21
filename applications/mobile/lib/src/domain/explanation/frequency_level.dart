/// How frequently the expression appears in English usage (spec 005).
enum FrequencyLevel {
  often,
  sometimes,
  rarely,
  hardlyEver,
}

extension FrequencyLevelLabel on FrequencyLevel {
  /// Japanese short label used on Detail chips (matches `tokens.jsx`
  /// `FREQ_JA`).
  String get labelJa {
    return switch (this) {
      FrequencyLevel.often => '頻出',
      FrequencyLevel.sometimes => '時々',
      FrequencyLevel.rarely => '稀',
      FrequencyLevel.hardlyEver => 'ほぼ無し',
    };
  }
}
