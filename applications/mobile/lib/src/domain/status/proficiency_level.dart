/// LearningState.proficiency enumeration (spec 005 concept-separation:
/// `Proficiency` is owned by `LearningState`).
///
/// The values progress from initial exposure to full fluency. Subsequent
/// specs (backend learning-state-reader) will surface real assignments;
/// the Flutter client currently relies on a stub provider that
/// deterministically derives a level from the catalog entry identifier.
enum ProficiencyLevel {
  learning,
  learned,
  internalized,
  fluent,
}
