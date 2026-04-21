//! Shared helpers for parsing the Firestore REST representation of
//! document fields. The REST envelope wraps each value in a typed
//! object (e.g. `{"stringValue":"foo"}`), so individual readers need to
//! reach through that wrapper to recover the native value.
//!
//! Kept in the `catalog` module so it stays co-located with the first
//! Firestore adapter while the remaining detail readers adopt the same
//! convention. Access is `pub(crate)` — sibling modules only.

use serde_json::{Map, Value};

pub(crate) fn read_string_field(fields: &Map<String, Value>, key: &str) -> Option<String> {
    fields
        .get(key)
        .and_then(Value::as_object)
        .and_then(|object| object.get("stringValue"))
        .and_then(Value::as_str)
        .map(str::to_owned)
}

/// Returns `Some(Some(..))` when the field exists and holds a
/// `stringValue`, `Some(None)` when it is explicitly `nullValue`, and
/// `None` when the key is absent entirely.
pub(crate) fn read_nullable_string_field(
    fields: &Map<String, Value>,
    key: &str,
) -> Option<Option<String>> {
    let field = fields.get(key)?.as_object()?;
    if field.contains_key("nullValue") {
        return Some(None);
    }
    field
        .get("stringValue")
        .and_then(Value::as_str)
        .map(|value| Some(value.to_owned()))
}

pub(crate) fn read_integer_field(fields: &Map<String, Value>, key: &str) -> Option<i64> {
    let field = fields.get(key)?.as_object()?;
    if let Some(raw) = field.get("integerValue") {
        if let Some(as_number) = raw.as_i64() {
            return Some(as_number);
        }
        if let Some(as_str) = raw.as_str() {
            return as_str.parse::<i64>().ok();
        }
    }
    None
}

pub(crate) fn read_map_field<'a>(
    fields: &'a Map<String, Value>,
    key: &str,
) -> Option<&'a Map<String, Value>> {
    fields
        .get(key)?
        .as_object()?
        .get("mapValue")?
        .as_object()?
        .get("fields")?
        .as_object()
}

pub(crate) fn read_array_field<'a>(
    fields: &'a Map<String, Value>,
    key: &str,
) -> Option<&'a Vec<Value>> {
    fields
        .get(key)?
        .as_object()?
        .get("arrayValue")?
        .as_object()?
        .get("values")?
        .as_array()
}

/// When iterating an `arrayValue.values` array, each element is a
/// Firestore value wrapper. For array elements whose entries are
/// maps, descend through `mapValue.fields` to reach the nested field
/// map.
pub(crate) fn value_as_map(value: &Value) -> Option<&Map<String, Value>> {
    value
        .as_object()?
        .get("mapValue")?
        .as_object()?
        .get("fields")?
        .as_object()
}
