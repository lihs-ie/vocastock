import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';
import 'src/app_bindings.dart';
import 'src/infrastructure/firebase/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
  if (useLiveBackend) {
    await FirebaseEmulatorBootstrap.initialize();
  }
  runApp(const ProviderScope(child: VocastockApp()));
}
