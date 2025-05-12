abstract class AlertsEvent {}

class LoadAlerts extends AlertsEvent {
  final bool? resolved;

  LoadAlerts({this.resolved});
}

class MarkAlertAsResolved extends AlertsEvent {
  final String alertId;

  MarkAlertAsResolved({required this.alertId});
}