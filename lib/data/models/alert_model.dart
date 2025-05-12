import '../../domain/entities/alert.dart';

class AlertModel extends Alert {
  const AlertModel({
    required String id,
    required String tankId,
    required String type,
    required String severity,
    required String message,
    required DateTime timestamp,
    required bool resolved,
    required bool pumpActivated,
  }) : super(
    id: id,
    tankId: tankId,
    type: type,
    severity: severity,
    message: message,
    timestamp: timestamp,
    resolved: resolved,
    pumpActivated: pumpActivated,
  );

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'],
      tankId: json['tankId'],
      type: json['type'],
      severity: json['severity'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      resolved: json['resolved'],
      pumpActivated: json['pumpActivated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tankId': tankId,
      'type': type,
      'severity': severity,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'resolved': resolved,
      'pumpActivated': pumpActivated,
    };
  }
}