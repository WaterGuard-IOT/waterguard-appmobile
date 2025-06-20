// lib/presentation/blocs/dashboard/dashboard_bloc.dart - CORREGIDO
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
  final WaterQualityRepository waterQualityRepository;

  final Map<String, Timer> _pumpTimers = {};
  final Map<String, Tank> _tankCache = {}; // Cache local para evitar llamadas al backend

  DashboardBloc({
    required this.tankRepository,
    required this.alertRepository,
    required this.tankService,
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

      // Actualizar cache local
      for (final tank in tanks) {
        _tankCache[tank.id] = tank;
      }

      // Mantener timers existentes para bombas activas
      final activePumpTanks = tanks.where((t) => t.pumpActive).map((t) => t.id).toSet();

      // Cancelar timers de bombas que ya no están activas
      _pumpTimers.keys.where((id) => !activePumpTanks.contains(id)).forEach((id) {
        _pumpTimers[id]?.cancel();
        _pumpTimers.remove(id);
      });

      // Iniciar timers para bombas activas que no los tienen
      for (final tankId in activePumpTanks) {
        if (!_pumpTimers.containsKey(tankId)) {
          _startPumpTimer(tankId);
        }
      }

      emit(DashboardLoaded(
        tanks: tanks,
        activeAlerts: activeAlerts,
      ));
    } catch (e) {
      print('❌ Error al cargar dashboard: $e');
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

    print('🔄 Cambiando estado de bomba del tanque ${tankToUpdate.id}: $newPumpStatus');

    // Cancelar timer existente
    _pumpTimers[tankToUpdate.id]?.cancel();
    _pumpTimers.remove(tankToUpdate.id);

    // Actualizar tanque en cache local primero
    final updatedTank = tankToUpdate.copyWith(
      pumpActive: newPumpStatus,
      lastUpdated: DateTime.now(),
    );
    _tankCache[tankToUpdate.id] = updatedTank;

    // Actualizar estado inmediatamente
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      final updatedTanks = currentState.tanks.map((tank) {
        return tank.id == tankToUpdate.id ? updatedTank : tank;
      }).toList();

      emit(DashboardLoaded(
        tanks: updatedTanks,
        activeAlerts: currentState.activeAlerts,
      ));
    }

    // Intentar actualizar en backend (sin bloquear la UI)
    _updateTankInBackground(updatedTank);

    // Iniciar timer si la bomba está activa
    if (newPumpStatus) {
      _startPumpTimer(tankToUpdate.id);
    }
  }

  void _startPumpTimer(String tankId) {
    _pumpTimers[tankId] = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Verificar que el tanque aún existe y la bomba está activa
      final tank = _tankCache[tankId];
      if (tank == null || !tank.pumpActive) {
        timer.cancel();
        _pumpTimers.remove(tankId);
        return;
      }

      // Solo añadir eventos si el tanque no está lleno
      if (tank.currentLevel < tank.capacity) {
        add(UpdateTankLevel(tankId: tankId, amountToAdd: 15)); // 15 litros por segundo
      } else {
        // Auto-detener bomba cuando está lleno
        print('🛑 Tanque ${tankId} lleno, deteniendo bomba automáticamente');
        final fullTank = tank.copyWith(pumpActive: false);
        _tankCache[tankId] = fullTank;
        timer.cancel();
        _pumpTimers.remove(tankId);
        add(LoadDashboard()); // Refrescar para mostrar estado actualizado
      }
    });
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
    final updatedTank = currentTank.copyWith(
      currentLevel: newLevel,
      lastUpdated: DateTime.now(),
    );

    // Actualizar cache
    _tankCache[event.tankId] = updatedTank;

    final newList = List<Tank>.from(currentState.tanks);
    newList[tankIndex] = updatedTank;

    emit(DashboardLoaded(tanks: newList, activeAlerts: currentState.activeAlerts));

    // Actualizar en backend cada 5 segundos para evitar spam
    if (DateTime.now().second % 5 == 0) {
      _updateTankInBackground(updatedTank);
    }
  }

  // Método para actualizar en backend sin afectar la UI
  void _updateTankInBackground(Tank tank) async {
    try {
      final tankData = {
        "name": tank.name,
        "capacity": tank.capacity,
        "currentLevel": tank.currentLevel,
        "criticalLevel": tank.criticalLevel,
        "optimalLevel": tank.optimalLevel,
        "pumpActive": tank.pumpActive,
        "status": tank.status,
        "location": tank.location,
        "userId": 1, // Valor por defecto, debería obtenerse del usuario actual
      };

      await tankService.updateTank(int.parse(tank.id), tankData);
      print('✅ Tanque ${tank.id} actualizado en backend');
    } catch (e) {
      // Error silencioso - no afecta la funcionalidad local
      print('⚠️ Error al actualizar tanque ${tank.id} en backend: $e');
      print('💡 Continuando con funcionalidad local...');

      // Opcionalmente, podrías agregar una alerta local aquí
      // pero sin bloquear la funcionalidad
    }
  }

  @override
  Future<void> close() {
    _pumpTimers.values.forEach((timer) => timer.cancel());
    _pumpTimers.clear();
    _tankCache.clear();
    return super.close();
  }
}