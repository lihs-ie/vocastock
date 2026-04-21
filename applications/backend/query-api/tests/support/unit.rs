use std::cell::RefCell;
use std::collections::{BTreeMap, HashMap};

use query_api::{
    AllowanceRecord, CollocationRecord, ExplanationDetailRecord, ExplanationDetailSource,
    ImageDetailRecord, ImageDetailSource, InMemoryCatalogProjectionSource, ProjectionSourceRecord,
    PronunciationRecord, SenseExampleRecord, SenseRecord, SimilarityRecord, SubscriptionRecord,
    SubscriptionStatusSource, VocabularyExpressionDetailRecord, VocabularyExpressionDetailSource,
};
use shared_auth::{
    ActorReference, AuthAccountReference, SessionReference, SessionState, VerifiedActorContext,
};

pub fn active_actor() -> VerifiedActorContext {
    VerifiedActorContext::new(
        ActorReference::new("actor:learner"),
        AuthAccountReference::new("auth:actor:learner"),
        SessionReference::new("session:actor:learner"),
        SessionState::Active,
    )
}

pub fn reauth_actor() -> VerifiedActorContext {
    VerifiedActorContext::new(
        ActorReference::new("actor:learner"),
        AuthAccountReference::new("auth:actor:learner"),
        SessionReference::new("session:actor:learner"),
        SessionState::ReauthRequired,
    )
}

pub fn empty_actor() -> VerifiedActorContext {
    custom_actor("actor:empty")
}

pub fn other_actor() -> VerifiedActorContext {
    custom_actor("actor:other")
}

pub fn custom_actor(actor_reference: &str) -> VerifiedActorContext {
    VerifiedActorContext::new(
        ActorReference::new(actor_reference),
        AuthAccountReference::new(format!("auth:{actor_reference}")),
        SessionReference::new(format!("session:{actor_reference}")),
        SessionState::Active,
    )
}

pub fn custom_source(records: Vec<ProjectionSourceRecord>) -> InMemoryCatalogProjectionSource {
    let mut actor_records = BTreeMap::new();
    actor_records.insert("actor:learner".to_owned(), records);
    InMemoryCatalogProjectionSource::from_actor_records(actor_records)
}

// ---------- Test doubles for detail sources -------------------------------
// These are declared in tests/support/ (not in the production crate) so
// the "no in-memory production adapters" constraint from the plan is
// preserved. They exist only to exercise pure application logic.

pub struct VocabularyExpressionDetailTestSource {
    records: HashMap<(String, String), VocabularyExpressionDetailRecord>,
    calls: RefCell<Vec<(String, String)>>,
}

impl VocabularyExpressionDetailTestSource {
    pub fn empty() -> Self {
        Self {
            records: HashMap::new(),
            calls: RefCell::new(Vec::new()),
        }
    }

    pub fn with_record(actor: &str, record: VocabularyExpressionDetailRecord) -> Self {
        let mut records = HashMap::new();
        records.insert((actor.to_owned(), record.identifier.clone()), record);
        Self {
            records,
            calls: RefCell::new(Vec::new()),
        }
    }

    pub fn calls(&self) -> Vec<(String, String)> {
        self.calls.borrow().clone()
    }
}

impl VocabularyExpressionDetailSource for VocabularyExpressionDetailTestSource {
    fn record_for(
        &self,
        actor_context: &VerifiedActorContext,
        identifier: &str,
    ) -> Option<VocabularyExpressionDetailRecord> {
        let actor = actor_context.actor().as_str().to_owned();
        self.calls
            .borrow_mut()
            .push((actor.clone(), identifier.to_owned()));
        self.records.get(&(actor, identifier.to_owned())).cloned()
    }
}

pub struct ExplanationDetailTestSource {
    records: HashMap<(String, String), ExplanationDetailRecord>,
}

impl ExplanationDetailTestSource {
    pub fn empty() -> Self {
        Self {
            records: HashMap::new(),
        }
    }

    pub fn with_record(actor: &str, record: ExplanationDetailRecord) -> Self {
        let mut records = HashMap::new();
        records.insert((actor.to_owned(), record.identifier.clone()), record);
        Self { records }
    }
}

impl ExplanationDetailSource for ExplanationDetailTestSource {
    fn record_for(
        &self,
        actor_context: &VerifiedActorContext,
        identifier: &str,
    ) -> Option<ExplanationDetailRecord> {
        self.records
            .get(&(
                actor_context.actor().as_str().to_owned(),
                identifier.to_owned(),
            ))
            .cloned()
    }
}

