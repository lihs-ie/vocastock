use query_api::LearningStateRecord;

#[test]
fn record_is_a_plain_data_struct_with_public_fields() {
    let record = LearningStateRecord {
        vocabulary_expression: "vocab-0000".to_owned(),
        proficiency: "learned".to_owned(),
        created_at: "2026-04-05T10:00:00Z".to_owned(),
        updated_at: "2026-04-20T08:30:00Z".to_owned(),
    };
    assert_eq!(record.vocabulary_expression, "vocab-0000");
    assert_eq!(record.proficiency, "learned");
}
