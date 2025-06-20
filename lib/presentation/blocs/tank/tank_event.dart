// lib/presentation/blocs/tank/tank_event.dart

abstract class TankEvent {}

class LoadTankDetail extends TankEvent {
final String tankId;
LoadTankDetail({required this.tankId});
}

class TogglePump extends TankEvent {
final String tankId;
final bool active;
TogglePump({required this.tankId, required this.active});
}

// NUEVO EVENTO: Para actualizar un tanque
class UpdateTank extends TankEvent {
final int tankId;
final Map<String, dynamic> tankData;
UpdateTank({required this.tankId, required this.tankData});
}