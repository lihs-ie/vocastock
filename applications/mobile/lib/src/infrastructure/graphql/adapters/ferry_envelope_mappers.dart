// Duck-typing across the ferry-generated envelope types (each mutation
// has its own type even though the shape is identical). Concrete types
// are not unifiable, so dynamic access is intentional here.
// ignore_for_file: avoid_dynamic_calls

import 'package:gql_exec/gql_exec.dart';

import '../../../application/envelope/command_error.dart';
import '../../../application/envelope/command_response_envelope.dart';
import '../../../domain/common/user_facing_message.dart';

/// Shared helper that translates the `CommandResponseEnvelope` returned by
/// every mutation into the domain type consumed by presentation commands.
///
/// Accepts either the BuiltValue-generated envelope data (from ferry) or
/// the generic `GraphqlError` list so link-level failures also surface as
/// rejection envelopes instead of throwing.
class FerryEnvelopeMappers {
  const FerryEnvelopeMappers._();

  static CommandResponseEnvelope fromResponse(
    dynamic envelope,
    Object? linkException,
    List<GraphQLError>? graphqlErrors,
  ) {
    if (envelope == null) {
      final message = linkException != null
          ? linkException.toString()
          : graphqlErrors?.first.message ??
              'graphql-gateway did not return a response';
      return CommandResponseRejected(
        message: UserFacingMessage(
          key: 'downstream.graphql-gateway-failure',
          text: message,
        ),
        category: CommandErrorCategory.downstreamUnavailable,
      );
    }
    final accepted = envelope.accepted as bool;
    if (accepted) {
      final outcome = envelope.outcome;
      return CommandResponseAccepted(
        message: UserFacingMessage(
          key: envelope.message.key as String,
          text: envelope.message.text as String,
        ),
        outcome: switch (outcome?.name as String?) {
          'REUSED_EXISTING' => AcceptanceOutcome.reusedExisting,
          _ => AcceptanceOutcome.accepted,
        },
      );
    }
    final errorCategory = envelope.errorCategory;
    return CommandResponseRejected(
      message: UserFacingMessage(
        key: envelope.message.key as String,
        text: envelope.message.text as String,
      ),
      category: switch (errorCategory?.name as String?) {
        'VALIDATION_FAILED' => CommandErrorCategory.validationFailed,
        'TARGET_MISSING' => CommandErrorCategory.targetMissing,
        'TARGET_NOT_READY' => CommandErrorCategory.targetNotReady,
        'DISPATCH_FAILED' => CommandErrorCategory.dispatchFailed,
        'DOWNSTREAM_UNAVAILABLE' =>
          CommandErrorCategory.downstreamUnavailable,
        'DOWNSTREAM_AUTH_FAILED' =>
          CommandErrorCategory.downstreamAuthFailed,
        _ => CommandErrorCategory.downstreamUnavailable,
      },
    );
  }
}
