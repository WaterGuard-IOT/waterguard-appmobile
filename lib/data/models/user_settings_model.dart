import '../../domain/entities/user_settings.dart';

class UserSettingsModel extends UserSettings {
  const UserSettingsModel({
    required String userId,
    double defaultMinPh = 6.5,
    double defaultMaxPh = 8.5,
    double defaultMinTemperature = 15.0,
    double defaultMaxTemperature = 25.0,
    double defaultCriticalLevelPercentage = 20.0,
    double defaultOptimalLevelPercentage = 80.0,
  }) : super(
    userId: userId,
    defaultMinPh: defaultMinPh,
    defaultMaxPh: defaultMaxPh,
    defaultMinTemperature: defaultMinTemperature,
    defaultMaxTemperature: defaultMaxTemperature,
    defaultCriticalLevelPercentage: defaultCriticalLevelPercentage,
    defaultOptimalLevelPercentage: defaultOptimalLevelPercentage,
  );

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) {
    return UserSettingsModel(
      userId: json['userId'],
      defaultMinPh: json['defaultMinPh'] ?? 6.5,
      defaultMaxPh: json['defaultMaxPh'] ?? 8.5,
      defaultMinTemperature: json['defaultMinTemperature'] ?? 15.0,
      defaultMaxTemperature: json['defaultMaxTemperature'] ?? 25.0,
      defaultCriticalLevelPercentage: json['defaultCriticalLevelPercentage'] ?? 20.0,
      defaultOptimalLevelPercentage: json['defaultOptimalLevelPercentage'] ?? 80.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'defaultMinPh': defaultMinPh,
      'defaultMaxPh': defaultMaxPh,
      'defaultMinTemperature': defaultMinTemperature,
      'defaultMaxTemperature': defaultMaxTemperature,
      'defaultCriticalLevelPercentage': defaultCriticalLevelPercentage,
      'defaultOptimalLevelPercentage': defaultOptimalLevelPercentage,
    };
  }
}