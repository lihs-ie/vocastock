import 'package:flutter_test/flutter_test.dart';
import 'package:vocastock_mobile/src/domain/auth/actor_handoff_status.dart';
import 'package:vocastock_mobile/src/infrastructure/stub/stub_actor_handoff_controller.dart';

void main() {
  group('StubActorHandoffController', () {
    test('starts in not-started state', () {
      final controller = StubActorHandoffController();
      expect(controller.current, isA<ActorHandoffNotStarted>());
    });

    test('runs through all three stages to completion', () async {
      final controller = StubActorHandoffController();
      final observed = <ActorHandoffStatus>[];
      final subscription = controller.watch().listen(observed.add);

      await controller.signIn(AuthProvider.basic);
      // Drain pending stream events before reading observed list.
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      final stages = observed.whereType<ActorHandoffInProgress>().map(
            (event) => event.stage,
          );
      expect(stages, equals(ActorHandoffStage.values));
      expect(controller.current, isA<ActorHandoffCompleted>());

      await controller.dispose();
    });

    test('injected failure truncates remaining stages', () async {
      final controller = StubActorHandoffController(
        failAt: ActorHandoffStage.backendTokenVerify,
      );

      await controller.signIn(AuthProvider.google);

      expect(controller.current, isA<ActorHandoffFailed>());
      await controller.dispose();
    });

    test('signOut resets state', () async {
      final controller = StubActorHandoffController();
      await controller.signIn(AuthProvider.basic);
      expect(controller.current, isA<ActorHandoffCompleted>());

      await controller.signOut();

      expect(controller.current, isA<ActorHandoffNotStarted>());
      await controller.dispose();
    });
  });
}
