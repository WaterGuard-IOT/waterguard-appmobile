// lib/presentation/blocs/tank/tank_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waterguard/data/services/tank_service.dart';
import 'package:waterguard/domain/repositories/tank_repository.dart';
import '../../../domain/repositories/water_quality_repository.dart';
import 'tank_event.dart';
import 'tank_state.dart';
import 'package:waterguard/domain/entities/tank.dart';

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
    on<DeleteTank>(_onDeleteTank); // Registrar el nuevo manejador
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
    if (state is! TankDetailLoaded) return;
    emit(TankLoading());
    try {
      await tankService.updateTank(event.tankId, event.tankData);
      emit(TankUpdateSuccess());
      add(LoadTankDetail(tankId: event.tankId.toString()));
    } catch (e) {
      emit(TankError('Error al actualizar el tanque: ${e.toString()}'));
    }
  }

  // --- NUEVA FUNCIONALIDAD: Lógica para eliminar el tanque ---
  Future<void> _onDeleteTank(
      DeleteTank event,
      Emitter<TankState> emit,
      ) async {
    emit(TankLoading());
    try {
      await tankService.deleteTank(event.tankId);
      emit(TankDeleteSuccess());
    } catch (e) {
      emit(TankError('Error al eliminar el tanque: ${e.toString()}'));
    }
  }

  // --- LÓGICA MEJORADA: Activar/desactivar la bomba ---
  Future<void> _onTogglePump(
      TogglePump event,
      Emitter<TankState> emit,
      ) async {
    // Solo proceder si tenemos los datos del tanque cargados
    if (state is! TankDetailLoaded) return;

    final currentState = state as TankDetailLoaded;
    final currentTank = currentState.tank;

    // Crear el payload con el estado de la bomba actualizado
    final updatedData = {
      "name": currentTank.name,
      "capacity": currentTank.capacity,
      "criticalLevel": currentTank.criticalLevel,
      "optimalLevel": currentTank.optimalLevel,
      "pumpActive": event.active, // Usar el nuevo estado de la bomba
      "status": currentTank.status,
      "location": currentTank.location,
      "userId": int.parse(currentTank.id), // Asumiendo que el ID del usuario se puede obtener así
    };

    // Reutilizar el evento de actualización para mantener la consistencia
    add(UpdateTank(tankId: int.parse(currentTank.id), tankData: updatedData));
  }
}
