class UserSettings {
  final String userId;
  final double defaultMinPh;
  final double defaultMaxPh;
  final double defaultMinTemperature;
  final double defaultMaxTemperature;
  final double defaultCriticalLevelPercentage;
  final double defaultOptimalLevelPercentage;

  const UserSettings({
    required this.userId,
    this.defaultMinPh = 6.5,
    this.defaultMaxPh = 8.5,
    this.defaultMinTemperature = 15.0,
    this.defaultMaxTemperature = 25.0,
    this.defaultCriticalLevelPercentage = 20.0,
    this.defaultOptimalLevelPercentage = 80.0,
  });

  double calculateDefaultCriticalLevel(double tankCapacity) {
    return tankCapacity * (defaultCriticalLevelPercentage / 100);
  }

  double calculateDefaultOptimalLevel(double tankCapacity) {
    return tankCapacity * (defaultOptimalLevelPercentage / 100);
  }
}