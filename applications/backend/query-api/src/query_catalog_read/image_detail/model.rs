use serde::Serialize;

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct ImageDetailView {
    pub identifier: String,
    pub explanation: String,
    pub asset_reference: String,
    pub description: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub sense_identifier: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub sense_label: Option<String>,
}
