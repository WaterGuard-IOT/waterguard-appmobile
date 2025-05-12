class Alert {
  final String id;
  final String tankId;
  final String type;
  final String severity;
  final String message;
  final DateTime timestamp;
  final bool resolved;
  final bool pumpActivated;

  const Alert({
    required this.id,
    required this.tankId,
    required this.type,
    required this.severity,
    required this.message,
    required this.timestamp,
    required this.resolved,
    required this.pumpActivated,
  });

  bool get isCritical => severity == 'error';

  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    return difference.inHours < 24;
  }
}