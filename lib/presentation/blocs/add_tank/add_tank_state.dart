// lib/presentation/blocs/add_tank/add_tank_state.dart
import 'package:waterguard/domain/entities/tank.dart';

abstract class AddTankState {}

class AddTankInitial extends AddTankState {}

class AddTankLoading extends AddTankState {}

class AddTankSuccess extends AddTankState {
  final Tank tank;

  AddTankSuccess({required this.tank});
}

class AddTankError extends AddTankState {
  final String message;

  AddTankError(this.message);
}