use shared_auth::TokenVerificationError;

pub fn extract_bearer_token(
    authorization_header: Option<&str>,
) -> Result<&str, TokenVerificationError> {
    let header_value = authorization_header
        .map(str::trim)
        .filter(|value| !value.is_empty())
        .ok_or(TokenVerificationError::MissingToken)?;

    let (scheme, token) = header_value
        .split_once(' ')
        .ok_or(TokenVerificationError::InvalidToken)?;

    if !scheme.eq_ignore_ascii_case("bearer") || token.trim().is_empty() {
        return Err(TokenVerificationError::InvalidToken);
    }

    Ok(token.trim())
}
