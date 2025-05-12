import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waterguard/domain/repositories/tank_repository.dart';
import 'package:waterguard/domain/repositories/water_quality_repository.dart';
import 'tank_event.dart';
import 'tank_state.dart';

class TankBloc extends Bloc<TankEvent, TankState> {
  final TankRepository tankRepository;
  final WaterQualityRepository waterQualityRepository;

  TankBloc({
    required this.tankRepository,
    required this.waterQualityRepository,
  }) : super(TankInitial()) {
    on<LoadTankDetail>(_onLoadTankDetail);
    on<TogglePump>(_onTogglePump);
  }

  Future<void> _onLoadTankDetail(
      LoadTankDetail event,
      Emitter<TankState> emit,
      ) async {
    emit(TankLoading());
    try {
      final tank = await tankRepository.getTankById(event.tankId);

      if (tank == null) {
        emit(TankError('No se encontró el tanque solicitado.'));
        return;
      }

      // Obtener los datos de calidad del agua
      final waterQuality = await waterQualityRepository.getWaterQualityForTank(event.tankId);

      // Obtener los datos históricos
      final historicalData = await waterQualityRepository.getHistoricalData(event.tankId);

      emit(TankDetailLoaded(
        tank: tank,
        waterQuality: waterQuality,
        historicalData: historicalData,
      ));
    } catch (e) {
      emit(TankError('Error al cargar los detalles del tanque: ${e.toString()}'));
    }
  }

  Future<void> _onTogglePump(
      TogglePump event,
      Emitter<TankState> emit,
      ) async {
    try {
      await tankRepository.togglePump(event.tankId, event.active);

      // Recargar los detalles del tanque
      add(LoadTankDetail(tankId: event.tankId));
    } catch (e) {
      emit(TankError('Error al cambiar el estado de la bomba: ${e.toString()}'));
    }
  }
}