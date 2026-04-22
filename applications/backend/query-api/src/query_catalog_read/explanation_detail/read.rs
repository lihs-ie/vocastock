use shared_auth::{self, TokenVerificationPort, VerifiedActorContext};

use super::model::{
    CollocationView, ExplanationDetailView, FrequencyLevel, PronunciationView, SenseExampleView,
    SenseView, SimilarExpressionView, SophisticationLevel,
};
use super::source::{
    CollocationRecord, ExplanationDetailRecord, ExplanationDetailSource, PronunciationRecord,
    SenseExampleRecord, SenseRecord, SimilarityRecord,
};
use crate::runtime::authorization::extract_bearer_token;

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum ExplanationDetailError {
    Auth(shared_auth::TokenVerificationError),
    InactiveSession,
    MissingIdentifier,
}

impl ExplanationDetailError {
    pub fn user_message(&self) -> &'static str {
        match self {
            Self::Auth(error) => error.message(),
            Self::InactiveSession => "session is not active",
            Self::MissingIdentifier => "identifier is required",
        }
    }
}

pub fn read_explanation_detail(
    actor_context: &VerifiedActorContext,
    identifier: &str,
    source: &(impl ExplanationDetailSource + ?Sized),
) -> Result<Option<ExplanationDetailView>, ExplanationDetailError> {
    if !actor_context.is_active() {
        return Err(ExplanationDetailError::InactiveSession);
    }
    if identifier.trim().is_empty() {
        return Err(ExplanationDetailError::MissingIdentifier);
    }

    Ok(source.record_for(actor_context, identifier).map(map_record))
}

pub fn read_explanation_detail_from_authorization_header(
    authorization_header: Option<&str>,
    identifier: &str,
    verifier: &(impl TokenVerificationPort + ?Sized),
    source: &(impl ExplanationDetailSource + ?Sized),
) -> Result<Option<ExplanationDetailView>, ExplanationDetailError> {
    let bearer_token =
        extract_bearer_token(authorization_header).map_err(ExplanationDetailError::Auth)?;
    let actor_context = verifier
        .verify(bearer_token)
        .map_err(ExplanationDetailError::Auth)?;

    read_explanation_detail(&actor_context, identifier, source)
}

fn map_record(record: ExplanationDetailRecord) -> ExplanationDetailView {
    ExplanationDetailView {
        identifier: record.identifier,
        vocabulary_expression: record.vocabulary_expression,
        text: record.text,
        pronunciation: map_pronunciation(record.pronunciation),
        frequency: FrequencyLevel::parse(record.frequency.as_str()),
        sophistication: SophisticationLevel::parse(record.sophistication.as_str()),
        etymology: record.etymology,
        similarities: record
            .similarities
            .into_iter()
            .map(map_similarity)
            .collect(),
        senses: record.senses.into_iter().map(map_sense).collect(),
    }
}

fn map_pronunciation(record: PronunciationRecord) -> PronunciationView {
    PronunciationView {
        weak: record.weak,
        strong: record.strong,
    }
}

fn map_similarity(record: SimilarityRecord) -> SimilarExpressionView {
    SimilarExpressionView {
        value: record.value,
        meaning: record.meaning,
        comparison: record.comparison,
    }
}

fn map_sense(record: SenseRecord) -> SenseView {
    SenseView {
        identifier: record.identifier,
        order: record.order,
        label: record.label,
        situation: record.situation,
        nuance: record.nuance,
        examples: record.examples.into_iter().map(map_example).collect(),
        collocations: record
            .collocations
            .into_iter()
            .map(map_collocation)
            .collect(),
    }
}

fn map_example(record: SenseExampleRecord) -> SenseExampleView {
    SenseExampleView {
        value: record.value,
        meaning: record.meaning,
        pronunciation: record.pronunciation,
    }
}

fn map_collocation(record: CollocationRecord) -> CollocationView {
    CollocationView {
        value: record.value,
        meaning: record.meaning,
    }
}
