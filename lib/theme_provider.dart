import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// 1. The Provider State
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

// 2. The Notifier Logic
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light);

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

// 3. Define the AMOLED Theme Colors
final amoledDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF000000), // PURE BLACK
  primaryColor: Colors.tealAccent,
  colorScheme: const ColorScheme.dark(
    primary: Colors.tealAccent,
    surface: Color(0xFF121212), // Slightly lighter black for cards
    onSurface: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF000000),
    foregroundColor: Colors.tealAccent,
  ),
  cardTheme: const CardThemeData(
    color: Color(0xFF121212), // Dark Grey cards to pop against black bg
    elevation: 0,
  ),
);

final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
  scaffoldBackgroundColor: Colors.grey.shade50,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.teal,
    foregroundColor: Colors.white,
  ),
);