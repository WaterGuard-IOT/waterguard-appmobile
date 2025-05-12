// lib/data/repositories/water_quality_repository_impl.dart
import 'package:waterguard/data/datasources/mock/mock_data_provider.dart';
import 'package:waterguard/domain/entities/water_quality.dart';
import 'package:waterguard/domain/repositories/water_quality_repository.dart';
import 'package:waterguard/data/models/water_quality_model.dart';

class WaterQualityRepositoryImpl implements WaterQualityRepository {
  final MockDataProvider mockDataProvider;

  WaterQualityRepositoryImpl({required this.mockDataProvider});

  @override
  Future<List<WaterQuality>> getWaterQualityReadings() async {
    final readingsData = await mockDataProvider.getWaterQualityReadings();
    return readingsData.map((data) => WaterQualityModel.fromJson(data)).toList();
  }

  @override
  Future<WaterQuality?> getWaterQualityForTank(String tankId) async {
    final qualityData = await mockDataProvider.getWaterQualityForTank(tankId);
    if (qualityData == null) return null;
    return WaterQualityModel.fromJson(qualityData);
  }

  @override
  Future<List<Map<String, dynamic>>> getHistoricalData(String tankId) async {
    return await mockDataProvider.getHistoricalData(tankId);
  }
}