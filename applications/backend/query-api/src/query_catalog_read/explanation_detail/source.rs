use shared_auth::VerifiedActorContext;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct PronunciationRecord {
    pub weak: String,
    pub strong: String,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct SimilarityRecord {
    pub value: String,
    pub meaning: String,
    pub comparison: String,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct SenseExampleRecord {
    pub value: String,
    pub meaning: String,
    pub pronunciation: Option<String>,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct CollocationRecord {
    pub value: String,
    pub meaning: String,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct SenseRecord {
    pub identifier: String,
    pub order: i64,
    pub label: String,
    pub situation: String,
    pub nuance: String,
    pub examples: Vec<SenseExampleRecord>,
    pub collocations: Vec<CollocationRecord>,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct ExplanationDetailRecord {
    pub identifier: String,
    pub vocabulary_expression: String,
    pub text: String,
    pub pronunciation: PronunciationRecord,
    pub frequency: String,
    pub sophistication: String,
    pub etymology: String,
    pub similarities: Vec<SimilarityRecord>,
    pub senses: Vec<SenseRecord>,
}

pub trait ExplanationDetailSource {
    fn record_for(
        &self,
        actor_context: &VerifiedActorContext,
        identifier: &str,
    ) -> Option<ExplanationDetailRecord>;
}
