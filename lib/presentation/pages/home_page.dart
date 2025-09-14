import 'package:flutter/material.dart';

/// HomePage — Presentation scaffold for S1.
///
/// Minimal page to confirm routing structure; the actual features
/// (new game, continue, load) are introduced in later sprints.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Open Adventure — S1 scaffold')),
    );
  }
}

