use query_api::ProficiencyLevel;

#[test]
fn proficiency_level_parse_covers_all_variants() {
    assert_eq!(
        ProficiencyLevel::parse("learning"),
        Some(ProficiencyLevel::Learning)
    );
    assert_eq!(
        ProficiencyLevel::parse("learned"),
        Some(ProficiencyLevel::Learned)
    );
    assert_eq!(
        ProficiencyLevel::parse("internalized"),
        Some(ProficiencyLevel::Internalized)
    );
    assert_eq!(
        ProficiencyLevel::parse("fluent"),
        Some(ProficiencyLevel::Fluent)
    );
    assert_eq!(ProficiencyLevel::parse("unknown"), None);
    assert_eq!(ProficiencyLevel::parse(""), None);
}

#[test]
fn view_serializes_with_screaming_snake_case_proficiency() {
    use query_api::LearningStateView;
    let view = LearningStateView {
        vocabulary_expression: "vocab-0000".to_owned(),
        proficiency: ProficiencyLevel::Internalized,
        created_at: "2026-04-05T10:00:00Z".to_owned(),
        updated_at: "2026-04-20T08:30:00Z".to_owned(),
    };
    let serialized = serde_json::to_string(&view).unwrap();
    assert!(serialized.contains("\"proficiency\":\"INTERNALIZED\""));
    assert!(serialized.contains("\"vocabularyExpression\":\"vocab-0000\""));
    assert!(serialized.contains("\"createdAt\":\"2026-04-05T10:00:00Z\""));
}
