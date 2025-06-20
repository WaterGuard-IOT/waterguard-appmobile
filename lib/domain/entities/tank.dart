// lib/domain/entities/tank.dart

class Tank {
  final String id;
  final String name;
  final Map<String, dynamic> location;
  final double capacity;
  final double currentLevel;
  final double criticalLevel;
  final double optimalLevel;
  final DateTime lastUpdated;
  final String status;
  final bool pumpActive;

  const Tank({
    required this.id,
    required this.name,
    required this.location,
    required this.capacity,
    required this.currentLevel,
    required this.criticalLevel,
    required this.optimalLevel,
    required this.lastUpdated,
    required this.status,
    required this.pumpActive,
  });

  double get levelPercentage => capacity > 0 ? (currentLevel / capacity) * 100 : 0;
  bool get isCritical => levelPercentage <= criticalLevel;
  bool get isOptimal => levelPercentage >= optimalLevel;
  bool get needsRefill => levelPercentage < optimalLevel;

  String calculateStatus() {
    if (isCritical) return 'critical';
    if (needsRefill) return 'warning';
    return 'normal';
  }

  // --- NUEVA FUNCIONALIDAD: Método para crear copias del objeto ---
  Tank copyWith({
    double? currentLevel,
    bool? pumpActive,
    DateTime? lastUpdated,
  }) {
    return Tank(
      id: id,
      name: name,
      location: location,
      capacity: capacity,
      currentLevel: currentLevel ?? this.currentLevel,
      criticalLevel: criticalLevel,
      optimalLevel: optimalLevel,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      status: status,
      pumpActive: pumpActive ?? this.pumpActive,
    );
  }

  // --- NUEVA FUNCIONALIDAD: Método para convertir a JSON para el backend ---
  Map<String, dynamic> toJson() {
    return {
      'id': int.tryParse(id) ?? 0,
      'name': name,
      'capacity': capacity,
      'currentLevel': currentLevel,
      'criticalLevel': criticalLevel,
      'optimalLevel': optimalLevel,
      'lastUpdated': lastUpdated.toIso8601String(),
      'status': status,
      'pumpActive': pumpActive,
      'location': location,
      'userId': int.tryParse(id) ?? 0, // Asumiendo que el userId se puede obtener del tankId
    };
  }
}
