// lib/presentation/blocs/tank/tank_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waterguard/data/services/tank_service.dart';
import 'package:waterguard/domain/repositories/tank_repository.dart';
import 'package:waterguard/domain/repositories/water_quality_repository.dart';
import 'tank_event.dart';
import 'tank_state.dart';

class TankBloc extends Bloc<TankEvent, TankState> {
  final TankRepository tankRepository;
  final TankService tankService;
  final WaterQualityRepository waterQualityRepository;

  TankBloc({
    required this.tankRepository,
    required this.tankService,
    required this.waterQualityRepository,
  }) : super(TankInitial()) {
    on<LoadTankDetail>(_onLoadTankDetail);
    on<TogglePump>(_onTogglePump);
    on<UpdateTank>(_onUpdateTank);
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
      final waterQuality =
      await waterQualityRepository.getWaterQualityForTank(event.tankId);
      final historicalData =
      await waterQualityRepository.getHistoricalData(event.tankId);
      emit(TankDetailLoaded(
        tank: tank,
        waterQuality: waterQuality,
        historicalData: historicalData,
      ));
    } catch (e) {
      emit(TankError('Error al cargar los detalles: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateTank(
      UpdateTank event,
      Emitter<TankState> emit,
      ) async {
    // Muestra un indicador de carga mientras se guarda
    emit(TankLoading());
    try {
      // Llama al servicio que realiza la petición PUT
      await tankService.updateTank(event.tankId, event.tankData);

      // Emite un estado de éxito para que la UI pueda reaccionar (e.g., mostrar un SnackBar)
      emit(TankUpdateSuccess());

      // Vuelve a cargar los datos del tanque para reflejar los cambios
      add(LoadTankDetail(tankId: event.tankId.toString()));
    } catch (e) {
      // Si algo falla, emite un estado de error
      emit(TankError('Error al actualizar el tanque: ${e.toString()}'));
    }
  }

  Future<void> _onTogglePump(
      TogglePump event,
      Emitter<TankState> emit,
      ) async {
    try {
      await tankRepository.togglePump(event.tankId, event.active);
      add(LoadTankDetail(tankId: event.tankId));
    } catch (e) {
      emit(TankError('Error al cambiar estado de la bomba: ${e.toString()}'));
    }
  }
}
