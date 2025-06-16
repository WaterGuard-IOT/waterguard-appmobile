// Modelos adaptados para el backend según OpenAPI

import '../../domain/entities/tank.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/water_quality.dart';

// Modelo de Usuario del Backend
class BackendUserModel extends User {
  const BackendUserModel({
    required String id,
    required String name,
    required String email,
    String role = 'community_member',
    String phoneNumber = '',
    List<String> preferredNotifications = const [],
    List<String> managedTanks = const [],
  }) : super(
    id: id,
    name: name,
    role: role,
    email: email,
    phoneNumber: phoneNumber,
    preferredNotifications: preferredNotifications,
    managedTanks: managedTanks,
  );

  factory BackendUserModel.fromJson(Map<String, dynamic> json) {
    return BackendUserModel(
      id: json['id'].toString(),
      name: json['username'] ?? '',
      email: json['email'] ?? '',
      role: 'community_member',
      phoneNumber: '',
      preferredNotifications: ['push'],
      managedTanks: json['tanques'] != null
          ? (json['tanques'] as List).map((t) => t['id'].toString()).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': int.parse(id),
      'username': name,
      'email': email,
    };
  }
}

// Modelo de Tanque del Backend
class BackendTankModel extends Tank {
  const BackendTankModel({
    required String id,
    required String name,
    required Map<String, dynamic> location,
    required double capacity,
    required double currentLevel,
    required double criticalLevel,
    required double optimalLevel,
    required DateTime lastUpdated,
    required String status,
    required bool pumpActive,
  }) : super(
    id: id,
    name: name,
    location: location,
    capacity: capacity,
    currentLevel: currentLevel,
    criticalLevel: criticalLevel,
    optimalLevel: optimalLevel,
    lastUpdated: lastUpdated,
    status: status,
    pumpActive: pumpActive,
  );

  factory BackendTankModel.fromJson(Map<String, dynamic> json) {
    // Capacidad fija por ahora (se puede hacer configurable después)
    const capacity = 1000.0;

    // Calcular nivel actual basado en el porcentaje del backend
    double currentLevel = capacity * 0.5; // Por defecto 50%
    DateTime lastUpdated = DateTime.now();

    if (json['nivel'] != null) {
      final nivelData = json['nivel'] as Map<String, dynamic>;
      if (nivelData['porcentaje'] != null) {
        currentLevel = capacity * (nivelData['porcentaje'] / 100.0);
      }
      if (nivelData['fechaMedicion'] != null) {
        lastUpdated = DateTime.parse(nivelData['fechaMedicion']);
      }
    }

    return BackendTankModel(
      id: json['id'].toString(),
      name: 'Tanque ${json['id']}',
      location: {
        'latitude': -12.0464,
        'longitude': -77.0428,
        'address': 'Lima, Perú',
      },
      capacity: capacity,
      currentLevel: currentLevel,
      criticalLevel: capacity * 0.2, // 20%
      optimalLevel: capacity * 0.8, // 80%
      lastUpdated: lastUpdated,
      status: _calculateStatus(currentLevel, capacity),
      pumpActive: false, // No disponible en backend actual
    );
  }

  static String _calculateStatus(double currentLevel, double capacity) {
    final percentage = (currentLevel / capacity) * 100;
    if (percentage < 20) return 'critical';
    if (percentage < 50) return 'warning';
    return 'normal';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': int.parse(id),
      'capacity': capacity,
      'currentLevel': currentLevel,
      'status': status,
    };
  }
}

// Modelo de Calidad de Agua del Backend
class BackendWaterQualityModel extends WaterQuality {
  const BackendWaterQualityModel({
    required String tankId,
    required DateTime timestamp,
    required double ph,
    required double temperature,
    required String status,
    this.turbidez,
    this.conductividad,
  }) : super(
    tankId: tankId,
    timestamp: timestamp,
    ph: ph,
    temperature: temperature,
    status: status,
  );

  final double? turbidez;
  final double? conductividad;

  factory BackendWaterQualityModel.fromJson(
      Map<String, dynamic> json,
      String tankId
      ) {
    final ph = json['ph']?.toDouble() ?? 7.0;
    final temperature = json['temperatura']?.toDouble() ?? 20.0;
    final turbidez = json['turbidez']?.toDouble();
    final conductividad = json['conductividad']?.toDouble();

    return BackendWaterQualityModel(
      tankId: tankId,
      timestamp: json['fechaRegistro'] != null
          ? DateTime.parse(json['fechaRegistro'])
          : DateTime.now(),
      ph: ph,
      temperature: temperature,
      status: _calculateQualityStatus(ph, temperature),
      turbidez: turbidez,
      conductividad: conductividad,
    );
  }

  static String _calculateQualityStatus(double ph, double temperature) {
    final isPhNormal = ph >= 6.5 && ph <= 8.5;
    final isTempNormal = temperature >= 15.0 && temperature <= 25.0;

    if (isPhNormal && isTempNormal) return 'good';
    if ((ph >= 6.0 && ph <= 9.0) && (temperature >= 10.0 && temperature <= 30.0)) {
      return 'acceptable';
    }
    return 'poor';
  }

  Map<String, dynamic> toJson() {
    return {
      'ph': ph,
      'turbidez': turbidez,
      'conductividad': conductividad,
      'temperatura': temperature,
    };
  }
}