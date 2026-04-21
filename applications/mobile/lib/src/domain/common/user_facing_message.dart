import 'package:meta/meta.dart';

/// User-facing text used for command response envelopes and UI error rendering
/// (spec 011). The `key` stays stable for localization while `text` carries the
/// rendered copy from the backend.
@immutable
class UserFacingMessage {
  const UserFacingMessage({required this.key, required this.text});

  final String key;
  final String text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserFacingMessage && other.key == key && other.text == text);

  @override
  int get hashCode => Object.hash(key, text);

  @override
  String toString() => 'UserFacingMessage($key)';
}
