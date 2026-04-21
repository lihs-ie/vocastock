import 'package:meta/meta.dart';

import '../common/user_facing_message.dart';

/// Canonical UI state variants defined by spec 013 data-model.md.
///
/// Screens MUST exhaustively switch over this sealed family so the Dart
/// compiler flags any unhandled variant. Completed payload access is only
/// permitted through the [UIStateCompleted] variant for screens that carry
/// `allowsCompletedPayload = true` per
/// `contracts/generation-result-visibility-contract.md`.
@immutable
sealed class UIStateVariant<T> {
  const UIStateVariant();
}

/// Nothing to display yet; reader is resolving.
@immutable
final class UIStateLoading<T> extends UIStateVariant<T> {
  const UIStateLoading();
}

/// Summary-only payload; completed body must not be rendered.
@immutable
final class UIStateStatusOnly<T> extends UIStateVariant<T> {
  const UIStateStatusOnly(this.summary);
  final T summary;
}

/// Completed payload; only legal on screens that opt in to completed access.
@immutable
final class UIStateCompleted<T> extends UIStateVariant<T> {
  const UIStateCompleted(this.payload);
  final T payload;
}

/// Recoverable failure; UI exposes a retry action backed by a command.
@immutable
final class UIStateRetryableFailure<T> extends UIStateVariant<T> {
  const UIStateRetryableFailure(this.message);
  final UserFacingMessage message;
}

/// Hard stop; screen must not expose normal-use actions, only recovery.
@immutable
final class UIStateHardStop<T> extends UIStateVariant<T> {
  const UIStateHardStop(this.message);
  final UserFacingMessage message;
}
