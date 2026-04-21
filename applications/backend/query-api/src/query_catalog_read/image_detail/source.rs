use shared_auth::VerifiedActorContext;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct ImageDetailRecord {
    pub identifier: String,
    pub explanation: String,
    pub asset_reference: String,
    pub description: String,
    pub sense_identifier: Option<String>,
    pub sense_label: Option<String>,
}

pub trait ImageDetailSource {
    fn record_for(
        &self,
        actor_context: &VerifiedActorContext,
        identifier: &str,
    ) -> Option<ImageDetailRecord>;
}
