// lib/main.dart - SETUP MIXTO: Backend Real + Mock para Calidad/Alertas
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waterguard/app/app.dart';
import 'package:waterguard/data/datasources/mock/mock_data_provider.dart';
import 'package:waterguard/data/repositories/alert_repository_impl.dart';
import 'package:waterguard/data/repositories/water_quality_repository_impl.dart';
import 'package:waterguard/data/repositories/user_settings_repository_impl.dart';
import 'package:waterguard/domain/repositories/alert_repository.dart';
import 'package:waterguard/domain/repositories/tank_repository.dart';
import 'package:waterguard/domain/repositories/user_repository.dart';
import 'package:waterguard/domain/repositories/user_settings_repository.dart';
import 'package:waterguard/domain/repositories/water_quality_repository.dart';

import 'data/repositories/backend_repositories.dart';
import 'data/services/auth_service.dart';
import 'data/services/http_service.dart';
import 'data/services/tank_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Inicializar MockDataProvider SOLO para calidad y alertas
  final mockDataProvider = MockDataProvider();
  await mockDataProvider.init();

  // Setup mixto: Backend real + Mock para funcionalidades específicas
  setupMixedDependencies(mockDataProvider);

  runApp(const WaterGuardApp());
}

void setupMixedDependencies(MockDataProvider mockDataProvider) {
  print('🔧 Configurando dependencias mixtas...');
  print('🌐 Backend real: Usuarios, Tanques, Autenticación');
  print('🧪 Mock: Calidad de agua, Alertas');

  // --- SERVICIOS HTTP Y BACKEND REAL ---
  getIt.registerSingleton<HttpService>(HttpService());

  getIt.registerSingleton<AuthService>(
    AuthService(getIt<HttpService>()),
  );

  getIt.registerSingleton<TankService>(
    TankService(getIt<HttpService>()),
  );

  // --- REPOSITORIOS DEL BACKEND REAL ---

  // ✅ USUARIOS - Backend real
  getIt.registerSingleton<UserRepository>(
    BackendUserRepositoryImpl(authService: getIt<AuthService>()),
  );

  // ✅ TANQUES - Backend real
  getIt.registerSingleton<TankRepository>(
    BackendTankRepositoryImpl(tankService: getIt<TankService>()),
  );

  // --- REPOSITORIOS MOCKEADOS ---

  // 🧪 CALIDAD DE AGUA - Mockeado (pH, temperatura, etc.)
  getIt.registerSingleton<WaterQualityRepository>(
    WaterQualityRepositoryImpl(mockDataProvider: mockDataProvider),
  );

  // 🧪 ALERTAS - Mockeado (notificaciones)
  getIt.registerSingleton<AlertRepository>(
    AlertRepositoryImpl(mockDataProvider: mockDataProvider),
  );

  // --- REPOSITORIOS LOCALES ---

  // 💾 CONFIGURACIONES DE USUARIO - SharedPreferences local
  getIt.registerSingleton<UserSettingsRepository>(
    UserSettingsRepositoryImpl(),
  );

  // ✅ REGISTRAR MOCK DATA PROVIDER PARA REPOSITORIOS QUE LO NECESITEN
  getIt.registerSingleton<MockDataProvider>(mockDataProvider);

  print('✅ Configuración mixta completada');
  print('📊 Dashboard usará: Backend (tanques) + Mock (calidad, alertas)');
}

// Función anterior para referencia (comentada)
void setupBackendDependencies() {
  // --- ESTA FUNCIÓN YA NO SE USA ---
  // Servicios HTTP
  // getIt.registerSingleton<HttpService>(HttpService());
  //
  // getIt.registerSingleton<AuthService>(
  //   AuthService(getIt<HttpService>()),
  // );
  //
  // getIt.registerSingleton<TankService>(
  //   TankService(getIt<HttpService>()),
  // );
  //
  // // Repositorios que se conectan al backend
  // getIt.registerSingleton<UserRepository>(
  //   BackendUserRepositoryImpl(authService: getIt<AuthService>()),
  // );
  //
  // getIt.registerSingleton<TankRepository>(
  //   BackendTankRepositoryImpl(tankService: getIt<TankService>()),
  // );
  //
  // getIt.registerSingleton<WaterQualityRepository>(
  //   BackendWaterQualityRepositoryImpl(tankService: getIt<TankService>()),
  // );
  //
  // getIt.registerSingleton<AlertRepository>(
  //   BackendAlertRepositoryImpl(),
  // );
  //
  // // Repositorio de configuraciones (sigue usando SharedPreferences)
  // getIt.registerSingleton<UserSettingsRepository>(
  //   UserSettingsRepositoryImpl(),
  // );
}

void setupDependencies(MockDataProvider mockDataProvider) {
  // --- ESTA FUNCIÓN YA NO SE USA (ERA PARA TODO MOCK) ---
  // getIt.registerSingleton<MockDataProvider>(mockDataProvider);
  //
  // getIt.registerSingleton<TankRepository>(
  //   TankRepositoryImpl(mockDataProvider: getIt<MockDataProvider>()),
  // );
  //
  // getIt.registerSingleton<WaterQualityRepository>(
  //   WaterQualityRepositoryImpl(mockDataProvider: getIt<MockDataProvider>()),
  // );
  //
  // getIt.registerSingleton<UserRepository>(
  //   UserRepositoryImpl(mockDataProvider: getIt<MockDataProvider>()),
  // );
  //
  // getIt.registerSingleton<AlertRepository>(
  //   AlertRepositoryImpl(mockDataProvider: getIt<MockDataProvider>()),
  // );
  //
  // getIt.registerSingleton<UserSettingsRepository>(
  //   UserSettingsRepositoryImpl(),
  // );
}