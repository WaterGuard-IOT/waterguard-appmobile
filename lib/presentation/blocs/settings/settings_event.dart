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