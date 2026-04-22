use query_api::explanation_detail::parse_explanation_document;
use serde_json::json;

fn canned_explanation_document() -> serde_json::Value {
    json!({
        "name": "projects/demo-vocastock/databases/(default)/documents/actors/stub-actor-demo/explanations/stub-exp-for-stub-vocab-0000",
        "fields": {
            "id": {"stringValue": "stub-exp-for-stub-vocab-0000"},
            "vocabularyExpression": {"stringValue": "stub-vocab-0000"},
            "text": {"stringValue": "run"},
            "pronunciation": {
                "mapValue": {
                    "fields": {
                        "weak": {"stringValue": "/run/"},
                        "strong": {"stringValue": "/RUN/"}
                    }
                }
            },
            "frequency": {"stringValue": "often"},
            "sophistication": {"stringValue": "veryBasic"},
            "etymology": {"stringValue": "古英語 rinnan に由来する。"},
            "similarities": {
                "arrayValue": {
                    "values": [
                        {
                            "mapValue": {
                                "fields": {
                                    "value": {"stringValue": "sprint"},
                                    "meaning": {"stringValue": "全力疾走する"},
                                    "comparison": {"stringValue": "run よりも短距離で最大速度のニュアンス。"}
                                }
                            }
                        }
                    ]
                }
            },
            "senses": {
                "arrayValue": {
                    "values": [
                        {
                            "mapValue": {
                                "fields": {
                                    "identifier": {"stringValue": "s1"},
                                    "order": {"integerValue": "1"},
                                    "label": {"stringValue": "走る"},
                                    "situation": {"stringValue": "スポーツ・日常の移動"},
                                    "nuance": {"stringValue": "歩くより速い速度"},
                                    "examples": {
                                        "arrayValue": {
                                            "values": [
                                                {
                                                    "mapValue": {
                                                        "fields": {
                                                            "value": {"stringValue": "I run every morning before work."},
                                                            "meaning": {"stringValue": "毎朝、仕事の前に走っています。"}
                                                        }
                                                    }
                                                }
                                            ]
                                        }
                                    },
                                    "collocations": {
                                        "arrayValue": {
                                            "values": [
                                                {
                                                    "mapValue": {
                                                        "fields": {
                                                            "value": {"stringValue": "run fast"},
                                                            "meaning": {"stringValue": "速く走る"}
                                                        }
                                                    }
                                                }
                                            ]
                                        }
                                    }
                                }
                            }
                        }
                    ]
                }
            }
        }
    })
}

#[test]
fn parses_nested_map_and_array_values() {
    let payload = canned_explanation_document();
    let record = parse_explanation_document(&payload).expect("document parses");

    assert_eq!(record.identifier, "stub-exp-for-stub-vocab-0000");
    assert_eq!(record.vocabulary_expression, "stub-vocab-0000");
    assert_eq!(record.pronunciation.weak, "/run/");
    assert_eq!(record.pronunciation.strong, "/RUN/");
    assert_eq!(record.similarities.len(), 1);
    assert_eq!(record.similarities[0].value, "sprint");
    assert_eq!(record.senses.len(), 1);
    let sense = &record.senses[0];
    assert_eq!(sense.identifier, "s1");
    assert_eq!(
        sense.order, 1,
        "integerValue is encoded as a string in Firestore REST but must parse back to i64"
    );
    assert_eq!(sense.examples.len(), 1);
    assert_eq!(sense.examples[0].value, "I run every morning before work.");
    assert_eq!(sense.collocations.len(), 1);
    assert_eq!(sense.collocations[0].value, "run fast");
}

#[test]
fn returns_none_when_fields_envelope_is_absent() {
    let payload = json!({"error": {"code": 404, "status": "NOT_FOUND"}});
    assert!(parse_explanation_document(&payload).is_none());
}

#[test]
fn returns_none_when_required_fields_are_missing() {
    let payload = json!({
        "fields": {
            "text": {"stringValue": "run"}
        }
    });
    assert!(
        parse_explanation_document(&payload).is_none(),
        "missing id / vocabularyExpression must disqualify the record"
    );
}
