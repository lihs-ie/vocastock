use shared_auth::VerifiedActorContext;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct VocabularyExpressionDetailRecord {
    pub identifier: String,
    pub text: String,
    pub registration_status: String,
    pub explanation_status: String,
    pub image_status: String,
    pub current_explanation: Option<String>,
    pub current_image: Option<String>,
    pub registered_at: String,
}

pub trait VocabularyExpressionDetailSource {
    fn record_for(
        &self,
        actor_context: &VerifiedActorContext,
        identifier: &str,
    ) -> Option<VocabularyExpressionDetailRecord>;
}
