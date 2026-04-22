use query_api::{
    CollocationView, ExplanationDetailView, FrequencyLevel, PronunciationView, SenseExampleView,
    SenseView, SimilarExpressionView, SophisticationLevel,
};

#[test]
fn frequency_and_sophistication_parse_covers_all_variants() {
    assert_eq!(FrequencyLevel::parse("often"), FrequencyLevel::Often);
    assert_eq!(
        FrequencyLevel::parse("sometimes"),
        FrequencyLevel::Sometimes
    );
    assert_eq!(FrequencyLevel::parse("rarely"), FrequencyLevel::Rarely);
    assert_eq!(
        FrequencyLevel::parse("hardlyEver"),
        FrequencyLevel::HardlyEver
    );
    assert_eq!(
        FrequencyLevel::parse("unknown"),
        FrequencyLevel::Sometimes,
        "unknown frequency defaults to Sometimes so listings stay informative"
    );

    assert_eq!(
        SophisticationLevel::parse("veryBasic"),
        SophisticationLevel::VeryBasic
    );
    assert_eq!(
        SophisticationLevel::parse("basic"),
        SophisticationLevel::Basic
    );
    assert_eq!(
        SophisticationLevel::parse("intermediate"),
        SophisticationLevel::Intermediate
    );
    assert_eq!(
        SophisticationLevel::parse("advanced"),
        SophisticationLevel::Advanced
    );
    assert_eq!(
        SophisticationLevel::parse("unknown"),
        SophisticationLevel::Basic
    );
}

#[test]
fn view_serializes_with_graphql_enum_strings_and_nested_collections() {
    let view = ExplanationDetailView {
        identifier: "stub-exp-for-stub-vocab-0000".to_owned(),
        vocabulary_expression: "stub-vocab-0000".to_owned(),
        text: "run".to_owned(),
        pronunciation: PronunciationView {
            weak: "/run/".to_owned(),
            strong: "/RUN/".to_owned(),
        },
        frequency: FrequencyLevel::Often,
        sophistication: SophisticationLevel::VeryBasic,
        etymology: "古英語 rinnan に由来する。".to_owned(),
        similarities: vec![SimilarExpressionView {
            value: "sprint".to_owned(),
            meaning: "全力疾走する".to_owned(),
            comparison: "run よりも短距離で最大速度のニュアンス。".to_owned(),
        }],
        senses: vec![SenseView {
            identifier: "s1".to_owned(),
            order: 1,
            label: "走る".to_owned(),
            situation: "スポーツ・日常の移動".to_owned(),
            nuance: "歩くより速い速度で足を交互に動かす最も中核的な意味。".to_owned(),
            examples: vec![SenseExampleView {
                value: "I run every morning before work.".to_owned(),
                meaning: "毎朝、仕事の前に走っています。".to_owned(),
                pronunciation: None,
            }],
            collocations: vec![CollocationView {
                value: "run fast".to_owned(),
                meaning: "速く走る".to_owned(),
            }],
        }],
    };

    let serialized = serde_json::to_string(&view).expect("view should serialize");

    assert!(serialized.contains("\"identifier\":\"stub-exp-for-stub-vocab-0000\""));
    assert!(serialized.contains("\"vocabularyExpression\":\"stub-vocab-0000\""));
    assert!(serialized.contains("\"frequency\":\"OFTEN\""));
    assert!(serialized.contains("\"sophistication\":\"VERY_BASIC\""));
    assert!(serialized.contains("\"pronunciation\":{\"weak\":\"/run/\",\"strong\":\"/RUN/\"}"));
    assert!(serialized.contains("\"label\":\"走る\""));
    assert!(serialized.contains("\"collocations\":[{\"value\":\"run fast\""));
    assert!(
        !serialized.contains("\"pronunciation\":null"),
        "None pronunciation at the example level should be skipped"
    );
}
