// lib/presentation/blocs/auth/auth_bloc.dart - REEMPLAZAR TODO EL CONTENIDO
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waterguard/domain/repositories/user_repository.dart';
import 'package:waterguard/data/services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRepository userRepository;
  final AuthService? authService;

  AuthBloc({
    required this.userRepository,
    this.authService,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
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

  Future<void> _onRegisterRequested(
      RegisterRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      if (authService == null) {
        emit(AuthError('Servicio de autenticación no disponible'));
        return;
      }

      // Registrar el usuario usando el servicio del backend
      final result = await authService!.register(
        event.username,
        event.email,
        event.password,
      );

      if (result.isNotEmpty) {
        emit(RegisterSuccess());
      } else {
        emit(AuthError('Error al crear la cuenta. Intenta de nuevo.'));
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      String errorMessage = 'Error al crear la cuenta: ';

      // Manejar errores específicos del backend
      if (e.toString().contains('already exists') ||
          e.toString().contains('duplicate') ||
          e.toString().contains('ya existe')) {
        errorMessage = 'El usuario o email ya está registrado';
      } else if (e.toString().contains('invalid email') ||
          e.toString().contains('email inválido')) {
        errorMessage = 'El formato del email es inválido';
      } else if (e.toString().contains('password') ||
          e.toString().contains('contraseña')) {
        errorMessage = 'La contraseña no cumple con los requisitos';
      } else {
        errorMessage += e.toString();
      }

      emit(AuthError(errorMessage));
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