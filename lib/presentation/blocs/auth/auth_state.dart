abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String userId;

  AuthAuthenticated(this.userId);
}

class AuthUnauthenticated extends AuthState {}

class RegisterSuccess extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}