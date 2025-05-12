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