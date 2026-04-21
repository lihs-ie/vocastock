use serde::Serialize;

#[derive(Clone, Copy, Debug, Eq, PartialEq, Serialize)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
pub enum FrequencyLevel {
    Often,
    Sometimes,
    Rarely,
    HardlyEver,
}

impl FrequencyLevel {
    pub fn parse(raw: &str) -> Self {
        match raw {
            "often" => Self::Often,
            "rarely" => Self::Rarely,
            "hardlyEver" => Self::HardlyEver,
            _ => Self::Sometimes,
        }
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq, Serialize)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
pub enum SophisticationLevel {
    VeryBasic,
    Basic,
    Intermediate,
    Advanced,
}

impl SophisticationLevel {
    pub fn parse(raw: &str) -> Self {
        match raw {
            "veryBasic" => Self::VeryBasic,
            "intermediate" => Self::Intermediate,
            "advanced" => Self::Advanced,
            _ => Self::Basic,
        }
    }
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
pub struct PronunciationView {
    pub weak: String,
    pub strong: String,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
pub struct SimilarExpressionView {
    pub value: String,
    pub meaning: String,
    pub comparison: String,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
pub struct SenseExampleView {
    pub value: String,
    pub meaning: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub pronunciation: Option<String>,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
pub struct CollocationView {
    pub value: String,
    pub meaning: String,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
pub struct SenseView {
    pub identifier: String,
    pub order: i64,
    pub label: String,
    pub situation: String,
    pub nuance: String,
    pub examples: Vec<SenseExampleView>,
    pub collocations: Vec<CollocationView>,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct ExplanationDetailView {
    pub identifier: String,
    pub vocabulary_expression: String,
    pub text: String,
    pub pronunciation: PronunciationView,
    pub frequency: FrequencyLevel,
    pub sophistication: SophisticationLevel,
    pub etymology: String,
    pub similarities: Vec<SimilarExpressionView>,
    pub senses: Vec<SenseView>,
}
