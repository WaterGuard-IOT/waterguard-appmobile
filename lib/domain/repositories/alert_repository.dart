import '../entities/alert.dart';

abstract class AlertRepository {
  Future<List<Alert>> getAlerts({bool? resolved});
  Future<Alert?> getAlertById(String id);
  Future<void> markAsResolved(String id);
}