pub struct ImageDetailTestSource {
    records: HashMap<(String, String), ImageDetailRecord>,
}

impl ImageDetailTestSource {
    pub fn empty() -> Self {
        Self {
            records: HashMap::new(),
        }
    }

    pub fn with_record(actor: &str, record: ImageDetailRecord) -> Self {
        let mut records = HashMap::new();
        records.insert((actor.to_owned(), record.identifier.clone()), record);
        Self { records }
    }
}

impl ImageDetailSource for ImageDetailTestSource {
    fn record_for(
        &self,
        actor_context: &VerifiedActorContext,
        identifier: &str,
    ) -> Option<ImageDetailRecord> {
        self.records
            .get(&(
                actor_context.actor().as_str().to_owned(),
                identifier.to_owned(),
            ))
            .cloned()
    }
}

pub struct SubscriptionStatusTestSource {
    records: HashMap<String, SubscriptionRecord>,
}

impl SubscriptionStatusTestSource {
    pub fn empty() -> Self {
        Self {
            records: HashMap::new(),
        }
    }

    pub fn with_record(actor: &str, record: SubscriptionRecord) -> Self {
        let mut records = HashMap::new();
        records.insert(actor.to_owned(), record);
        Self { records }
    }
}

impl SubscriptionStatusSource for SubscriptionStatusTestSource {
    fn record_for(&self, actor_context: &VerifiedActorContext) -> Option<SubscriptionRecord> {
        self.records.get(actor_context.actor().as_str()).cloned()
    }
}

// ---------- Sample records ------------------------------------------------

pub fn sample_vocabulary_expression_record() -> VocabularyExpressionDetailRecord {
    VocabularyExpressionDetailRecord {
        identifier: "stub-vocab-0000".to_owned(),
        text: "run".to_owned(),
        registration_status: "active".to_owned(),
        explanation_status: "succeeded".to_owned(),
        image_status: "succeeded".to_owned(),
        current_explanation: Some("stub-exp-for-stub-vocab-0000".to_owned()),
        current_image: Some("stub-img-for-stub-vocab-0000".to_owned()),
        registered_at: "2026-04-05T10:00:00.000Z".to_owned(),
    }
}

pub fn sample_explanation_record() -> ExplanationDetailRecord {
    ExplanationDetailRecord {
        identifier: "stub-exp-for-stub-vocab-0000".to_owned(),
        vocabulary_expression: "stub-vocab-0000".to_owned(),
        text: "run".to_owned(),
        pronunciation: PronunciationRecord {
            weak: "/run/".to_owned(),
            strong: "/RUN/".to_owned(),
        },
        frequency: "often".to_owned(),
        sophistication: "veryBasic".to_owned(),
        etymology: "古英語 rinnan に由来する。".to_owned(),
        similarities: vec![SimilarityRecord {
            value: "sprint".to_owned(),
            meaning: "全力疾走する".to_owned(),
            comparison: "run よりも短距離で最大速度のニュアンス。".to_owned(),
        }],
        senses: vec![SenseRecord {
            identifier: "s1".to_owned(),
            order: 1,
            label: "走る".to_owned(),
            situation: "スポーツ・日常の移動".to_owned(),
            nuance: "歩くより速い速度で足を交互に動かす最も中核的な意味。".to_owned(),
            examples: vec![SenseExampleRecord {
                value: "I run every morning before work.".to_owned(),
                meaning: "毎朝、仕事の前に走っています。".to_owned(),
                pronunciation: None,
            }],
            collocations: vec![CollocationRecord {
                value: "run fast".to_owned(),
                meaning: "速く走る".to_owned(),
            }],
        }],
    }
}

pub fn sample_image_record() -> ImageDetailRecord {
    ImageDetailRecord {
        identifier: "stub-img-for-stub-vocab-0000".to_owned(),
        explanation: "stub-exp-for-stub-vocab-0000".to_owned(),
        asset_reference: "actors/stub-actor-demo/images/stub-img-for-stub-vocab-0000.png"
            .to_owned(),
        description: "「run」を視覚化したイラスト".to_owned(),
        sense_identifier: Some("s1".to_owned()),
        sense_label: Some("走る".to_owned()),
    }
}

pub fn sample_subscription_record() -> SubscriptionRecord {
    SubscriptionRecord {
        state: "active".to_owned(),
        plan: "standardMonthly".to_owned(),
        entitlement: "premiumGeneration".to_owned(),
        allowance: AllowanceRecord {
            remaining_explanation_generations: 82,
            remaining_image_generations: 27,
        },
    }
}
