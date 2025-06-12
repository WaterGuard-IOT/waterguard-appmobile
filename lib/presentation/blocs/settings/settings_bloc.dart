// lib/presentation/blocs/settings/settings_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waterguard/domain/repositories/user_settings_repository.dart';
import 'package:waterguard/data/models/user_settings_model.dart';
import 'package:waterguard/services/global_settings_service.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final UserSettingsRepository userSettingsRepository;
  final String userId;
  final GlobalSettingsService _globalSettingsService = GlobalSettingsService();

  SettingsBloc({
    required this.userSettingsRepository,
    required this.userId,
  }) : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdatePhThresholds>(_onUpdatePhThresholds);
    on<UpdateTemperatureThresholds>(_onUpdateTemperatureThresholds);
    on<UpdateWaterLevelThresholds>(_onUpdateWaterLevelThresholds);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<UpdateNotificationSettings>(_onUpdateNotificationSettings);
    on<RestoreDefaultSettings>(_onRestoreDefaultSettings);
  }

  Future<void> _onLoadSettings(
      LoadSettings event,
      Emitter<SettingsState> emit,
      ) async {
    emit(SettingsLoading());
    try {
      final settings = await userSettingsRepository.getUserSettings(userId);

      // Notificar cambio global
      _globalSettingsService.updateSettings(settings);

      emit(SettingsLoaded(settings: settings));
    } catch (e) {
      emit(SettingsError('Error al cargar las configuraciones: ${e.toString()}'));
    }
  }

  Future<void> _onUpdatePhThresholds(
      UpdatePhThresholds event,
      Emitter<SettingsState> emit,
      ) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;

      final updatedSettings = UserSettingsModel(
        userId: currentSettings.userId,
        defaultMinPh: event.minPh,
        defaultMaxPh: event.maxPh,
        defaultMinTemperature: currentSettings.defaultMinTemperature,
        defaultMaxTemperature: currentSettings.defaultMaxTemperature,
        defaultCriticalLevelPercentage: currentSettings.defaultCriticalLevelPercentage,
        defaultOptimalLevelPercentage: currentSettings.defaultOptimalLevelPercentage,
      );

      try {
        await userSettingsRepository.updateUserSettings(updatedSettings);

        // Notificar cambio global
        _globalSettingsService.updateSettings(updatedSettings);

        emit(SettingsLoaded(settings: updatedSettings));

        // Emitir evento de éxito
        emit(SettingsUpdatedSuccessfully(
          message: 'Umbrales de pH actualizados correctamente',
          settings: updatedSettings,
        ));
      } catch (e) {
        emit(SettingsError('Error al actualizar los umbrales de pH: ${e.toString()}'));
      }
    }
  }

  Future<void> _onUpdateTemperatureThresholds(
      UpdateTemperatureThresholds event,
      Emitter<SettingsState> emit,
      ) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;

      final updatedSettings = UserSettingsModel(
        userId: currentSettings.userId,
        defaultMinPh: currentSettings.defaultMinPh,
        defaultMaxPh: currentSettings.defaultMaxPh,
        defaultMinTemperature: event.minTemperature,
        defaultMaxTemperature: event.maxTemperature,
        defaultCriticalLevelPercentage: currentSettings.defaultCriticalLevelPercentage,
        defaultOptimalLevelPercentage: currentSettings.defaultOptimalLevelPercentage,
      );

      try {
        await userSettingsRepository.updateUserSettings(updatedSettings);

        // Notificar cambio global
        _globalSettingsService.updateSettings(updatedSettings);

        emit(SettingsLoaded(settings: updatedSettings));

        emit(SettingsUpdatedSuccessfully(
          message: 'Umbrales de temperatura actualizados correctamente',
          settings: updatedSettings,
        ));
      } catch (e) {
        emit(SettingsError('Error al actualizar los umbrales de temperatura: ${e.toString()}'));
      }
    }
  }

  Future<void> _onUpdateWaterLevelThresholds(
      UpdateWaterLevelThresholds event,
      Emitter<SettingsState> emit,
      ) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;

      final updatedSettings = UserSettingsModel(
        userId: currentSettings.userId,
        defaultMinPh: currentSettings.defaultMinPh,
        defaultMaxPh: currentSettings.defaultMaxPh,
        defaultMinTemperature: currentSettings.defaultMinTemperature,
        defaultMaxTemperature: currentSettings.defaultMaxTemperature,
        defaultCriticalLevelPercentage: event.criticalPercentage,
        defaultOptimalLevelPercentage: event.optimalPercentage,
      );

      try {
        await userSettingsRepository.updateUserSettings(updatedSettings);

        // Notificar cambio global
        _globalSettingsService.updateSettings(updatedSettings);

        emit(SettingsLoaded(settings: updatedSettings));

        emit(SettingsUpdatedSuccessfully(
          message: 'Umbrales de nivel de agua actualizados correctamente',
          settings: updatedSettings,
        ));
      } catch (e) {
        emit(SettingsError('Error al actualizar los umbrales de nivel de agua: ${e.toString()}'));
      }
    }
  }

  Future<void> _onUpdateUserProfile(
      UpdateUserProfile event,
      Emitter<SettingsState> emit,
      ) async {
    try {
      // Aquí podrías actualizar el perfil del usuario
      // Para este ejemplo, solo emitimos éxito
      emit(SettingsUpdatedSuccessfully(
        message: 'Perfil actualizado correctamente',
        settings: (state as SettingsLoaded).settings,
      ));
    } catch (e) {
      emit(SettingsError('Error al actualizar el perfil: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateNotificationSettings(
      UpdateNotificationSettings event,
      Emitter<SettingsState> emit,
      ) async {
    try {
      // Aquí podrías actualizar las configuraciones de notificación
      emit(SettingsUpdatedSuccessfully(
        message: 'Configuración de notificaciones guardada',
        settings: (state as SettingsLoaded).settings,
      ));
    } catch (e) {
      emit(SettingsError('Error al actualizar las notificaciones: ${e.toString()}'));
    }
  }

  Future<void> _onRestoreDefaultSettings(
      RestoreDefaultSettings event,
      Emitter<SettingsState> emit,
      ) async {
    try {
      final defaultSettings = UserSettingsModel(userId: userId);

      await userSettingsRepository.updateUserSettings(defaultSettings);

      // Notificar cambio global
      _globalSettingsService.updateSettings(defaultSettings);

      emit(SettingsLoaded(settings: defaultSettings));

      emit(SettingsUpdatedSuccessfully(
        message: 'Configuraciones restauradas por defecto',
        settings: defaultSettings,
      ));
    } catch (e) {
      emit(SettingsError('Error al restaurar configuraciones: ${e.toString()}'));
    }
  }
}