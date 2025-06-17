// lib/presentation/blocs/add_tank/add_tank_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waterguard/data/services/tank_service.dart';
import 'package:waterguard/data/models/backend_models.dart';

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
      final userId = int.parse(event.userId);
      final tankData = await tankService.createTank(userId);

      // Convertir la respuesta del backend a nuestro modelo
      final tank = BackendTankModel.fromJson(tankData);

      emit(AddTankSuccess(tank: tank));
    } catch (e) {
      emit(AddTankError('Error al crear el tanque: ${e.toString()}'));
    }
  }

  Future<void> _onResetState(
      ResetAddTankState event,
      Emitter<AddTankState> emit,
      ) async {
    emit(AddTankInitial());
  }
}