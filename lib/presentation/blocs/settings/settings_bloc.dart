import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waterguard/domain/repositories/user_settings_repository.dart';
import 'package:waterguard/data/models/user_settings_model.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final UserSettingsRepository userSettingsRepository;
  final String userId;

  SettingsBloc({
    required this.userSettingsRepository,
    required this.userId,
  }) : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdatePhThresholds>(_onUpdatePhThresholds);
    on<UpdateTemperatureThresholds>(_onUpdateTemperatureThresholds);
    on<UpdateWaterLevelThresholds>(_onUpdateWaterLevelThresholds);
  }

  Future<void> _onLoadSettings(
      LoadSettings event,
      Emitter<SettingsState> emit,
      ) async {
    emit(SettingsLoading());
    try {
      final settings = await userSettingsRepository.getUserSettings(userId);
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
        emit(SettingsLoaded(settings: updatedSettings));
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
        emit(SettingsLoaded(settings: updatedSettings));
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
        emit(SettingsLoaded(settings: updatedSettings));
      } catch (e) {
        emit(SettingsError('Error al actualizar los umbrales de nivel de agua: ${e.toString()}'));
      }
    }
  }
}