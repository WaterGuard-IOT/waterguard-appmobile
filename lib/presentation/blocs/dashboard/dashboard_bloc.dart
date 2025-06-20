// lib/presentation/blocs/dashboard/dashboard_bloc.dart
import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waterguard/data/services/tank_service.dart';
import 'package:waterguard/domain/entities/tank.dart';
import 'package:waterguard/domain/repositories/alert_repository.dart';
import 'package:waterguard/domain/repositories/tank_repository.dart';
import 'package:waterguard/domain/repositories/water_quality_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final TankRepository tankRepository;
  final AlertRepository alertRepository;
  final TankService tankService;
  // --- CORRECCIÓN: Repositorio restaurado ---
  final WaterQualityRepository waterQualityRepository;

  final Map<String, Timer> _pumpTimers = {};

  DashboardBloc({
    required this.tankRepository,
    required this.alertRepository,
    required this.tankService,
    // --- CORRECCIÓN: Parámetro restaurado en el constructor ---
    required this.waterQualityRepository,
  }) : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
    on<TogglePump>(_onTogglePump);
    on<UpdateTankLevel>(_onUpdateTankLevel);
  }

  Future<void> _onLoadDashboard(
      LoadDashboard event,
      Emitter<DashboardState> emit,
      ) async {
    if (state is! DashboardLoaded) {
      emit(DashboardLoading());
    }
    try {
      final tanks = await tankRepository.getTanks();
      final activeAlerts = await alertRepository.getAlerts(resolved: false);

      final activePumpTanks = tanks.where((t) => t.pumpActive).map((t) => t.id).toSet();
      _pumpTimers.keys.where((id) => !activePumpTanks.contains(id)).forEach((id) {
        _pumpTimers[id]?.cancel();
        _pumpTimers.remove(id);
      });

      emit(DashboardLoaded(
        tanks: tanks,
        activeAlerts: activeAlerts,
      ));
    } catch (e) {
      emit(DashboardError('Error al cargar el dashboard: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshDashboard(
      RefreshDashboard event,
      Emitter<DashboardState> emit,
      ) async {
    add(LoadDashboard());
  }

  Future<void> _onTogglePump(
      TogglePump event,
      Emitter<DashboardState> emit,
      ) async {
    final tankToUpdate = event.tank;
    final newPumpStatus = !tankToUpdate.pumpActive;

    _pumpTimers[tankToUpdate.id]?.cancel();
    _pumpTimers.remove(tankToUpdate.id);

    await tankService.updateTank(int.parse(tankToUpdate.id), {
      ...tankToUpdate.toJson(),
      "pumpActive": newPumpStatus,
    });

    add(LoadDashboard());

    if (newPumpStatus) {
      _pumpTimers[tankToUpdate.id] = Timer.periodic(const Duration(seconds: 1), (timer) {
        add(UpdateTankLevel(tankId: tankToUpdate.id, amountToAdd: 15));
      });
    }
  }

  Future<void> _onUpdateTankLevel(
      UpdateTankLevel event,
      Emitter<DashboardState> emit,
      ) async {
    if (state is! DashboardLoaded) return;

    final currentState = state as DashboardLoaded;
    final tankIndex = currentState.tanks.indexWhere((t) => t.id == event.tankId);
    if (tankIndex == -1) {
      _pumpTimers[event.tankId]?.cancel();
      _pumpTimers.remove(event.tankId);
      return;
    }

    final currentTank = currentState.tanks[tankIndex];

    if (!currentTank.pumpActive) {
      _pumpTimers[event.tankId]?.cancel();
      _pumpTimers.remove(event.tankId);
      return;
    }

    final newLevel = min(currentTank.currentLevel + event.amountToAdd, currentTank.capacity);
    final updatedTank = currentTank.copyWith(currentLevel: newLevel, lastUpdated: DateTime.now());

    final newList = List<Tank>.from(currentState.tanks);
    newList[tankIndex] = updatedTank;

    emit(DashboardLoaded(tanks: newList, activeAlerts: currentState.activeAlerts));

    if (DateTime.now().second % 5 == 0) {
      try {
        await tankService.updateTank(int.parse(updatedTank.id), updatedTank.toJson());
      } catch(e) {
        print("Error al persistir el nivel del tanque: $e");
      }
    }
  }

  @override
  Future<void> close() {
    _pumpTimers.values.forEach((timer) => timer.cancel());
    return super.close();
  }
}
