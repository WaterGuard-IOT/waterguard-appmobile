class WaterQuality {
  final String tankId;
  final DateTime timestamp;
  final double ph;
  final double temperature;
  final String status;

  final double minNormalPh;
  final double maxNormalPh;
  final double minNormalTemperature;
  final double maxNormalTemperature;

  const WaterQuality({
    required this.tankId,
    required this.timestamp,
    required this.ph,
    required this.temperature,
    required this.status,
    this.minNormalPh = 6.5,
    this.maxNormalPh = 8.5,
    this.minNormalTemperature = 15.0,
    this.maxNormalTemperature = 25.0,
  });

  bool get isPhNormal => ph >= minNormalPh && ph <= maxNormalPh;
  bool get isTemperatureNormal => temperature >= minNormalTemperature && temperature <= maxNormalTemperature;

  String calculateQualityStatus() {
    if (isPhNormal && isTemperatureNormal) {
      return 'good';
    } else if ((ph >= minNormalPh - 0.5 && ph <= maxNormalPh + 0.5) &&
        (temperature >= minNormalTemperature - 5 && temperature <= maxNormalTemperature + 5)) {
      return 'acceptable';
    } else {
      return 'poor';
    }
  }
}