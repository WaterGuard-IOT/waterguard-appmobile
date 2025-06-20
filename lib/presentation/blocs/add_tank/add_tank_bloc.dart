// lib/presentation/blocs/add_tank/add_tank_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waterguard/data/models/backend_models.dart';
import 'package:waterguard/data/services/tank_service.dart';
import 'package:waterguard/presentation/blocs/add_tank/add_tank_event.dart';
import 'package:waterguard/presentation/blocs/add_tank/add_tank_state.dart';

class AddTankBloc extends Bloc<AddTankEvent, AddTankState> {
  final TankService tankService;

  AddTankBloc({required this.tankService}) : super(AddTankInitial()) {
    on<CreateTank>(_onCreateTank);
    on<ResetAddTankState>(_onResetState);
  }

  Future<void> _onCreateTank(
      CreateTank event,
      Emitter<AddTankState> emit,
      ) async {
    emit(AddTankLoading());
    try {
      // CORREGIDO: Llama al servicio con el mapa de datos completo.
      final tankData = await tankService.createTank(event.tankData);
      final tank = BackendTankModel.fromJson(tankData);
      emit(AddTankSuccess(tank: tank));
    } catch (e) {
      emit(AddTankError('Error al crear el tanque: ${e.toString()}'));
    }
  }

  void _onResetState(
      ResetAddTankState event,
      Emitter<AddTankState> emit,
      ) {
    emit(AddTankInitial());
  }
}