// lib/presentation/blocs/settings/settings_event.dart
abstract class SettingsEvent {}

class LoadSettings extends SettingsEvent {}

class UpdatePhThresholds extends SettingsEvent {
  final double minPh;
  final double maxPh;

  UpdatePhThresholds({required this.minPh, required this.maxPh});
}

class UpdateTemperatureThresholds extends SettingsEvent {
  final double minTemperature;
  final double maxTemperature;

  UpdateTemperatureThresholds({
    required this.minTemperature,
    required this.maxTemperature,
  });
}

class UpdateWaterLevelThresholds extends SettingsEvent {
  final double criticalPercentage;
  final double optimalPercentage;

  UpdateWaterLevelThresholds({
    required this.criticalPercentage,
    required this.optimalPercentage,
  });
}

// NUEVOS EVENTOS
class UpdateUserProfile extends SettingsEvent {
  final String name;
  final String phoneNumber;

  UpdateUserProfile({
    required this.name,
    required this.phoneNumber,
  });
}

class UpdateNotificationSettings extends SettingsEvent {
  final List<String> preferredNotifications;
  final bool criticalAlertsOnly;

  UpdateNotificationSettings({
    required this.preferredNotifications,
    required this.criticalAlertsOnly,
  });
}

class RestoreDefaultSettings extends SettingsEvent {}

// Evento para notificar cambios globales
class SettingsUpdated extends SettingsEvent {
  final String settingsType; // 'thresholds', 'profile', 'notifications'

  SettingsUpdated({required this.settingsType});
}