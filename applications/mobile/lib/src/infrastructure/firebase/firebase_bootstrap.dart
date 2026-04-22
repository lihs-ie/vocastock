import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Initialises Firebase core + points the Auth / Storage SDKs at the
/// local Firebase emulator suite.
///
/// Emulator ports mirror `docker/firebase/env/.env.example` (Auth 19099,
/// Storage 19199). Firestore is **not** used directly from Flutter — the
/// client reaches `/actors/{uid}/...` through the GraphQL gateway
/// (`applications/backend/graphql-gateway`). Only Auth (for ID tokens)
/// and Storage (for rendered illustration downloads) are consumed
/// directly by the mobile app.
class FirebaseEmulatorBootstrap {
  const FirebaseEmulatorBootstrap._();

  static const String projectId = 'demo-vocastock';
  static const String storageBucket = 'demo-vocastock.firebasestorage.app';

  static const int authPort = 19099;
  static const int storagePort = 19199;

  /// iOS simulator shares the host network stack so `127.0.0.1` resolves
  /// to the host Mac. Android emulator requires the magic address
  /// `10.0.2.2` for the same destination.
  static String get emulatorHost {
    if (Platform.isAndroid) return '10.0.2.2';
    return '127.0.0.1';
  }

  /// Initialise the default `FirebaseApp` with demo options. Idempotent —
  /// repeated calls within a process are no-ops because `initializeApp`
  /// throws `duplicate-app` and we swallow it.
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'demo-emulator-api-key',
          appId: '1:0000000000:ios:0000000000',
          messagingSenderId: '0000000000',
          projectId: projectId,
          storageBucket: storageBucket,
        ),
      );
    } on FirebaseException catch (error) {
      if (error.code != 'duplicate-app') rethrow;
    }

    await FirebaseAuth.instance.useAuthEmulator(emulatorHost, authPort);
    await FirebaseStorage.instance.useStorageEmulator(
      emulatorHost,
      storagePort,
    );
  }
}
