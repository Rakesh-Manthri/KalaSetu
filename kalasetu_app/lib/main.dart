import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/theme.dart';
import 'features/home/home_screen.dart';

/// KalaSetu Application Entry Point
/// AI-Driven Market Linkage & Smart Cataloging for Marginalized Artisans
/// Smart India Hackathon 2026 | PS 26090
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: KalaSetuApp(),
    ),
  );
}

class KalaSetuApp extends StatelessWidget {
  const KalaSetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KalaSetu कलासेतु',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
