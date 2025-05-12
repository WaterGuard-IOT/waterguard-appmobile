
import 'package:waterguard/domain/entities/tank.dart';

abstract class TankRepository{
  Future<List<Tank>> getTanks();
  Future<Tank?> getTankById(String id);
  Future<void> togglePump(String id, bool active);
}