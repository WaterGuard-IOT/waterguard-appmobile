import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waterguard/domain/repositories/user_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRepository userRepository;

  AuthBloc({required this.userRepository}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
      LoginRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      final user = await userRepository.authenticateUser(
        event.email,
        event.password,
      );

      if (user != null) {
        emit(AuthAuthenticated(user.id));
      } else {
        emit(AuthError('Credenciales inválidas. Por favor intenta de nuevo.'));
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError('Error al iniciar sesión: ${e.toString()}'));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    // Aquí podrías agregar lógica para limpiar tokens o sesiones
    emit(AuthUnauthenticated());
  }
}