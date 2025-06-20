// lib/data/models/backend_models.dart

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
    // --- CORRECCIÓN AQUÍ ---
    // Se leen los valores directamente del JSON en lugar de usar valores fijos.

    // 1. Lee la capacidad del JSON. Si es nula, usa 0.0 como valor por defecto.
    final double capacity = (json['capacity'] as num?)?.toDouble() ?? 0.0;

    // 2. Lee el nivel actual. Si es nulo, usa 0.0.
    final double currentLevel = (json['currentLevel'] as num?)?.toDouble() ?? 0.0;

    // 3. Intenta parsear la fecha. Si es nula o inválida, usa la fecha actual.
    DateTime lastUpdated;
    try {
      lastUpdated = json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now();
    } catch (e) {
      lastUpdated = DateTime.now();
    }

    return BackendTankModel(
      id: json['id'].toString(),
      // 4. Lee el nombre del JSON. Si es nulo, crea uno genérico.
      name: json['name'] ?? 'Tanque ${json['id']}',
      // 5. Lee la ubicación. Si es nula, provee un mapa vacío.
      location: json['location'] != null ? Map<String, dynamic>.from(json['location']) : {},
      // 6. Asigna los valores leídos del JSON.
      capacity: capacity,
      currentLevel: currentLevel,
      criticalLevel: (json['criticalLevel'] as num?)?.toDouble() ?? 0.0,
      optimalLevel: (json['optimalLevel'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: lastUpdated,
      status: json['status'] ?? 'unknown',
      pumpActive: json['pumpActive'] ?? false,
    );
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

