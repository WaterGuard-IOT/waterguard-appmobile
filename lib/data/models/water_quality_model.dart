import '../../domain/entities/water_quality.dart';

class WaterQualityModel extends WaterQuality {
  const WaterQualityModel({
    required String tankId,
    required DateTime timestamp,
    required double ph,
    required double temperature,
    required String status,
  }) : super(
    tankId: tankId,
    timestamp: timestamp,
    ph: ph,
    temperature: temperature,
    status: status,
  );

  factory WaterQualityModel.fromJson(Map<String, dynamic> json) {
    return WaterQualityModel(
      tankId: json['tankId'],
      timestamp: DateTime.parse(json['timestamp']),
      ph: json['ph'].toDouble(),
      temperature: json['temperature'].toDouble(),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tankId': tankId,
      'timestamp': timestamp.toIso8601String(),
      'ph': ph,
      'temperature': temperature,
      'status': status,
    };
  }
}