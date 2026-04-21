import 'package:meta/meta.dart';

import '../../domain/common/user_facing_message.dart';
import 'command_error.dart';

/// Response returned by every command intake (spec 011).
///
/// Both success and error paths MUST carry a `UserFacingMessage`. The sealed
/// family forces callers to handle both variants explicitly; a command
/// response alone never confirms completed payload visibility — readers must
/// be re-fetched afterwards.
@immutable
sealed class CommandResponseEnvelope {
  const CommandResponseEnvelope({required this.message});
  final UserFacingMessage message;
}

@immutable
final class CommandResponseAccepted extends CommandResponseEnvelope {
  const CommandResponseAccepted({
    required super.message,
    required this.outcome,
  });

  final AcceptanceOutcome outcome;
}

@immutable
final class CommandResponseRejected extends CommandResponseEnvelope {
  const CommandResponseRejected({
    required super.message,
    required this.category,
  });

  final CommandErrorCategory category;
}

/// Whether the command created a new target or reused an existing one
/// (spec 011 idempotency contract).
enum AcceptanceOutcome {
  accepted,
  reusedExisting,
}
