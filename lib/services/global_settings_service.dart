// lib/services/global_settings_service.dart
import 'dart:async';
import 'package:waterguard/domain/entities/user_settings.dart';

class GlobalSettingsService {
  static final GlobalSettingsService _instance = GlobalSettingsService._internal();
  factory GlobalSettingsService() => _instance;
  GlobalSettingsService._internal();

  final _settingsController = StreamController<UserSettings>.broadcast();
  UserSettings? _currentSettings;

  Stream<UserSettings> get settingsStream => _settingsController.stream;
  UserSettings? get currentSettings => _currentSettings;

  void updateSettings(UserSettings settings) {
    _currentSettings = settings;
    _settingsController.add(settings);
  }

  void dispose() {
    _settingsController.close();
  }
}