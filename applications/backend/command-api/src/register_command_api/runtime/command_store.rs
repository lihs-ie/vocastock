use crate::command::{
    AcceptedCommandResult, DuplicateReuseResult, RegisterVocabularyExpressionCommand,
};

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct StoredRegistration {
    pub vocabulary_expression: String,
    pub registration_state: String,
    pub explanation_state: String,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct PlannedNewRegistration {
    pub vocabulary_expression: String,
    pub explanation_state: String,
    pub dispatch_required: bool,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct PlannedReuseRegistration {
    pub existing_registration: StoredRegistration,
    pub resulting_explanation_state: String,
    pub duplicate_reuse: DuplicateReuseResult,
    pub dispatch_required: bool,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum StoreDecision {
    AcceptNew(PlannedNewRegistration),
    ReplayExisting(AcceptedCommandResult),
    ReuseExisting(PlannedReuseRegistration),
    Conflict,
}

/// Port for the register-vocabulary-expression authoritative write
/// path. The production adapter lives in `firestore_command_store`;
/// the deterministic in-memory double used by unit tests lives under
/// `tests/support/command_store.rs`.
pub trait CommandStore {
    fn plan(&self, command: &RegisterVocabularyExpressionCommand) -> StoreDecision;
    fn commit_new(
        &self,
        command: &RegisterVocabularyExpressionCommand,
        plan: &PlannedNewRegistration,
        result: &AcceptedCommandResult,
    );
    fn commit_reuse(
        &self,
        command: &RegisterVocabularyExpressionCommand,
        plan: &PlannedReuseRegistration,
        result: &AcceptedCommandResult,
    );
}
