// lib/data/repositories/alert_repository_impl.dart
import 'package:waterguard/data/datasources/mock/mock_data_provider.dart';
import 'package:waterguard/domain/entities/alert.dart';
import 'package:waterguard/domain/repositories/alert_repository.dart';
import 'package:waterguard/data/models/alert_model.dart';

class AlertRepositoryImpl implements AlertRepository {
  final MockDataProvider mockDataProvider;

  AlertRepositoryImpl({required this.mockDataProvider});

  @override
  Future<List<Alert>> getAlerts({bool? resolved}) async {
    final alertsData = await mockDataProvider.getAlerts(resolved: resolved);
    return alertsData.map((data) => AlertModel.fromJson(data)).toList();
  }

  @override
  Future<Alert?> getAlertById(String id) async {
    final alerts = await mockDataProvider.getAlerts();
    final alertData = alerts.firstWhere(
          (alert) => alert['id'] == id,
      orElse: () => null,
    );
    if (alertData == null) return null;
    return AlertModel.fromJson(alertData);
  }

  @override
  Future<void> markAsResolved(String id) async {
    await mockDataProvider.markAlertAsResolved(id);
  }
}