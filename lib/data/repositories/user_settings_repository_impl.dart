// lib/data/repositories/user_settings_repository_impl.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/user_settings_repository.dart';
import '../models/user_settings_model.dart';

class UserSettingsRepositoryImpl implements UserSettingsRepository {
  @override
  Future<UserSettings> getUserSettings(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('user_settings_$userId');

    if (settingsJson != null) {
      final Map<String, dynamic> settingsMap = json.decode(settingsJson);
      settingsMap['userId'] = userId; // Aseguramos que el ID esté presente
      return UserSettingsModel.fromJson(settingsMap);
    }

    // Si no hay configuración guardada, devolver valores por defecto
    return UserSettingsModel(userId: userId);
  }

  @override
  Future<void> saveUserSettings(UserSettings settings) async {
    final prefs = await SharedPreferences.getInstance();

    // Convertimos la entidad a un modelo si no lo es ya
    final settingsModel = settings is UserSettingsModel
        ? settings
        : UserSettingsModel(
      userId: settings.userId,
      defaultMinPh: settings.defaultMinPh,
      defaultMaxPh: settings.defaultMaxPh,
      defaultMinTemperature: settings.defaultMinTemperature,
      defaultMaxTemperature: settings.defaultMaxTemperature,
      defaultCriticalLevelPercentage: settings.defaultCriticalLevelPercentage,
      defaultOptimalLevelPercentage: settings.defaultOptimalLevelPercentage,
    );

    // Guardamos la configuración
    await prefs.setString('user_settings_${settings.userId}', json.encode(settingsModel.toJson()));
  }

  @override
  Future<void> updateUserSettings(UserSettings settings) async {
    // En este caso, la implementación es la misma que saveUserSettings
    await saveUserSettings(settings);
  }

  @override
  Future<UserSettings> getDefaultSettings() async {
    // Devuelve una configuración con valores por defecto
    return UserSettingsModel(userId: 'default');
  }
}