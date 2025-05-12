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

  double get levelPercentage => (currentLevel / capacity) * 100;
  bool get isCritical => currentLevel <= criticalLevel;
  bool get isOptimal => currentLevel >= optimalLevel;
  bool get needsRefill => currentLevel < optimalLevel;

  // Método para determinar el estado del tanque basado en niveles
  String calculateStatus() {
    if (isCritical) {
      return 'critical';
    } else if (needsRefill) {
      return 'warning';
    } else {
      return 'normal';
    }
  }
}