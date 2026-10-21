import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme.dart';
import 'shell.dart';

void main() {
  runApp(const ProviderScope(child: VibeJourneyApp()));
}

class VibeJourneyApp extends StatelessWidget {
  const VibeJourneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vibe Journey',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const Shell(),
    );
  }
}
