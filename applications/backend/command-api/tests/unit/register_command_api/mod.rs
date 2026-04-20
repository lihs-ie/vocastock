use command_api::{
    normalize_text, REGISTER_VOCABULARY_EXPRESSION_PATH, ROOT_MESSAGE, SERVICE_NAME,
};

#[test]
fn crate_root_exports_command_api_surface() {
    assert_eq!(SERVICE_NAME, "command-api");
    assert_eq!(
        REGISTER_VOCABULARY_EXPRESSION_PATH,
        "/commands/register-vocabulary-expression"
    );
    assert!(ROOT_MESSAGE.contains("accepted/reused-existing"));
    assert_eq!(
        normalize_text("  Mixed   Case  ").as_deref(),
        Some("mixed case")
    );
}
