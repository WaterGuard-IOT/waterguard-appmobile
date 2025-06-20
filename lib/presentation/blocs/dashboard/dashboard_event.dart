// lib/presentation/blocs/dashboard/dashboard_event.dart
import 'package:waterguard/domain/entities/tank.dart';

abstract class DashboardEvent {}

class LoadDashboard extends DashboardEvent {}

class RefreshDashboard extends DashboardEvent {}

class TogglePump extends DashboardEvent {
  final Tank tank;
  TogglePump({required this.tank});
}

// --- NUEVA FUNCIONALIDAD: Evento interno para la simulación ---
// Este evento será añadido por el propio BLoC para actualizar el nivel de forma segura.
class UpdateTankLevel extends DashboardEvent {
  final String tankId;
  final double amountToAdd;

  UpdateTankLevel({required this.tankId, required this.amountToAdd});
}
