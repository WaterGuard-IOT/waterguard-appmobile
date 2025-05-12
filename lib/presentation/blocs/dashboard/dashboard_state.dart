import 'package:waterguard/domain/entities/tank.dart';
import 'package:waterguard/domain/entities/alert.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<Tank> tanks;
  final List<Alert> activeAlerts;

  DashboardLoaded({
    required this.tanks,
    required this.activeAlerts,
  });
}

class DashboardError extends DashboardState {
  final String message;

  DashboardError(this.message);
}