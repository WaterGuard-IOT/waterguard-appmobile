// lib/presentation/blocs/auth/auth_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waterguard/data/services/auth_service.dart';
import 'package:waterguard/domain/repositories/user_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRepository userRepository;
  final AuthService authService;

  AuthBloc({
    required this.userRepository,
    required this.authService,
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
      print('🔄 BLoC: Procesando login para username: ${event.username}');

      // CORREGIDO: Se llama al repositorio con los parámetros correctos.
      final user = await userRepository.authenticateUser(
        event.username,
        event.password,
      );

      if (user != null) {
        print('✅ BLoC: Login exitoso para usuario: ${user.name}');
        emit(AuthAuthenticated(user.id));
      } else {
        print('❌ BLoC: Login falló, credenciales inválidas.');
        emit(AuthError('Credenciales inválidas. Verifica tu username y contraseña.'));
        // No emitir AuthUnauthenticated aquí para que el error se muestre
      }
    } catch (e) {
      print('❌ BLoC: Error en login: $e');
      emit(AuthError('Error al iniciar sesión: ${e.toString()}'));
    }
  }

  Future<void> _onRegisterRequested(
      RegisterRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      print('🔄 BLoC: Iniciando registro para username: ${event.username}');
      final result = await authService.register(
        event.username,
        event.email,
        event.password,
      );

      if (result.isNotEmpty) {
        emit(RegisterSuccess());
        print('🎉 BLoC: Usuario registrado exitosamente.');
      } else {
        emit(AuthError('Error al crear la cuenta. Intenta de nuevo.'));
      }
    } catch (e) {
      print('❌ BLoC: Error en registro: $e');
      final errorString = e.toString().toLowerCase();
      String errorMessage = 'Error al crear la cuenta.';
      if (errorString.contains('already exists') || errorString.contains('duplicate')) {
        errorMessage = 'El usuario o email ya está registrado.';
      }
      emit(AuthError(errorMessage));
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event,
      Emitter<AuthState> emit,
      ) async {
    await authService.logout();
    emit(AuthUnauthenticated());
    print('✅ BLoC: Sesión cerrada.');
  }
}
