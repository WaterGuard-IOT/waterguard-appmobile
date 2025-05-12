import '../entities/water_quality.dart';

abstract class WaterQualityRepository {
  Future<List<WaterQuality>> getWaterQualityReadings();
  Future<WaterQuality?> getWaterQualityForTank(String tankId);
  Future<List<Map<String, dynamic>>> getHistoricalData(String tankId);
}