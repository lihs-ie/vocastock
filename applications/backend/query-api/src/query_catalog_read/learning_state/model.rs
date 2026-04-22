use serde::Serialize;

#[derive(Clone, Copy, Debug, Eq, PartialEq, Serialize)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
pub enum ProficiencyLevel {
    Learning,
    Learned,
    Internalized,
    Fluent,
}

impl ProficiencyLevel {
    pub fn parse(raw: &str) -> Option<Self> {
        match raw {
            "learning" => Some(Self::Learning),
            "learned" => Some(Self::Learned),
            "internalized" => Some(Self::Internalized),
            "fluent" => Some(Self::Fluent),
            _ => None,
        }
    }
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct LearningStateView {
    pub vocabulary_expression: String,
    pub proficiency: ProficiencyLevel,
    pub created_at: String,
    pub updated_at: String,
}
