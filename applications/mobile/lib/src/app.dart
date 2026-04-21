import 'package:flutter/material.dart';

class VocastockApp extends StatelessWidget {
  const VocastockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'vocastock',
      theme: ThemeData.light(useMaterial3: true),
      home: const _BootstrapPlaceholder(),
    );
  }
}

class _BootstrapPlaceholder extends StatelessWidget {
  const _BootstrapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('vocastock mobile client — bootstrap'),
      ),
    );
  }
}
