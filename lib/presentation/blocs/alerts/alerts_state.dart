import 'package:waterguard/domain/entities/alert.dart';

abstract class AlertsState {}

class AlertsInitial extends AlertsState {}

class AlertsLoading extends AlertsState {}

class AlertsLoaded extends AlertsState {
  final List<Alert> alerts;

  AlertsLoaded({required this.alerts});
}

class AlertsError extends AlertsState {
  final String message;

  AlertsError(this.message);
}