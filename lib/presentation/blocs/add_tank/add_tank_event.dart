// lib/presentation/blocs/add_tank/add_tank_event.dart

abstract class AddTankEvent {}

// CORREGIDO: El evento ahora lleva todos los datos del tanque.
class CreateTank extends AddTankEvent {
  final Map<String, dynamic> tankData;

  CreateTank({required this.tankData});
}

class ResetAddTankState extends AddTankEvent {}