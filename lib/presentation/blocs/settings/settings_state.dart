import 'package:waterguard/domain/entities/user_settings.dart';

abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final UserSettings settings;

  SettingsLoaded({required this.settings});
}

class SettingsError extends SettingsState {
  final String message;

  SettingsError(this.message);
}