// lib/presentation/blocs/tank/tank_state.dart
import 'package:waterguard/domain/entities/tank.dart';
import 'package:waterguard/domain/entities/water_quality.dart';

abstract class TankState {}

class TankInitial extends TankState {}

class TankLoading extends TankState {}

// NUEVO ESTADO: Para notificar éxito en la actualización
class TankUpdateSuccess extends TankState {}

class TankDetailLoaded extends TankState {
  final Tank tank;
  final WaterQuality? waterQuality;
  final List<Map<String, dynamic>> historicalData;

  TankDetailLoaded({
    required this.tank,
    this.waterQuality,
    required this.historicalData,
  });
}

class TankError extends TankState {
  final String message;
  TankError(this.message);
}