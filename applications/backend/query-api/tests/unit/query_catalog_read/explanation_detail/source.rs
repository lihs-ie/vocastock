use query_api::{
    CollocationRecord, ExplanationDetailRecord, PronunciationRecord, SenseExampleRecord,
    SenseRecord, SimilarityRecord,
};

#[test]
fn explanation_detail_record_is_clone_and_eq() {
    let record = ExplanationDetailRecord {
        identifier: "stub-exp".to_owned(),
        vocabulary_expression: "stub-vocab".to_owned(),
        text: "run".to_owned(),
        pronunciation: PronunciationRecord {
            weak: "/run/".to_owned(),
            strong: "/RUN/".to_owned(),
        },
        frequency: "often".to_owned(),
        sophistication: "veryBasic".to_owned(),
        etymology: "-".to_owned(),
        similarities: vec![SimilarityRecord {
            value: "sprint".to_owned(),
            meaning: "-".to_owned(),
            comparison: "-".to_owned(),
        }],
        senses: vec![SenseRecord {
            identifier: "s1".to_owned(),
            order: 1,
            label: "走る".to_owned(),
            situation: "-".to_owned(),
            nuance: "-".to_owned(),
            examples: vec![SenseExampleRecord {
                value: "I run.".to_owned(),
                meaning: "走る。".to_owned(),
                pronunciation: None,
            }],
            collocations: vec![CollocationRecord {
                value: "run fast".to_owned(),
                meaning: "速く走る".to_owned(),
            }],
        }],
    };
    assert_eq!(record.clone(), record);
    assert_eq!(record.senses[0].examples[0].value, "I run.");
}
