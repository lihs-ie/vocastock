use shared_auth::VerifiedActorContext;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct LearningStateRecord {
    pub vocabulary_expression: String,
    pub proficiency: String,
    pub created_at: String,
    pub updated_at: String,
}

pub trait LearningStateSource {
    fn record_for(
        &self,
        actor_context: &VerifiedActorContext,
        vocabulary_expression: &str,
    ) -> Option<LearningStateRecord>;

    fn all_records_for(&self, actor_context: &VerifiedActorContext) -> Vec<LearningStateRecord>;
}
