// lib/presentation/blocs/auth/auth_bloc.dart - ACTUALIZADO PARA USERNAME
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waterguard/domain/repositories/user_repository.dart';
import 'package:waterguard/data/services/auth_service.dart';
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
      print('🔄 Procesando login para: ${event.email}');

      // NOTA: Aunque el campo se llama 'email' en el evento por compatibilidad,
      // ahora puede contener username o email
      final user = await userRepository.authenticateUser(
        event.email, // Puede ser username o email
        event.password,
      );

      if (user != null) {
        print('✅ Login exitoso para usuario: ${user.name}');
        emit(AuthAuthenticated(user.id));
      } else {
        print('❌ Login falló - credenciales inválidas');
        emit(AuthError('Credenciales inválidas. Verifica tu username y contraseña.'));
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      print('❌ Error en login: $e');

      String errorMessage = 'Error al iniciar sesión: ';
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('401') || errorString.contains('unauthorized')) {
        errorMessage = 'Username o contraseña incorrectos';
      } else if (errorString.contains('connection') ||
          errorString.contains('timeout') ||
          errorString.contains('network')) {
        errorMessage = 'Error de conexión. Verifica tu internet.';
      } else if (errorString.contains('server') || errorString.contains('500')) {
        errorMessage = 'Error del servidor. Intenta más tarde.';
      } else {
        errorMessage += 'Verifica tus credenciales e intenta de nuevo.';
      }

      emit(AuthError(errorMessage));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onRegisterRequested(
      RegisterRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      print('🔄 Iniciando registro para username: ${event.username}');

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