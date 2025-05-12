import '../../domain/entities/tank.dart';

class TankModel extends Tank {
  const TankModel({
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

  factory TankModel.fromJson(Map<String, dynamic> json) {
    return TankModel(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      capacity: json['capacity'].toDouble(),
      currentLevel: json['currentLevel'].toDouble(),
      criticalLevel: json['criticalLevel'].toDouble(),
      optimalLevel: json['optimalLevel'].toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      status: json['status'],
      pumpActive: json['pumpActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'capacity': capacity,
      'currentLevel': currentLevel,
      'criticalLevel': criticalLevel,
      'optimalLevel': optimalLevel,
      'lastUpdated': lastUpdated.toIso8601String(),
      'status': status,
      'pumpActive': pumpActive,
    };
  }
}