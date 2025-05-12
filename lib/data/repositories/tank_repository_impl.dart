import 'package:waterguard/data/datasources/mock/mock_data_provider.dart';
import 'package:waterguard/domain/entities/tank.dart';
import 'package:waterguard/domain/repositories/tank_repository.dart';
import 'package:waterguard/data/models/tank_model.dart';

class TankRepositoryImpl implements TankRepository {
  final MockDataProvider mockDataProvider;

  TankRepositoryImpl({required this.mockDataProvider});

  @override
  Future<List<Tank>> getTanks() async {
    final tanksData = await mockDataProvider.getTanks();
    return tanksData.map((data) => TankModel.fromJson(data)).toList();
  }

  @override
  Future<Tank?> getTankById(String id) async {
    final tankData = await mockDataProvider.getTankById(id);
    if (tankData == null) return null;
    return TankModel.fromJson(tankData);
  }

  @override
  Future<void> togglePump(String id, bool active) async {
    await mockDataProvider.togglePump(id, active);
  }
}