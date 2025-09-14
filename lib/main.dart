// main.dart

import 'package:flutter/material.dart';
import 'features/adventure/presentation/pages/adventure_page.dart';

void main() {
  // Set up dependency injection here if needed
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Build your root widget
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adventure Game',
      home: AdventurePage(),
    );
  }
}
