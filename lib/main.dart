import 'package:flutter/material.dart';

void main() {
  runApp(const OpenAdventureApp());
}

/// Minimal bootstrap app for S1 scaffolding.
class OpenAdventureApp extends StatelessWidget {
  const OpenAdventureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Open Adventure',
      home: const _ScaffoldS1(),
    );
  }
}

class _ScaffoldS1 extends StatelessWidget {
  const _ScaffoldS1();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('S1 — Data/Repo scaffolding ready'),
      ),
    );
  }
}
