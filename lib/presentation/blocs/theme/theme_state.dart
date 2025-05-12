// lib/presentation/blocs/theme/theme_state.dart
import 'package:flutter/material.dart';

class ThemeState {
  final ThemeMode themeMode;

  bool get isDarkMode => themeMode == ThemeMode.dark;

  ThemeState({this.themeMode = ThemeMode.light});

  ThemeState copyWith({ThemeMode? themeMode}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
    );
  }
}