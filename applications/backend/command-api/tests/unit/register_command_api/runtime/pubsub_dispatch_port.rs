use command_api::{build_dispatch_message, DispatchKind, DispatchRequest};

fn decode_data(base64: &str) -> String {
    const ALPHABET: &[u8; 64] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    let mut lookup = [0u8; 256];
    for (index, byte) in ALPHABET.iter().enumerate() {
        lookup[*byte as usize] = index as u8;
    }
    let bytes = base64.as_bytes();
    let mut out = Vec::new();
    let mut chunks = bytes.chunks_exact(4);
    for chunk in chunks.by_ref() {
        if chunk[0] == b'=' {
            break;
        }
        let a = lookup[chunk[0] as usize] as u32;
        let b = lookup[chunk[1] as usize] as u32;
        let combined = (a << 18) | (b << 12);
        if chunk[2] == b'=' {
            out.push((combined >> 16) as u8);
            break;
        }
        let c = lookup[chunk[2] as usize] as u32;
        let combined = combined | (c << 6);
        if chunk[3] == b'=' {
            out.push((combined >> 16) as u8);
            out.push((combined >> 8) as u8);
            break;
        }
        let d = lookup[chunk[3] as usize] as u32;
        let combined = combined | d;
        out.push((combined >> 16) as u8);
        out.push((combined >> 8) as u8);
        out.push(combined as u8);
    }
    String::from_utf8(out).expect("utf-8 payload")
}

#[test]
fn build_dispatch_message_encodes_explanation_request() {
    let request = DispatchRequest::new("actor:learner", "k1", "", "vocabulary:run", false)
        .with_kind(DispatchKind::ExplanationGeneration);
    let message = build_dispatch_message(&request);

    // Attributes carry actor / idempotency / kind.
    let attributes: std::collections::HashMap<_, _> = message.attributes.iter().cloned().collect();
    assert_eq!(attributes.get("actor"), Some(&"actor:learner".to_owned()));
    assert_eq!(attributes.get("idempotencyKey"), Some(&"k1".to_owned()));
    assert_eq!(
        attributes.get("kind"),
        Some(&"explanation-generation".to_owned())
    );
    assert!(!attributes.contains_key("retryTarget"));
    assert!(!attributes.contains_key("planCode"));

    let payload_json = String::from_utf8(message.data.clone()).expect("utf-8 data");
    assert!(payload_json.contains("\"actor\":\"actor:learner\""));
    assert!(payload_json.contains("\"kind\":\"explanation-generation\""));
    assert!(payload_json.contains("\"vocabularyExpression\":\"vocabulary:run\""));
}

#[test]
fn build_dispatch_message_includes_retry_target_attribute_and_payload() {
    let request = DispatchRequest::new("actor:learner", "k2", "", "vocabulary:run", true)
        .with_kind(DispatchKind::Retry)
        .with_retry_target("IMAGE");
    let message = build_dispatch_message(&request);

    let attributes: std::collections::HashMap<_, _> = message.attributes.iter().cloned().collect();
    assert_eq!(attributes.get("kind"), Some(&"retry".to_owned()));
    assert_eq!(attributes.get("retryTarget"), Some(&"IMAGE".to_owned()));

    let payload_json = String::from_utf8(message.data.clone()).expect("utf-8 data");
    assert!(payload_json.contains("\"retryTarget\":\"IMAGE\""));
    assert!(payload_json.contains("\"restartRequested\":true"));
}

#[test]
fn build_dispatch_message_includes_plan_code_for_purchase() {
    let request = DispatchRequest::new("actor:learner", "k3", "", "", false)
        .with_kind(DispatchKind::Purchase)
        .with_plan_code("STANDARD_MONTHLY");
    let message = build_dispatch_message(&request);

    let attributes: std::collections::HashMap<_, _> = message.attributes.iter().cloned().collect();
    assert_eq!(
        attributes.get("planCode"),
        Some(&"STANDARD_MONTHLY".to_owned())
    );

    let payload_json = String::from_utf8(message.data.clone()).expect("utf-8 data");
    assert!(payload_json.contains("\"planCode\":\"STANDARD_MONTHLY\""));
}

#[test]
fn build_dispatch_message_includes_sense_identifier_for_image_generation() {
    let request = DispatchRequest::new("actor:learner", "k4", "", "vocabulary:run", false)
        .with_kind(DispatchKind::ImageGeneration)
        .with_sense_identifier("sense-001");
    let message = build_dispatch_message(&request);

    let attributes: std::collections::HashMap<_, _> = message.attributes.iter().cloned().collect();
    assert_eq!(attributes.get("kind"), Some(&"image-generation".to_owned()));
    assert_eq!(
        attributes.get("senseIdentifier"),
        Some(&"sense-001".to_owned())
    );

    let payload_json = String::from_utf8(message.data.clone()).expect("utf-8 data");
    assert!(payload_json.contains("\"senseIdentifier\":\"sense-001\""));
}

#[test]
fn build_dispatch_message_omits_sense_identifier_when_absent() {
    let request = DispatchRequest::new("actor:learner", "k5", "", "vocabulary:run", false)
        .with_kind(DispatchKind::ImageGeneration);
    let message = build_dispatch_message(&request);

    let attributes: std::collections::HashMap<_, _> = message.attributes.iter().cloned().collect();
    assert!(!attributes.contains_key("senseIdentifier"));

    let payload_json = String::from_utf8(message.data.clone()).expect("utf-8 data");
    assert!(!payload_json.contains("senseIdentifier"));
}

#[test]
fn decode_data_helper_round_trips() {
    // sanity check the in-test decoder against shared-pubsub's encoder.
    assert_eq!(decode_data("Zm9v"), "foo");
    assert_eq!(decode_data("Zm9vYmFy"), "foobar");
}
