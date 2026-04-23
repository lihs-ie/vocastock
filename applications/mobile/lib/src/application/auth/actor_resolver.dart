import '../../domain/common/actor_reference.dart';

/// Resolves the authenticated Firebase subject into a normalized
/// actor/learner reference via the backend.
///
/// This is stage 3 (`actorResolve`) of the 3-stage actor handoff
/// defined in spec 008. The implementation calls
/// `actorHandoffStatus` through the GraphQL gateway and maps the
/// response into an [ActorReference].
abstract class ActorResolver {
  Future<ActorReference> resolveActor();
}
