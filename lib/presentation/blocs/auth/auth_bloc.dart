// lib/presentation/blocs/auth/auth_bloc.dart - ACTUALIZADO
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waterguard/domain/repositories/user_repository.dart';
import 'package:waterguard/data/services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRepository userRepository;
  final AuthService authService; // ✅ YA NO ES OPCIONAL

  AuthBloc({
    required this.userRepository,
    required this.authService, // ✅ REQUERIDO
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
      print('🔄 Iniciando registro para: ${event.email}');

      // Registrar el usuario usando el servicio del backend
      final result = await authService.register(
        event.username,
        event.email,
        event.password,
      );

      print('✅ Registro completado: $result');

      if (result.isNotEmpty) {
        emit(RegisterSuccess());
        print('🎉 Usuario registrado exitosamente');
      } else {
        emit(AuthError('Error al crear la cuenta. Intenta de nuevo.'));
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      print('❌ Error en registro: $e');
      String errorMessage = 'Error al crear la cuenta: ';

      // Manejar errores específicos del backend
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('already exists') ||
          errorString.contains('duplicate') ||
          errorString.contains('ya existe') ||
          errorString.contains('username') ||
          errorString.contains('email')) {
        errorMessage = 'El usuario o email ya está registrado';
      } else if (errorString.contains('invalid email') ||
          errorString.contains('email inválido')) {
        errorMessage = 'El formato del email es inválido';
      } else if (errorString.contains('password') ||
          errorString.contains('contraseña')) {
        errorMessage = 'La contraseña no cumple con los requisitos';
      } else if (errorString.contains('connection') ||
          errorString.contains('timeout') ||
          errorString.contains('network')) {
        errorMessage = 'Error de conexión. Verifica tu internet.';
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

    try {
      // ✅ USAR EL MÉTODO DE LOGOUT DEL AUTH SERVICE
      await authService.logout();

      emit(AuthUnauthenticated());
      print('✅ Sesión cerrada exitosamente');
    } catch (e) {
      print('❌ Error al cerrar sesión: $e');
      // Aún así cerrar sesión localmente
      emit(AuthUnauthenticated());
    }
  }
}