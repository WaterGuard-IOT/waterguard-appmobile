// lib/presentation/blocs/add_tank/add_tank_event.dart
abstract class AddTankEvent {}

class CreateTank extends AddTankEvent {
  final String userId;

  CreateTank({required this.userId});
}

class ResetAddTankState extends AddTankEvent {}