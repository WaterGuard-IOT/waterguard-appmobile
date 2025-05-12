import 'package:flutter/material.dart';

abstract class ThemeEvent {}

class LoadThemeMode extends ThemeEvent {}

class ChangeThemeMode extends ThemeEvent {
  final ThemeMode themeMode;
  ChangeThemeMode(this.themeMode);
}

class ToggleTheme extends ThemeEvent {}