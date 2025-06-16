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

// Estado faltante que se usa en settings_bloc.dart
class SettingsUpdatedSuccessfully extends SettingsState {
  final String message;
  final UserSettings settings;

  SettingsUpdatedSuccessfully({
    required this.message,
    required this.settings,
  });
}