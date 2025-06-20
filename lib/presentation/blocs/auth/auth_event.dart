// lib/presentation/blocs/auth/auth_event.dart

abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  // CORREGIDO: El parámetro ahora es 'username' para reflejar su propósito.
  final String username;
  final String password;

  LoginRequested({
    required this.username,
    required this.password,
  });
}

class RegisterRequested extends AuthEvent {
  final String username;
  final String email;
  final String password;

  RegisterRequested({
    required this.username,
    required this.email,
    required this.password,
  });
}

class LogoutRequested extends AuthEvent {}
