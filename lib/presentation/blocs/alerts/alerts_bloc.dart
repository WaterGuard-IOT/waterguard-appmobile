import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waterguard/domain/repositories/alert_repository.dart';
import 'alerts_event.dart';
import 'alerts_state.dart';

class AlertsBloc extends Bloc<AlertsEvent, AlertsState> {
  final AlertRepository alertRepository;

  AlertsBloc({required this.alertRepository}) : super(AlertsInitial()) {
    on<LoadAlerts>(_onLoadAlerts);
    on<MarkAlertAsResolved>(_onMarkAlertAsResolved);
  }

  Future<void> _onLoadAlerts(
      LoadAlerts event,
      Emitter<AlertsState> emit,
      ) async {
    emit(AlertsLoading());
    try {
      final alerts = await alertRepository.getAlerts(resolved: event.resolved);
      emit(AlertsLoaded(alerts: alerts));
    } catch (e) {
      emit(AlertsError('Error al cargar las alertas: ${e.toString()}'));
    }
  }

  Future<void> _onMarkAlertAsResolved(
      MarkAlertAsResolved event,
      Emitter<AlertsState> emit,
      ) async {
    try {
      await alertRepository.markAsResolved(event.alertId);

      // Recargar las alertas
      final alerts = await alertRepository.getAlerts(resolved: false);
      emit(AlertsLoaded(alerts: alerts));
    } catch (e) {
      emit(AlertsError('Error al marcar la alerta como resuelta: ${e.toString()}'));
    }
  }
}