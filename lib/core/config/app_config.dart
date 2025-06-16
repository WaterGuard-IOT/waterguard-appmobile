class AppConfig {
  // URL del backend desplegado
  static const String baseUrl = 'https://172.178.70.242/api';

  // Para desarrollo local, puedes usar:
  // static const String baseUrl = 'http://10.0.2.2:443/api'; // Para Android Emulator
  // static const String baseUrl = 'http://localhost:443/api'; // Para iOS Simulator

  // Configuración de timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  // Configuración de la aplicación
  static const String appName = 'WaterGuard';
  static const String appVersion = '1.0.0';

  // Configuración de autenticación
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'current_user_id';

  // Configuración de la aplicación según el entorno
  static bool get isProduction => const bool.fromEnvironment('dart.vm.product');
  static bool get isDevelopment => !isProduction;

  // URLs específicas del backend
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String usersEndpoint = '/auth/users';

  // Función para obtener la URL de tanques por usuario
  static String tanksByUserEndpoint(String userId) => '/usuario/$userId/tanques';
  static String tankByIdEndpoint(String tankId) => '/tanque/$tankId';
  static String tankQualityEndpoint(String tankId) => '/tanque/$tankId/calidad';
  static String tankLevelEndpoint(String tankId) => '/tanque/$tankId/nivel';
}

// Clase para manejar diferentes entornos
class Environment {
  static const String development = 'development';
  static const String staging = 'staging';
  static const String production = 'production';

  static String get current {
    return const String.fromEnvironment('ENVIRONMENT', defaultValue: development);
  }

  static bool get isDevelopment => current == development;
  static bool get isStaging => current == staging;
  static bool get isProduction => current == production;
}

// Configuración específica por entorno
class EnvironmentConfig {
  static String get baseUrl {
    switch (Environment.current) {
      case Environment.production:
        return 'https://172.178.70.242/api';
      case Environment.staging:
        return 'https://172.178.70.242/api';
      default:
        return 'https://172.178.70.242/api'; // Backend desplegado
    }
  }

  static bool get enableLogging => Environment.isDevelopment;
}