import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waterguard/presentation/blocs/theme/theme_event.dart';
import 'package:waterguard/presentation/blocs/theme/theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState()) {
    on<LoadThemeMode>(_onLoadThemeMode);
    on<ChangeThemeMode>(_onChangeThemeMode);
    on<ToggleTheme>(_onToggleTheme);
  }

  Future<void> _onLoadThemeMode(
      LoadThemeMode event,
      Emitter<ThemeState> emit
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    emit(state.copyWith(
        themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light
    ));
  }

  Future<void> _onChangeThemeMode(
      ChangeThemeMode event,
      Emitter<ThemeState> emit
      ) async {
    await _saveThemePreference(event.themeMode == ThemeMode.dark);
    emit(state.copyWith(themeMode: event.themeMode));
  }

  Future<void> _onToggleTheme(
      ToggleTheme event,
      Emitter<ThemeState> emit
      ) async {
    final newThemeMode = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;

    await _saveThemePreference(newThemeMode == ThemeMode.dark);
    emit(state.copyWith(themeMode: newThemeMode));
  }

  Future<void> _saveThemePreference(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }
}