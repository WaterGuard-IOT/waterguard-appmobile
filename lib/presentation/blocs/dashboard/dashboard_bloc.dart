import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waterguard/domain/repositories/tank_repository.dart';
import 'package:waterguard/domain/repositories/water_quality_repository.dart';
import 'package:waterguard/domain/repositories/alert_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final TankRepository tankRepository;
  final WaterQualityRepository waterQualityRepository;
  final AlertRepository alertRepository;

  DashboardBloc({
    required this.tankRepository,
    required this.waterQualityRepository,
    required this.alertRepository,
  }) : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
  }

  Future<void> _onLoadDashboard(
      LoadDashboard event,
      Emitter<DashboardState> emit,
      ) async {
    emit(DashboardLoading());
    try {
      final tanks = await tankRepository.getTanks();
      final activeAlerts = await alertRepository.getAlerts(resolved: false);

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
    // Podríamos implementar alguna lógica extra aquí si fuera necesario
    add(LoadDashboard());
  }
}